vsim -gui work.Control_Unit
add wave -position end  sim:/Control_Unit/clk
add wave -position end  sim:/Control_Unit/Rst
add wave -position end  sim:/Control_Unit/SFD
add wave -position end  sim:/Control_Unit/SRD
add wave -position end  sim:/Control_Unit/SFA
add wave -position end  sim:/Control_Unit/SW
add wave -position end  sim:/Control_Unit/ST
add wave -position end  sim:/Control_Unit/display
add wave -position end  sim:/Control_Unit/fdoor
add wave -position end  sim:/Control_Unit/rdoor
add wave -position end  sim:/Control_Unit/winbuzz
add wave -position end  sim:/Control_Unit/alarambuzz
add wave -position end  sim:/Control_Unit/heater
add wave -position end  sim:/Control_Unit/cooler
force -freeze sim:/Control_Unit/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/Control_Unit/Rst 1 0
force -freeze sim:/Control_Unit/ST 0111100 0
force -freeze sim:/Control_Unit/SFA 0 0
force -freeze sim:/Control_Unit/SFD 0 0
force -freeze sim:/Control_Unit/SRD 0 0
force -freeze sim:/Control_Unit/SW 0 0
run
force -freeze sim:/Control_Unit/Rst 0 0
run
force -freeze sim:/Control_Unit/SFA 1 0
run
run
force -freeze sim:/Control_Unit/SFD 1 0
run
run
run
run
force -freeze sim:/Control_Unit/SRD 1 0
force -freeze sim:/Control_Unit/SW 1 0
run
run
run
run
run

force -freeze sim:/Control_Unit/ST 1000110 0
run
run
run
run
run


force -freeze sim:/Control_Unit/ST 1000111 0
run
run
run
run

force -freeze sim:/Control_Unit/ST 0110001 0
run
run
run
run

