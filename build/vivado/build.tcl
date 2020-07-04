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

create_project dvbs2_tx build/vivado/dvbs2_tx -part xczu4cg-sfvc784-1LV-i -force

set_property library str_format [ add_files [ glob third_party/hdl_string_format/src/str_format_pkg.vhd ] ]
set_property library fpga_cores [ add_files [ glob third_party/fpga_cores/src/*.vhd ] ]

add_files [ glob rtl/bch_generated/*.vhd ]
add_files [ glob rtl/ldpc/*.vhd ]
add_files [ glob rtl/*.vhd ]

# WARNING: [Synth 8-6849] Infeasible attribute ram_style = "block" set for RAM
# "ldpc_encoder_u/frame_ram_u/ram_u/ram_reg", trying to implement using LUTRAM
set_msg_config -id "Synth 8-6849" -new_severity ERROR

# INFO: [Synth 8-7053] The timing for the instance
# ldpc_encoder_u/frame_ram_u/ram_u/ram_reg_bram_0 (implemented as a Block RAM) might be
# sub-optimal as no optional output register could be merged into the ram block. Providing
# additional output register may help in improving timing.
# set_msg_config -id "Synth 8-7053" -new_severity ERROR

set_property TOP dvbs2_tx [ current_fileset ]
set_property STEPS.SYNTH_DESIGN.ARGS.ASSERT true [ get_runs synth_1 ]

launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1
wait_on_run impl_1
