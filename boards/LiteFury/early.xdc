# "Early" constraints file
# Evaluated before integrated IP


###############################################################################
# PCIe x4
###############################################################################

# PCIe lane 0

# PCIe lane 1
set_property LOC GTPE2_CHANNEL_X0Y6 [get_cells {design_1_i/xdma_0/inst/design_1_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN A10 [get_ports {pcie_mgt_rxn[0]}]
set_property PACKAGE_PIN B10 [get_ports {pcie_mgt_rxp[0]}]
set_property PACKAGE_PIN A6 [get_ports {pcie_mgt_txn[0]}]
set_property PACKAGE_PIN B6 [get_ports {pcie_mgt_txp[0]}]

# PCIe lane 2

# PCIe lane 3
set_property LOC GTPE2_CHANNEL_X0Y4 [get_cells {design_1_i/xdma_0/inst/design_1_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN A8 [get_ports {pcie_mgt_rxn[1]}]
set_property PACKAGE_PIN B8 [get_ports {pcie_mgt_rxp[1]}]
set_property PACKAGE_PIN A4 [get_ports {pcie_mgt_txn[1]}]
set_property PACKAGE_PIN B4 [get_ports {pcie_mgt_txp[1]}]
set_property LOC GTPE2_CHANNEL_X0Y7 [get_cells {design_1_i/xdma_0/inst/design_1_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN C9 [get_ports {pcie_mgt_rxn[3]}]
set_property PACKAGE_PIN D9 [get_ports {pcie_mgt_rxp[3]}]
set_property PACKAGE_PIN C7 [get_ports {pcie_mgt_txn[3]}]
set_property PACKAGE_PIN D7 [get_ports {pcie_mgt_txp[3]}]

# PCIe refclock
set_property PACKAGE_PIN F6 [get_ports {pcie_clkin_clk_p[0]}]
set_property PACKAGE_PIN E6 [get_ports {pcie_clkin_clk_n[0]}]

# Other PCIe signals
set_property PACKAGE_PIN G1 [get_ports {pcie_clkreq_l[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pcie_clkreq_l[0]}]
set_property PACKAGE_PIN J1 [get_ports pci_reset]
set_property IOSTANDARD LVCMOS33 [get_ports pci_reset]





