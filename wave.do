add  wave  -noupdate -expand -group "TB top" "sim:/*"
add  wave  -noupdate -expand -group "DUT"    "sim:/dut/*"
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
