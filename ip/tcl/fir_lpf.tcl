set ipDir "../ip"
set modName "fir_lpf"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name $modName -dir $ipDir -force
set_property -dict [list \
  CONFIG.CoefficientVector {-374 -579 -822 -908 -693 -74 969 2343 3849 5215 6171 6514 6171 5215 3849 2343 969 -74 -693 -908 -822 -579 -374} \
  CONFIG.Coefficient_Fractional_Bits {0} \
  CONFIG.Coefficient_Sets {1} \
  CONFIG.Coefficient_Sign {Signed} \
  CONFIG.Coefficient_Structure {Inferred} \
  CONFIG.Coefficient_Width {16} \
  CONFIG.Data_Width {16} \
  CONFIG.Output_Width {32} \
  CONFIG.Quantization {Integer_Coefficients} \
  CONFIG.S_DATA_Has_FIFO {false} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
