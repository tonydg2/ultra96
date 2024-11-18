rm -rf work

#vlog  ../hdl/spi.sv       -sv -work work +define+SIMULATION
vlog  ../hdl/spi.sv       -sv -work work
vlog  ../hdl/tb/spi_tb.sv -sv -work work

vsim  -vopt work.spi_tb -voptargs=+acc

log -r /*

if {[file exists wave.do]} {do wave.do}

#run 100us
run 1000ns
