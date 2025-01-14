rm -rf work
vcom  ../hdl/common/2008/led_cnt_vhd08.vhd  -2008 -work work
vlog  ../hdl/tb/led_cnt_tb.sv -sv -work work

restart

log -r *

run 10us