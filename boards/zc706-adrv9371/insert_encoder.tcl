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

proc insert_encoder { } {
  set path_to_repo_root [ file normalize "[ file dirname [ info script ] ]/../../" ]

  # Add DVB Encoder files and create an instance in the block design
  source ${path_to_repo_root}/build/vivado/add_dvbs2_files.tcl
  add_files ${path_to_repo_root}/build/vivado/dvbs2_encoder_wrapper.vhd

  # Open the block design and add an instance of the DVB encoder
  open_bd_design [ get_files system.bd ]
  create_bd_cell -type module -reference dvbs2_encoder_wrapper dvbs2_encoder_wrapper_0

  # Set input and output data width to 128 bit to match TX DMA and DAC FIFO
  # respectively
  set_property -dict [ list                     \
      CONFIG.INPUT_DATA_WIDTH {128}             \
      CONFIG.IQ_WIDTH {128}                     \
    ] [ get_bd_cells dvbs2_encoder_wrapper_0 ]

  # Set the clock properties of all interfaces to the DMA clock
  set_property CONFIG.CLK_DOMAIN system_sys_ps7_0_FCLK_CLK1 [ get_bd_pins /dvbs2_encoder_wrapper_0/clk ]
  set_property CONFIG.CLK_DOMAIN system_sys_ps7_0_FCLK_CLK1 [ get_bd_intf_pins /dvbs2_encoder_wrapper_0/s_axis ]
  set_property CONFIG.CLK_DOMAIN system_sys_ps7_0_FCLK_CLK1 [ get_bd_intf_pins /dvbs2_encoder_wrapper_0/s_axi_lite ]
  set_property CONFIG.CLK_DOMAIN system_sys_ps7_0_FCLK_CLK1 [ get_bd_intf_pins /dvbs2_encoder_wrapper_0/s_metadata ]

  # Disconnect the TX DMA master AXI-Stream from the DAC FIFO slave AXI-Stream
  delete_bd_objs                                    \
    [ get_bd_nets axi_ad9371_tx_dma_m_axis_valid ]  \
    [ get_bd_nets axi_ad9371_tx_dma_m_axis_data ]   \
    [ get_bd_nets axi_ad9371_tx_dma_m_axis_last ]   \
    [ get_bd_nets axi_ad9371_dacfifo_dma_ready ]

  # Connect the output of the TX DMA to the DVB Encoder
  connect_bd_intf_net                                    \
    [ get_bd_intf_pins axi_ad9371_tx_dma/m_axis ]        \
    [ get_bd_intf_pins dvbs2_encoder_wrapper_0/s_axis ]

  # Connect the output of the DVB Encoder to the DAC FIFO
  connect_bd_net [ get_bd_pins dvbs2_encoder_wrapper_0/m_axis_tlast ] [ get_bd_pins axi_ad9371_dacfifo/dma_xfer_last ]
  connect_bd_net [ get_bd_pins dvbs2_encoder_wrapper_0/m_axis_tvalid ] [ get_bd_pins axi_ad9371_dacfifo/dma_valid ]
  connect_bd_net [ get_bd_pins dvbs2_encoder_wrapper_0/m_axis_tdata ] [ get_bd_pins axi_ad9371_dacfifo/dma_data ]
  connect_bd_net [ get_bd_pins dvbs2_encoder_wrapper_0/m_axis_tready ] [ get_bd_pins axi_ad9371_dacfifo/dma_ready ]

  # Connect clock and reset
  connect_bd_net [ get_bd_pins dvbs2_encoder_wrapper_0/clk ] [ get_bd_pins sys_ps7/FCLK_CLK1 ]
  connect_bd_net [ get_bd_pins dvbs2_encoder_wrapper_0/rst_n ] [ get_bd_pins sys_ps7/FCLK_RESET1_N ]

  # Let Vivado connect the AXI-Lite interface
  apply_bd_automation                                          \
    -rule xilinx.com:bd_rule:axi4                              \
    -config {                                                  \
      Clk_master {/sys_ps7/FCLK_CLK0 (100 MHz)}                \
      Clk_slave {/sys_ps7/FCLK_CLK1 (200 MHz)}                 \
      Clk_xbar {/sys_ps7/FCLK_CLK0 (100 MHz)}                  \
      Master {/sys_ps7/M_AXI_GP0}                              \
      Slave {/dvbs2_encoder_wrapper_0/s_axi_lite}              \
      intc_ip {/axi_cpu_interconnect}                          \
      master_apm {0}                                           \
    } [ get_bd_intf_pins dvbs2_encoder_wrapper_0/s_axi_lite ]

  # Create dummy metadata tvalid and tdata for now
  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 s_metadata_tvalid
  set_property CONFIG.CONST_VAL 1 [ get_bd_cells /s_metadata_tvalid ]
  set_property CONFIG.CONST_WIDTH 1 [ get_bd_cells /s_metadata_tvalid ]
  connect_bd_net [ get_bd_pins s_metadata_tvalid/dout ] [ get_bd_pins dvbs2_encoder_wrapper_0/s_metadata_tvalid ]

  create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 s_metadata_tdata
  set_property CONFIG.CONST_VAL 0 [ get_bd_cells /s_metadata_tdata ]
  set_property CONFIG.CONST_WIDTH 8 [ get_bd_cells /s_metadata_tdata ]
  connect_bd_net [ get_bd_pins s_metadata_tdata/dout ] [ get_bd_pins dvbs2_encoder_wrapper_0/s_metadata_tdata ]

  validate_bd_design
}

insert_encoder
