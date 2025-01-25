set ipDir "../ip"
set modName "fifo_gen_dram_sync"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name $modName -dir $ipDir
set_property -dict [list \
  CONFIG.Almost_Full_Flag {true} \
  CONFIG.Dout_Reset_Value {010101} \
  CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
  CONFIG.Input_Data_Width {24} \
  CONFIG.Input_Depth {16} \
  CONFIG.Performance_Options {First_Word_Fall_Through} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
