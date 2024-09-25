set ipDir "../ip"
set modName "dfx_axi_mgr"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name dfx_axi_shutdown_manager -vendor xilinx.com -library ip -version 1.0 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.CTRL_INTERFACE_TYPE {0} \
  CONFIG.DP_AXI_ADDR_WIDTH {7} \
  CONFIG.DP_AXI_RESP {2} \
  CONFIG.DP_PROTOCOL {AXI4LITE} \
  CONFIG.RP_IS_MASTER {false} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}

