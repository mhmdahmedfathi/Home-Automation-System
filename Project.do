vsim -gui work.control_unit
add wave -position end  sim:/control_unit/clk
add wave -position end  sim:/control_unit/Rst
add wave -position end  sim:/control_unit/SFD
add wave -position end  sim:/control_unit/SRD
add wave -position end  sim:/control_unit/SFA
add wave -position end  sim:/control_unit/SW
add wave -position end  sim:/control_unit/ST
add wave -position end  sim:/control_unit/display
add wave -position end  sim:/control_unit/fdoor
add wave -position end  sim:/control_unit/rdoor
add wave -position end  sim:/control_unit/winbuzz
add wave -position end  sim:/control_unit/alarambuzz
add wave -position end  sim:/control_unit/heater
add wave -position end  sim:/control_unit/cooler
force -freeze sim:/control_unit/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/control_unit/Rst 0 0
force -freeze sim:/control_unit/ST 0111100 0
force -freeze sim:/control_unit/SFA 0 0
force -freeze sim:/control_unit/SFD 0 0
force -freeze sim:/control_unit/SRD 0 0
force -freeze sim:/control_unit/SW 0 0
run
run
run
force -freeze sim:/control_unit/SFA 1 0
run
run
force -freeze sim:/control_unit/SFD 1 0
run
run
run
run
force -freeze sim:/control_unit/SRD 1 0
force -freeze sim:/control_unit/SW 1 0
run
run
run
run
run

force -freeze sim:/control_unit/ST 1000110 0
run
run
run
run
run


force -freeze sim:/control_unit/ST 1000111 0
run
run
run
run

force -freeze sim:/control_unit/ST 0110001 0
run
run
run
run

