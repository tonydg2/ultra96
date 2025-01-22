if {![file exists modelsim.ini]} {vmap -c }

rm -rf work

#vcom  ../hdl/common/2008/led_cnt_vhd08.vhd  -2008 -work work
#vlog  ../hdl/common/led_cnt.sv  -sv -work work
#vlog  ../hdl/tb/led_cnt_tb.sv   -sv -work work

vlog  ../hdl/design.sv   -sv -work work
vlog  ../hdl/tb/testbench.sv   -sv -work work

vsim  -vopt work.top -voptargs=+acc

log -r /*

if {[file exists wave.do]} {do wave.do}

run 10us