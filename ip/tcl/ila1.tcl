set ipDir "../ip"
set modName "ila1"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {2048} \
  CONFIG.C_NUM_OF_PROBES {4} \
  CONFIG.C_PROBE0_WIDTH {1} \
  CONFIG.C_PROBE1_WIDTH {1} \
  CONFIG.C_PROBE2_WIDTH {1} \
  CONFIG.C_PROBE3_WIDTH {1} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}