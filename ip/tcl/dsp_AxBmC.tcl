set ipDir "../ip"
set modName "dsp_macro_AxBmC"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name dsp_macro -vendor xilinx.com -library ip -version 1.0 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.a_binarywidth {0} \
  CONFIG.a_width {18} \
  CONFIG.areg_3 {true} \
  CONFIG.areg_4 {true} \
  CONFIG.b_binarywidth {0} \
  CONFIG.b_width {18} \
  CONFIG.breg_3 {true} \
  CONFIG.breg_4 {true} \
  CONFIG.c_binarywidth {0} \
  CONFIG.c_width {48} \
  CONFIG.concat_binarywidth {0} \
  CONFIG.concat_width {48} \
  CONFIG.creg_3 {true} \
  CONFIG.creg_4 {true} \
  CONFIG.creg_5 {true} \
  CONFIG.d_width {18} \
  CONFIG.instruction1 {A*B-C} \
  CONFIG.mreg_5 {true} \
  CONFIG.p_full_width {48} \
  CONFIG.p_width {48} \
  CONFIG.pcin_binarywidth {0} \
  CONFIG.preg_6 {true} \
  CONFIG.has_ce {true} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
