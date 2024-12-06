rm -rf work

#vlog  ../hdl/spi.sv      -sv   -work work +define+SIMULATION
vlog  ../hdl/spi.sv       -sv   -work work
vlog  ../hdl/spi2.sv      -sv   -work work
vcom  ../hdl/spi3.vhd     -2008 -work work
vcom  ../hdl/spi4.vhd     -2008 -work work
vlog  ../hdl/tb/spi_tb.sv -sv   -work work

restart

log -r *

#run 100us
run 5.5 us
