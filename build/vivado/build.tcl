#
# DVB IP
#
# Copyright 2019 by Andre Souto (suoto)
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

set path_to_repo_root [ file normalize "[ file dirname [ info script ] ]/../../"]

create_project dvbs2_encoder ${path_to_repo_root}/build/vivado/dvbs2_encoder -part xczu4cg-sfvc784-1LV-i -force

set_property library str_format [ add_files [ glob ${path_to_repo_root}/third_party/hdl_string_format/src/str_format_pkg.vhd ] ]
set_property library fpga_cores [ add_files [ glob ${path_to_repo_root}/third_party/fpga_cores/src/*.vhd ] ]

add_files [ glob ${path_to_repo_root}/rtl/polyphase_filter/*.vhd ]
add_files [ glob ${path_to_repo_root}/rtl/ldpc/*.vhd ]
add_files [ glob ${path_to_repo_root}/rtl/*.vhd ]
set_property FILE_TYPE {VHDL 2008} [ get_files *.vhd ]

add_files ${path_to_repo_root}/build/vivado/dvbs2_encoder_wrapper.vhd

add_files [ glob ${path_to_repo_root}/third_party/airhdl/*.vhd ]
add_files [ glob ${path_to_repo_root}/third_party/bch_generated/*.vhd ]

# WARNING: [Synth 8-6849] Infeasible attribute ram_style = "block" set for RAM
# "ldpc_encoder_u/frame_ram_u/ram_u/ram_reg", trying to implement using LUTRAM
set_msg_config -id "Synth 8-6849" -new_severity ERROR

# CRITICAL WARNING: [Synth 8-507] null range (31 downto 32) not supported
# We're largely OK with null ranges, make it a regular warning
set_msg_config -id "Synth 8-507" -new_severity WARNING


# INFO: [Synth 8-7053] The timing for the instance
# ldpc_encoder_u/frame_ram_u/ram_u/ram_reg_bram_0 (implemented as a Block RAM) might be
# sub-optimal as no optional output register could be merged into the ram block. Providing
# additional output register may help in improving timing.
# set_msg_config -id "Synth 8-7053" -new_severity ERROR

set_property TOP dvbs2_encoder_wrapper [ current_fileset ]
set_property STEPS.SYNTH_DESIGN.ARGS.ASSERT true [ get_runs synth_1 ]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -object [get_runs synth_1]

add_files -fileset constrs_1 build/vivado/constraints.xdc
set_property target_constrs_file build/vivado/constraints.xdc [current_fileset -constrset]

launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1
wait_on_run impl_1
