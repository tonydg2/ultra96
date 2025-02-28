if {![file exists modelsim.ini]} {vmap -c }

rm -rf work

#vcom  ../hdl/common/2008/led_cnt_vhd08.vhd  -2008 -work work
#vlog  ../hdl/common/led_cnt.sv  -sv -work work
#vlog  ../hdl/tb/led_cnt_tb.sv   -sv -work work

vlog  ../hdl/top/real_to_iq.sv    -sv -work work
vlog  ../hdl/top/iq_to_real.sv    -sv -work work
vlog  ../hdl/top/msk_modulator.sv -sv -work work
vlog  ../hdl/top/msk_demodulator.sv -sv -work work
vlog  ../hdl/tb/msk_tb.sv         -sv -work work

#vsim  -vopt work.msk_tb -voptargs=+acc

# ps resolution
vsim  -vopt work.msk_tb -voptargs=+acc -t ps
#vsim  -vopt work.msk_tb -voptargs=+acc -t fs

log -r /*

if {[file exists wave.do]} {do wave.do}

run 5us