rm -rf work
vlog  ../hdl/real_to_iq.sv          -sv -work work
vlog  ../hdl/iq_to_real.sv          -sv -work work
vlog  ../hdl/mdl/msk_modulator.sv   -sv -work work
vlog  ../hdl/mdl/msk_demodulator.sv -sv -work work
vlog  ../hdl/tb/msk_tb.sv           -sv -work work

restart

log -r *

run 40us