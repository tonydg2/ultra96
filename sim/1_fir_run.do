rm -rf work xbip_utils_v3_0_11 fir_compiler_v7_2_20 axi_utils_v2_0_7

#vlog  ../hdl/spi.sv      -sv   -work work +define+SIMULATION

vlog  ../ip/fir0/fir0_sim_netlist.v   -work work
#vcom  ../ip/fir0/sim/fir0.vhd -work work

vcom  ../ip/fir0/hdl/xbip_utils_v3_0_vh_rfs.vhd   -work xbip_utils_v3_0_11
vcom  ../ip/fir0/hdl/axi_utils_v2_0_vh_rfs.vhd    -work axi_utils_v2_0_7
vcom  ../ip/fir0/hdl/fir_compiler_v7_2_vh_rfs.vhd -work fir_compiler_v7_2_20

vlog  ../hdl/tb/fir_tb.sv -sv         -work work

vsim  -vopt work.fir_tb -voptargs=+acc

log -r /*

if {[file exists wave.do]} {do wave.do}

#run 100us
run 5.5 us
