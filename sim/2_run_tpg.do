rm -rf work

vlog  ../hdl/common/video_tpg.sv  -sv   -work work
vlog  ../hdl/tb/video_tpg_tb.sv   -sv   -work work

#vsim  -L crc_lib -vopt work.video_tpg_tb -voptargs=+acc
vsim  -vopt work.video_tpg_tb -voptargs=+acc

log -r /*

if {[file exists wave.do]} {do wave.do}

run 5us
