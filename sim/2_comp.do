rm -rf work
vlog  ../hdl/top/real_to_iq.sv    -sv -work work
vlog  ../hdl/top/iq_to_real.sv    -sv -work work
vlog  ../hdl/top/msk_modulator.sv -sv -work work
vlog  ../hdl/top/msk_demodulator.sv -sv -work work
vlog  ../hdl/tb/msk_tb.sv         -sv -work work

restart

log -r *

run 40us