#!/usr/bin/env python3

import os.path as p
import sys

from vunit import VUnit  # type: ignore


def main():
    cli = VUnit.from_argv()
    cli.add_osvvm()
    cli.enable_location_preprocessing()

    root = p.dirname(__file__)

    library = cli.add_library("lib")
    library.add_source_files(p.join(root, "rtl", "*.vhd"))
    library.add_source_files(p.join(root, "third_party", "wb2axip", "rtl", "skidbuffer.v"))

    tb_lib = cli.add_library("tb_lib")

    tb_lib.add_source_files(p.join(root, "testbench", "*.vhd"))
    tb_lib.add_source_files(p.join(root, "testbench", "*", "*.vhd"))

    cli.add_library("str_format").add_source_files(
        p.join(root, "third_party", "hdl_string_format", "src", "*.vhd")
    )

    add_axi_stream_delay_tb_tests(cli)

    cli.set_compile_option("modelsim.vcom_flags", ["-novopt", "-explicit"])
    cli.set_sim_option("modelsim.vsim_flags", ["-novopt"])
    cli.set_sim_option("disable_ieee_warnings", True)
    cli.set_sim_option("modelsim.init_file.gui", p.join(root, "wave.do"))
    cli.main()

def add_axi_stream_delay_tb_tests(cli):
    axi_stream_delay_tb = cli.library('tb_lib').entity('axi_stream_delay_tb')

    #  def add_config(self,  # pylint: disable=too-many-arguments
    #                 name, generics=None, parameters=None, pre_config=None, post_check=None, sim_options=None,
    #                 attributes=None):
    for delay in (1, 2, 8):
        axi_stream_delay_tb.add_config(name=f'delay={delay}', parameters={'DELAY_CYCLES': delay})


if __name__ == "__main__":
    sys.exit(main())
