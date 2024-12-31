rm -rf work

vlog  ../hdl/common/video_tpg.sv  -sv   -work work
vlog  ../hdl/tb/video_tpg_tb.sv   -sv   -work work

restart

log -r *

run 5us