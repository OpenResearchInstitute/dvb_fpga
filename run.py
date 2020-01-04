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

import os.path as p
import sys
from collections import namedtuple

from vunit import VUnit  # type: ignore

ROOT = p.abspath(p.dirname(__file__))


def main():
    cli = VUnit.from_argv()
    cli.add_osvvm()
    cli.add_com()
    cli.enable_location_preprocessing()

    library = cli.add_library("lib")
    library.add_source_files(p.join(ROOT, "rtl", "*.vhd"))
    library.add_source_files(p.join(ROOT, "rtl", "bch_generated", "*.vhd"))
    # We don't really need the entier wb2axip for now, just the skid buffer
    library.add_source_files(
        p.join(ROOT, "third_party", "wb2axip", "rtl", "skidbuffer.v")
    )

    library.add_source_files(p.join(ROOT, "testbench", "*.vhd"))
    library.add_source_files(p.join(ROOT, "testbench", "*", "*.vhd"))

    cli.add_library("str_format").add_source_files(
        p.join(ROOT, "third_party", "hdl_string_format", "src", "*.vhd")
    )

    addAxiStreamDelayTests(cli)
    addAxiFileReaderTests(cli)
    addAxiBitInterleaverTests(cli)
    addAxiBchEncoderTests(cli)

    cli.set_compile_option("modelsim.vcom_flags", ["-novopt", "-explicit"])
    cli.set_sim_option("modelsim.vsim_flags", ["-novopt"])
    cli.set_sim_option("disable_ieee_warnings", True)
    cli.set_sim_option("modelsim.init_file.gui", p.join(ROOT, "wave.do"))
    cli.main()


Parameters = namedtuple("Parameters", ("modulation", "frame_length", "code_rate"))


def _iterParams():
    for modulation_type in ("mod_8psk", "mod_16apsk", "mod_32apsk"):
        for frame_length in ("normal",):  # "short"):
            for code_rate in (
                "C1_4",
                "C1_3",
                "C2_5",
                "C1_2",
                "C3_5",
                "C2_3",
                "C3_4",
                "C4_5",
                "C5_6",
                "C8_9",
                "C9_10",
            ):
                yield Parameters(modulation_type, frame_length, code_rate)


def addAxiBchEncoderTests(cli):
    axi_bch_encoder_tb = cli.library("lib").entity("axi_bch_encoder_tb")

    test_cfg = []

    for modulation, frame_length, code_rate in _iterParams():

        data_files = p.join(
            ROOT,
            "gnuradio_data",
            f"FECFRAME_{frame_length}_{modulation}_{code_rate}".upper(),
        )

        input_file = p.join(data_files, "bch_encoder_input.bin")
        reference_file = p.join(data_files, "ldpc_encoder_input.bin")

        if not p.exists(input_file) or not p.exists(reference_file):
            continue

        test_cfg += [
            ",".join(
                map(
                    str,
                    (modulation, frame_length, code_rate, input_file, reference_file),
                )
            )
        ]

        # Can add this to run specific configs independently
        #  test_name = f"test_{frame_length}_frame_{modulation}_{code_rate}"
        #  axi_bch_encoder_tb.add_config(
        #      name=test_name, generics={"test_cfg": ":".join(test_cfg)}
        #  )

    axi_bch_encoder_tb.add_config(name="all", generics={"test_cfg": ":".join(test_cfg)})


def addAxiBitInterleaverTests(cli):
    axi_bit_interleaver_tb = cli.library("lib").entity("axi_bit_interleaver_tb")

    for modulation, frame_length, code_rate in _iterParams():

        data_files = p.join(
            ROOT,
            "gnuradio_data",
            f"FECFRAME_{frame_length}_{modulation}_{code_rate}".upper(),
        )

        input_file = p.join(data_files, "bit_interleaver_input.bin")
        reference_file = p.join(data_files, "bit_interleaver_output.bin")

        if not p.exists(input_file) or not p.exists(reference_file):
            continue

        test_name = f"test_{frame_length}_frame_{modulation}_{code_rate}"

        test_cfg = ",".join(
            map(str, (modulation, frame_length, code_rate, input_file, reference_file))
        )

        axi_bit_interleaver_tb.add_config(
            name=test_name, generics={"test_cfg": test_cfg}
        )


def addAxiStreamDelayTests(cli):
    axi_stream_delay_tb = cli.library("lib").entity("axi_stream_delay_tb")

    for delay in (1, 2, 8):
        axi_stream_delay_tb.add_config(
            name=f"delay={delay}", parameters={"DELAY_CYCLES": delay}
        )


def addAxiFileReaderTests(cli):
    axi_file_reader_tb = cli.library("lib").entity("axi_file_reader_tb")

    #  filename = "/home/souto/test.bin"
    #  filename = "/home/souto/phase4ground/bch_tests/bch_input.bin"
    filename = "/home/souto/phase4ground/bch_tests/golden_input.bin"

    for data_width in (8, 32):
        for bytes_are_bits in (False, True):

            ref_filename = f"dw_{data_width}_bytes_are_bits_{bytes_are_bits}.bin"

            filename = p.join(ROOT, "vunit_out", ref_filename)

            name = f"data_width={data_width},bytes_are_bits={bytes_are_bits}"

            axi_file_reader_tb.add_config(
                name=name,
                parameters={
                    "DATA_WIDTH": data_width,
                    "FILE_NAME": filename,
                    "BYTES_ARE_BITS": bytes_are_bits,
                },
            )


if __name__ == "__main__":
    sys.exit(main())
