
if {![file exists modelsim.ini]} {vmap -c }

#vlib work 
#vmap work work
#vlog  ../hdl/spi.sv       -sv -work work
#vlog  ../hdl/tb/spi_tb.sv -sv -work work
#vsim  -vopt work.spi_tb -voptargs=+acc
#log -r /*
#run 100us

do spi_run.do
