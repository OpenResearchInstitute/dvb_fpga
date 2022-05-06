#
# DVB FPGA
#
# Copyright 2019-2022 by suoto <andre820@gmail.com>
#
# This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
#
# You may redistribute and modify this source and make products using it under
# the terms of the CERN-OHL-W v2 (https://ohwr.org/cern_ohl_w_v2.txt).
#
# This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
# OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
# Please see the CERN-OHL-W v2 for applicable conditions.
#
# Source location: https://github.com/phase4ground/dvb_fpga
#
# As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
# source, You must maintain the Source Location visible on the external case of
# the DVB Encoder or other products you make using this source.

# Do this inside a function to avoid messing up with the caller's environment
proc add_dvbs2_files { } {
  set path_to_repo_root [ file normalize "[ file dirname [ info script ] ]/../../" ]

  set str_format [ add_files [ glob ${path_to_repo_root}/third_party/hdl_string_format/src/str_format_pkg.vhd ] ]
  set fpga_cores [ add_files [ glob ${path_to_repo_root}/third_party/fpga_cores/src/*.vhd ] ]
  set work [                                                  \
    add_files [                                               \
      glob                                                    \
        ${path_to_repo_root}/rtl/ldpc/*.vhd                   \
        ${path_to_repo_root}/rtl/*.vhd                        \
        ${path_to_repo_root}/third_party/airhdl/*.vhd         \
        ${path_to_repo_root}/third_party/bch_generated/*.vhd  \
    ]                                                         \
  ]

  set_property library str_format $str_format
  set_property library fpga_cores $fpga_cores
  set_property FILE_TYPE {VHDL 2008} [ get_files $fpga_cores ]
  set_property FILE_TYPE {VHDL 2008} [ get_files $str_format ]
  set_property FILE_TYPE {VHDL 2008} [ get_files $work ]

  set_property FILE_TYPE {VHDL} [ add_files [ glob ${path_to_repo_root}/build/vivado/dvbs2_encoder_wrapper.vhd ] ]
}

add_dvbs2_files
