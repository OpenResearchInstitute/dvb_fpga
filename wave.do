add  wave  -noupdate -expand -group "TB top" "sim:/*"
add  wave  -noupdate -expand -group "DUT"    "sim:/dut/*"
# add  wave  -noupdate -expand -group "DUT/poliyphase_filter" "sim:/dvbs2_encoder_tb/dut/polyphase_filter_u/*"
# add  wave  -noupdate -expand -group "DUT/poliyphase_filter/fir_filter\[0\]" "sim:/dvbs2_encoder_tb/dut/polyphase_filter_u/fir_filter\[0\]/fir_filter_inst/*"

add wave -noupdate -expand -group "axi debug" sim:/dvbs2_encoder_tb/dut/width_conv_dbg_u/*

# add  wave  -noupdate -expand -group "DUT/width converter"  \
#   "sim:/dvbs2_encoder_tb/dut/force_8_bit_u/*"                   \
#   "sim:/dvbs2_encoder_tb/dut/force_8_bit_u/g_downsize/*"

# add  wave  -noupdate -expand -group "DUT/physical layer framer"  

# add  wave  -noupdate -expand -group "DUT/arbiter"                                                 \
#   sim:/dvbs2_encoder_tb/dut/pre_constellaion_mapper_arbiter_block/*                                    \
#   sim:/dvbs2_encoder_tb/dut/pre_constellaion_mapper_arbiter_block/pre_constellaion_mapper_arbiter_u/*

# add  wave  -noupdate -expand -group "DUT/bit mapper"   \
#   sim:/dvbs2_encoder_tb/dut/constellation_mapper_u/*

# add  wave  -noupdate -expand -group "DUT" -group "bch" sim:/axi_bit_interleaver_tb/dut/bch_u/*
# add  wave  -noupdate -expand -group "file reader" sim:/axi_bit_interleaver_tb/axi_file_reader_u/*
# add  wave  -noupdate -expand -group "file cmp" sim:/axi_bit_interleaver_tb/axi_file_compare_u/*
# add  wave  -noupdate -expand -group "file cmp" -group "reader" sim:/axi_bit_interleaver_tb/axi_file_compare_u/axi_file_reader_u/*
#
# add wave -noupdate -group DUT                    \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr         \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(0)      \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(0).addr \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(0).data \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(0).en   \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(1)      \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(1).addr \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(1).data \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(1).en   \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(2)      \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(2).addr \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(2).data \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(2).en   \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(3)      \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(3).addr \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(3).data \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(3).en   \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(4)      \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(4).addr \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(4).data \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(4).en   \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(5)      \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(5).addr \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(5).data \
#   sim:/axi_bit_interleaver_tb/dut/ram_wr(5).en

configure wave -namecolwidth 300
configure wave -valuecolwidth 120
# update
