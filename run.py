#!/usr/bin/env python3

#
# DVB FPGA
#
# Copyright 2019 by Suoto <andre820@gmail.com>
#
# This file is part of DVB FPGA.
#
# DVB FPGA is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DVB FPGA is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DVB FPGA.  If not, see <http://www.gnu.org/licenses/>.

# pylint: disable=bad-continuation

import logging
import os.path as p
import random
import struct
import sys
from collections import namedtuple
from enum import Enum

from vunit import VUnit  # type: ignore

_logger = logging.getLogger(__name__)


ROOT = p.abspath(p.dirname(__file__))


def main():
    cli = VUnit.from_argv()
    cli.add_osvvm()
    cli.add_com()
    cli.enable_location_preprocessing()

    library = cli.add_library("lib")
    library.add_source_files(p.join(ROOT, "rtl", "*.vhd"))
    library.add_source_files(p.join(ROOT, "rtl", "bch_generated", "*.vhd"))

    library.add_source_files(p.join(ROOT, "testbench", "*.vhd"))
    library.add_source_files(p.join(ROOT, "testbench", "*", "*.vhd"))

    cli.add_library("str_format").add_source_files(
        p.join(ROOT, "third_party", "hdl_string_format", "src", "*.vhd")
    )

    addAxiStreamDelayTests(cli.library("lib").entity("axi_stream_delay_tb"))
    addAxiFileReaderTests(cli.library("lib").entity("axi_file_reader_tb"))

    parametrizeTests(
        entity=cli.library("lib").entity("axi_bit_interleaver_tb"),
        input_file_basename="bit_interleaver_input.bin",
        reference_file_basename="bit_interleaver_output.bin",
        detailed=True,
    )

    parametrizeTests(
        entity=cli.library("lib").entity("axi_bch_encoder_tb"),
        input_file_basename="bch_encoder_input.bin",
        reference_file_basename="ldpc_encoder_input.bin",
        detailed=True,
    )

    cli.set_compile_option("modelsim.vcom_flags", ["-explicit"])
    cli.set_compile_option("ghdl.flags", ["-frelaxed-rules"])

    # Needed for older ModelSim versions
    # cli.set_compile_option("modelsim.vcom_flags", ["-novopt"])
    # cli.set_sim_option("modelsim.vsim_flags", ["-novopt"])

    cli.set_sim_option("disable_ieee_warnings", True)
    cli.set_sim_option("modelsim.init_file.gui", p.join(ROOT, "wave.do"))
    cli.main()


Parameters = namedtuple("Parameters", ("constellation", "frame_length", "code_rate"))


class ConstellationType(Enum):
    MOD_8PSK = "8PSK"
    MOD_16APSK = "16APSK"
    MOD_32APSK = "32APSK"


class FrameLength(Enum):
    FECFRAME_NORMAL = "normal"
    FECFRAME_SHORT = "short"


class CodeRate(Enum):
    C1_4 = "1/4"
    C1_3 = "1/3"
    C2_5 = "2/5"
    C1_2 = "1/2"
    C3_5 = "3/5"
    C2_3 = "2/3"
    C3_4 = "3/4"
    C4_5 = "4/5"
    C5_6 = "5/6"
    C8_9 = "8/9"
    C9_10 = "9/10"


def parametrizeTests(
    entity, input_file_basename, reference_file_basename, detailed=False
):

    test_cfg = []

    for code_rate in CodeRate:

        for frame_length in FrameLength:
            for constellation in ConstellationType:

                data_files = p.join(
                    ROOT,
                    "gnuradio_data",
                    f"{frame_length.name}_{constellation.name}_{code_rate.name}".upper(),
                )

                input_file_path = p.join(data_files, input_file_basename)
                reference_file_path = p.join(data_files, reference_file_basename)

                if not p.exists(input_file_path) or not p.exists(reference_file_path):
                    if not p.exists(input_file_path):
                        _logger.warning("No such file '%s'", input_file_path)
                    if not p.exists(reference_file_path):
                        _logger.warning("No such file '%s'", reference_file_path)
                    continue

                test_cfg += [
                    ",".join(
                        [
                            constellation.name,
                            frame_length.name,
                            code_rate.name,
                            input_file_path,
                            reference_file_path,
                        ]
                    )
                ]

                if detailed:
                    test_name = ",".join(
                        [
                            f"FrameLength={frame_length.value}",
                            f"ConstellationType={constellation.value}",
                            f"CodeRate={code_rate.value}",
                        ]
                    )
                    entity.add_config(
                        name=test_name, generics={"test_cfg": "|".join(test_cfg)}
                    )
                    test_cfg = []

    if not detailed:
        assert test_cfg, f"No tests found for {entity.name}"

        entity.add_config(name="all_configs", generics={"test_cfg": "|".join(test_cfg)})


def addAxiStreamDelayTests(entity):
    for delay in (1, 2, 8):
        entity.add_config(name=f"delay={delay}", parameters={"DELAY_CYCLES": delay})


def addAxiFileReaderTests(entity):
    for data_width in (8, 32):
        all_configs = []

        for ratio in (
            (1, 8),
            (2, 8),
            (3, 8),
            (4, 8),
            (5, 8),
            (6, 8),
            (7, 8),
            (8, 8),
            (1, 4),
            (2, 4),
            (1, 1),
            (8, 32),
        ):

            # Test makes no sense but eaiser doing this than separating a loop
            # just for data width 4
            if max(ratio) > data_width:
                continue

            basename = (
                f"file_reader_data_width_{data_width}_ratio_{ratio[0]}_{ratio[1]}"
            )

            test_file = p.join(ROOT, "vunit_out", basename + "_input.bin")
            reference_file = p.join(ROOT, "vunit_out", basename + "_reference.bin")

            if not (p.exists(test_file) and p.exists(reference_file)):
                generateAxiFileReaderTestFile(
                    test_file=test_file,
                    reference_file=reference_file,
                    data_width=data_width,
                    length=256 * data_width,
                    ratio=ratio,
                )

            name = f"single,data_width={data_width},ratio={ratio[0]}:{ratio[1]}"

            test_cfg = ",".join([f"{ratio[0]}:{ratio[1]}", test_file, reference_file])

            all_configs += [test_cfg]

            entity.add_config(
                name=name, parameters={"DATA_WIDTH": data_width, "test_cfg": test_cfg}
            )

        entity.add_config(
            name=f"multiple,data_width={data_width}",
            parameters={"DATA_WIDTH": data_width, "test_cfg": "|".join(all_configs)},
        )


def swapBits(value, width=8):
    v_in_binary = bin(value)[2:]

    assert len(v_in_binary) <= width, "input is too big"

    v_in_binary = "0" * (width - len(v_in_binary)) + v_in_binary
    return int(v_in_binary[::-1], 2)


def generateAxiFileReaderTestFile(test_file, reference_file, data_width, length, ratio):
    rand_max = 2 ** data_width - 1
    ratio_first, ratio_second = ratio
    packed_data = []
    unpacked_bytes = []

    buffer_length = 0
    buffer_data = 0
    byte = ""

    for _ in range(length):
        for ratio_i in reversed(range(ratio_second)):
            if ratio_i < ratio_first:
                # Generate a new data word every time the previous is read out
                # completely
                if buffer_length == 0:
                    buffer_data = random.randrange(0, rand_max)
                    packed_data += [buffer_data]

                    buffer_data = swapBits(buffer_data, width=data_width)
                    buffer_length += data_width

                byte += str(buffer_data & 1)

                buffer_data >>= 1
                buffer_length -= 1
            else:
                # Pad only
                byte += "0"

            # Every time we get enough data, save it and reset it
            if len(byte) == 8:
                unpacked_bytes += [int(byte, 2)]
                byte = ""

    assert not byte, (
        f"Data width {data_width}, length {length} is invalid, "
        "need to make sure data_width*length is divisible by 8"
    )

    with open(test_file, "wb") as fd:
        for byte in unpacked_bytes:
            fd.write(struct.pack(">B", byte))

    # Format will depend on the data width, need to be wide enough for to fit
    # one character per nibble
    fmt = "%.{}x\n".format((data_width + 3) // 4)
    with open(reference_file, "w") as fd:
        for word in packed_data:
            fd.write(fmt % word)

    return packed_data


if __name__ == "__main__":
    sys.exit(main())
