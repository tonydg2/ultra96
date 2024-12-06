set modName "fir0"
set ipDir "../ip"
set coeFile "../../scripts_scratch/tapsXil.coe"

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name $modName -dir $ipDir -force

set_property -dict [list \
  CONFIG.Channel_Sequence {Basic} \
  CONFIG.Clock_Frequency {100.0} \
  CONFIG.CoefficientSource {COE_File} \
  CONFIG.Coefficient_Fanout {false} \
  CONFIG.Coefficient_File {$coeFile} \
  CONFIG.Coefficient_Fractional_Bits {0} \
  CONFIG.Coefficient_Sets {1} \
  CONFIG.Coefficient_Sign {Signed} \
  CONFIG.Coefficient_Structure {Inferred} \
  CONFIG.Coefficient_Width {32} \
  CONFIG.ColumnConfig {31} \
  CONFIG.Control_Broadcast_Fanout {false} \
  CONFIG.Control_Column_Fanout {false} \
  CONFIG.Control_LUT_Pipeline {false} \
  CONFIG.Control_Path_Fanout {false} \
  CONFIG.DATA_Has_TLAST {Not_Required} \
  CONFIG.Data_Path_Broadcast {false} \
  CONFIG.Data_Path_Fanout {false} \
  CONFIG.Data_Width {16} \
  CONFIG.Disable_Half_Band_Centre_Tap {false} \
  CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
  CONFIG.M_DATA_Has_TREADY {false} \
  CONFIG.M_DATA_Has_TUSER {Not_Required} \
  CONFIG.No_BRAM_Read_First_Mode {false} \
  CONFIG.No_SRL_Attributes {false} \
  CONFIG.Number_Channels {1} \
  CONFIG.Number_Paths {1} \
  CONFIG.Optimal_Column_Lengths {false} \
  CONFIG.Optimization_Goal {Area} \
  CONFIG.Optimization_List {None} \
  CONFIG.Optimization_Selection {None} \
  CONFIG.Other {false} \
  CONFIG.Output_Rounding_Mode {Full_Precision} \
  CONFIG.Output_Width {47} \
  CONFIG.Pre_Adder_Pipeline {false} \
  CONFIG.Quantization {Integer_Coefficients} \
  CONFIG.S_DATA_Has_TUSER {Not_Required} \
  CONFIG.Sample_Frequency {100} \
  CONFIG.Select_Pattern {All} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
