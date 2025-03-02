set ipDir "../ip"
set modName "dds_50"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name dds_compiler -vendor xilinx.com -library ip -version 6.0 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.Amplitude_Mode {Full_Range} \
  CONFIG.DATA_Has_TLAST {Not_Required} \
  CONFIG.DDS_Clock_Rate {200} \
  CONFIG.Frequency_Resolution {1} \
  CONFIG.Has_Phase_Out {false} \
  CONFIG.Latency {3} \
  CONFIG.M_DATA_Has_TUSER {Not_Required} \
  CONFIG.Noise_Shaping {Auto} \
  CONFIG.Output_Frequency1 {50} \
  CONFIG.Output_Width {8} \
  CONFIG.PINC1 {100000000000000000000000000} \
  CONFIG.Parameter_Entry {System_Parameters} \
  CONFIG.PartsPresent {Phase_Generator_and_SIN_COS_LUT} \
  CONFIG.Phase_Increment {Fixed} \
  CONFIG.Phase_Width {28} \
  CONFIG.Phase_offset {None} \
  CONFIG.S_PHASE_Has_TUSER {Not_Required} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
