#!/usr/bin/env python3

import os.path as p
import struct
import sys
import tempfile
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

    add_axi_stream_delay_tb_tests(cli)
    add_axi_file_reader_tb_tests(cli)
    add_axi_bit_interleaver_tests(cli)

    cli.set_compile_option("modelsim.vcom_flags", ["-novopt", "-explicit"])
    cli.set_sim_option("modelsim.vsim_flags", ["-novopt"])
    cli.set_sim_option("disable_ieee_warnings", True)
    cli.set_sim_option("modelsim.init_file.gui", p.join(ROOT, "wave.do"))
    cli.main()


Parameters = namedtuple("Parameters", ("modulation", "frame_length", "code_rate"))


def _iter_params():
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


def add_axi_bit_interleaver_tests(cli):
    axi_bit_interleaver_tb = cli.library("lib").entity("axi_bit_interleaver_tb")

    for modulation, frame_length, code_rate in _iter_params():

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

        output_path = p.join(ROOT, "vunit_out")
        config_file = p.join(output_path, test_name + ".csv")

        with open(config_file, "w") as fd:
            fd.write(
                ",".join(
                    map(
                        str,
                        (
                            modulation,
                            frame_length,
                            code_rate,
                            input_file,
                            reference_file,
                        ),
                    )
                )
            )

        axi_bit_interleaver_tb.add_config(
            name=test_name, generics={"CONFIG_FILE": config_file}
        )


def add_axi_stream_delay_tb_tests(cli):
    axi_stream_delay_tb = cli.library("lib").entity("axi_stream_delay_tb")

    for delay in (1, 2, 8):
        axi_stream_delay_tb.add_config(
            name=f"delay={delay}", parameters={"DELAY_CYCLES": delay}
        )


def add_axi_file_reader_tb_tests(cli):
    axi_file_reader_tb = cli.library("lib").entity("axi_file_reader_tb")

    #  filename = "/home/souto/test.bin"
    #  filename = "/home/souto/phase4ground/bch_tests/bch_input.bin"
    filename = "/home/souto/phase4ground/bch_tests/golden_input.bin"

    for data_width, fmt in ((8, "B"), (32, "I")):
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
