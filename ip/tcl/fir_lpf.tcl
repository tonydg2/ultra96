set ipDir "../ip"
set modName "fir_lpf"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.CoefficientVector {-627 -1299 -1088 1129 5235 9393 11156 9393 5235 1129 -1088 -1299 -627} \
  CONFIG.Coefficient_Fractional_Bits {0} \
  CONFIG.Coefficient_Sets {1} \
  CONFIG.Coefficient_Sign {Signed} \
  CONFIG.Coefficient_Structure {Inferred} \
  CONFIG.Coefficient_Width {16} \
  CONFIG.Data_Width {16} \
  CONFIG.Output_Width {32} \
  CONFIG.Quantization {Integer_Coefficients} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
