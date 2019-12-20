add  wave  -noupdate -group  "DUT"    "dut/*"
add  wave  -noupdate  -expand  -group  "TB top" "*"

configure wave -namecolwidth 200
configure wave -valuecolwidth 120
# update
