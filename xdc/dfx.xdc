#--------------------------------------------------------------------------------------------------
# X0Y1
create_pblock pblock_X0Y1
resize_pblock pblock_X0Y1 -add CLOCKREGION_X1Y1:CLOCKREGION_X0Y1
add_cells_to_pblock pblock_X0Y1 [get_cells [list axil_reg32_A_inst]] -clear_locs

#create_pblock pblock_regA
#resize_pblock pblock_regA -add {SLICE_X0Y60:SLICE_X14Y119 BUFG_PS_X0Y24:BUFG_PS_X0Y47 DSP48E2_X0Y24:DSP48E2_X0Y47 RAMB18_X0Y24:RAMB18_X1Y47 RAMB36_X0Y12:RAMB36_X1Y23}
#add_cells_to_pblock pblock_regA [get_cells [list axil_reg32_A_inst]] -clear_locs

#create_pblock pblock_reg0
#resize_pblock pblock_reg0 -add {SLICE_X15Y60:SLICE_X28Y119 DSP48E2_X1Y24:DSP48E2_X2Y47 RAMB18_X2Y24:RAMB18_X2Y47 RAMB36_X2Y12:RAMB36_X2Y23}
#add_cells_to_pblock pblock_reg0 [get_cells [list top_bd_wrapper_inst/top_bd_i/axil_reg32_0]] -clear_locs

#--------------------------------------------------------------------------------------------------
# X1Y1
create_pblock pblock_X1Y1
resize_pblock pblock_X1Y1 -add CLOCKREGION_X1Y1:CLOCKREGION_X1Y1
add_cells_to_pblock pblock_X1Y1 [get_cells [list top_bd_wrapper_inst/top_bd_i/axil_reg32_0]] -clear_locs

#--------------------------------------------------------------------------------------------------
# X0Y0
create_pblock pblock_X0Y0
resize_pblock pblock_X0Y0 -add CLOCKREGION_X0Y0:CLOCKREGION_X0Y0
add_cells_to_pblock pblock_X0Y0 [get_cells [list top_bd_wrapper_inst/top_bd_i/led_cnt_wrapper_0]] -clear_locs
add_cells_to_pblock pblock_X0Y0 [get_cells [list led_cnt_inst]] -clear_locs


