vsim -gui work.cu

add wave -position end  sim:/cu/Clk
add wave -position end  sim:/cu/Rst
add wave -position end  sim:/cu/SFD
add wave -position end  sim:/cu/SRD
add wave -position end  sim:/cu/SFA
add wave -position end  sim:/cu/SW
add wave -position end  sim:/cu/ST

add wave -position end  sim:/cu/fdoor
add wave -position end  sim:/cu/rdoor
add wave -position end  sim:/cu/winbuzz
add wave -position end  sim:/cu/alarambuzz
add wave -position end  sim:/cu/heater
add wave -position end  sim:/cu/cooler
add wave -position end  sim:/cu/display

force -freeze sim:/cu/Clk 1 0, 0 {50 ps} -r 100

force -freeze sim:/cu/Rst 1 0
force -freeze sim:/cu/ST 0111100 0
force -freeze sim:/cu/SFA 0 0
force -freeze sim:/cu/SFD 0 0
force -freeze sim:/cu/SRD 0 0
force -freeze sim:/cu/SW 0 0
run

force -freeze sim:/cu/Rst 0 0
run

force -freeze sim:/cu/SFA 1 0
run
run

force -freeze sim:/cu/SFD 1 0
run
run
run
run

force -freeze sim:/cu/SRD 1 0
force -freeze sim:/cu/SW 1 0
run
run
run
run
run

force -freeze sim:/cu/ST 1000110 0
run
run
run
run
run

force -freeze sim:/cu/ST 1000111 0
run
run
run
run

force -freeze sim:/cu/ST 0110001 0
run
run
run
run
run