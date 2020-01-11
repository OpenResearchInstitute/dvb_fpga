add  wave  -noupdate -expand -group "TB top" "sim:/*"
add  wave  -noupdate -expand -group "DUT"    "sim:/dut/*"
# add  wave  -noupdate -expand -group "DUT" -group "bch" sim:/axi_bit_interleaver_tb/dut/bch_u/*
add  wave  -noupdate -expand -group "file reader" sim:/axi_bit_interleaver_tb/axi_file_reader_u/*
# add  wave  -noupdate -expand -group "file cmp" sim:/axi_bit_interleaver_tb/axi_file_compare_u/*
# add  wave  -noupdate -expand -group "file cmp" -group "reader" sim:/axi_bit_interleaver_tb/axi_file_compare_u/axi_file_reader_u/*

configure wave -namecolwidth 200
configure wave -valuecolwidth 120
# update
