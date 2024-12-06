
if {![file exists modelsim.ini]} {vmap -c }

vmap unisim       /mnt/Misc_512/xil_lib/2023.2/unisim
vmap secureip     /mnt/Misc_512/xil_lib/2023.2/secureip
vmap simprims_ver /mnt/Misc_512/xil_lib/2023.2/simprims_ver

do 1_fir_run.do


