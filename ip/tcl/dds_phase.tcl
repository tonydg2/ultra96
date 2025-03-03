set ipDir "../ip"
set modName "dds_phase"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name dds_compiler -vendor xilinx.com -library ip -version 6.0 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.DATA_Has_TLAST {Not_Required} \
  CONFIG.DDS_Clock_Rate {200} \
  CONFIG.Frequency_Resolution {0.4} \
  CONFIG.Has_Phase_Out {false} \
  CONFIG.M_DATA_Has_TUSER {Not_Required} \
  CONFIG.Noise_Shaping {None} \
  CONFIG.Output_Frequency1 {0} \
  CONFIG.Output_Width {16} \
  CONFIG.PINC1 {0} \
  CONFIG.Parameter_Entry {Hardware_Parameters} \
  CONFIG.Phase_Increment {Streaming} \
  CONFIG.Phase_Width {32} \
  CONFIG.S_PHASE_Has_TUSER {Not_Required} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
