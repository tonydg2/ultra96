rm -rf work
#vlog  ../hdl/spi.sv       -sv -work work +define+SIMULATION
vlog  ../hdl/spi.sv       -sv -work work
vlog  ../hdl/tb/spi_tb.sv -sv -work work

restart

log -r *

#run 100us
run 1.5 us
