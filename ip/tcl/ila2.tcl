set modName "ila2"
set ipDir "../ip"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {8192} \
  CONFIG.C_NUM_OF_PROBES {12} \
  CONFIG.C_PROBE0_WIDTH {3} \
  CONFIG.C_PROBE1_WIDTH {1} \
  CONFIG.C_PROBE2_WIDTH {1} \
  CONFIG.C_PROBE3_WIDTH {1} \
  CONFIG.C_PROBE4_WIDTH {3} \
  CONFIG.C_PROBE5_WIDTH {8} \
  CONFIG.C_PROBE6_WIDTH {8} \
  CONFIG.C_PROBE7_WIDTH {8} \
  CONFIG.C_PROBE8_WIDTH {8} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
