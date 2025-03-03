set ipDir "../ip"
set modName "mmcm_clk_wiz"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {102.086} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
  CONFIG.CLK_OUT1_PORT {clk_200} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} \
  CONFIG.USE_RESET {false} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
