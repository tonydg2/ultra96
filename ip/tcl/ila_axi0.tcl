set ipDir "../ip"
set modName "ila_axi0"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.C_MONITOR_TYPE {AXI} \
  CONFIG.C_SLOT_0_AXI_ADDR_WIDTH {32} \
  CONFIG.C_SLOT_0_AXI_ID_WIDTH {0} \
  CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4LITE} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}