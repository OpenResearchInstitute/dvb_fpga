#
# DVB FPGA
#
# Copyright 2019 by suoto <andre820@gmail.com>
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

set path_to_repo_root [ file normalize "[ file dirname [ info script ] ]/../../" ]

create_project dvbs2_encoder LiteFury -part xc7a100tfgg484-2L -force

source ${path_to_repo_root}/build/vivado/add_dvbs2_files.tcl
add_files ${path_to_repo_root}/build/vivado/dvbs2_encoder_wrapper.vhd
source ${path_to_repo_root}/boards/LiteFury/block_design.tcl

make_wrapper -files [ get_files LiteFury/dvbs2_encoder.srcs/sources_1/bd/design_1/design_1.bd ] -top
add_files -norecurse LiteFury/dvbs2_encoder.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v

add_files -fileset constrs_1 [ glob ${path_to_repo_root}/boards/LiteFury/*.xdc ]
set_property PROCESSING_ORDER {EARLY} [ get_files ${path_to_repo_root}/boards/LiteFury/early.xdc ]

update_compile_order -fileset sources_1
# Disabling source management mode.  This is to allow the top design properties to be set without GUI intervention.
set_property source_mgmt_mode None [ current_project ]
set_property top design_1_wrapper [ current_fileset ]
# Re-enabling previously disabled source management mode.
set_property source_mgmt_mode All [ current_project ]
update_compile_order -fileset sources_1

# CRITICAL WARNING: [Synth 8-507] null range (31 downto 32) not supported
# We're largely OK with null ranges, make it a regular warning
set_msg_config -id "Synth 8-507" -new_severity WARNING

launch_runs synth_1 -jobs 8
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
