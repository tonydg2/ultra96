set ipDir "../ip"
set modName "blk_mem_gen"
set coeFile "../misc/behemothLogo_Region0.coe"
# /mnt/TDG_512/projects/1_dp/misc/behemothLogo_Region0.coe
# stupid vivado needs the stupid full path for the coe or it fails
# NONE of this works
set coeFileFull [file normalize $coeFile]

if {![file exists $ipDir]} {error "ip directory not present"}

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $modName -dir $ipDir
set_property -dict [list \
  CONFIG.Coe_File {/mnt/TDG_512/projects/1_dp/misc/behemothLogo_Region0.coe} \
  CONFIG.Fill_Remaining_Memory_Locations {true} \
  CONFIG.Load_Init_File {true} \
  CONFIG.Memory_Type {Single_Port_ROM} \
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
  CONFIG.Remaining_Memory_Locations {010101} \
  CONFIG.Write_Depth_A {111000} \
  CONFIG.Write_Width_A {24} \
] [get_ips $modName]

if {"-gen" in $argv} {generate_target all [get_files $modName.xci]}
