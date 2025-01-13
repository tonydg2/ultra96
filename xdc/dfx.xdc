#--------------------------------------------------------------------------------------------------
#  # X0Y1
#  create_pblock pblock_X0Y1
#  resize_pblock pblock_X0Y1 -add CLOCKREGION_X1Y1:CLOCKREGION_X0Y1
#  add_cells_to_pblock pblock_X0Y1 [get_cells [list axil_reg32_A_inst]] -clear_locs

#create_pblock pblock_regA
#resize_pblock pblock_regA -add {SLICE_X0Y60:SLICE_X14Y119 BUFG_PS_X0Y24:BUFG_PS_X0Y47 DSP48E2_X0Y24:DSP48E2_X0Y47 RAMB18_X0Y24:RAMB18_X1Y47 RAMB36_X0Y12:RAMB36_X1Y23}
#add_cells_to_pblock pblock_regA [get_cells [list axil_reg32_A_inst]] -clear_locs

#create_pblock pblock_reg0
#resize_pblock pblock_reg0 -add {SLICE_X15Y60:SLICE_X28Y119 DSP48E2_X1Y24:DSP48E2_X2Y47 RAMB18_X2Y24:RAMB18_X2Y47 RAMB36_X2Y12:RAMB36_X2Y23}
#add_cells_to_pblock pblock_reg0 [get_cells [list top_bd_wrapper_inst/top_bd_i/axil_reg32_0]] -clear_locs

#--------------------------------------------------------------------------------------------------
#  # X1Y1
#  create_pblock pblock_X1Y1
#  resize_pblock pblock_X1Y1 -add CLOCKREGION_X1Y1:CLOCKREGION_X1Y1
#  add_cells_to_pblock pblock_X1Y1 [get_cells [list top_bd_wrapper_inst/top_bd_i/axil_reg32_0]] -clear_locs

#--------------------------------------------------------------------------------------------------
#  # X0Y0
#  create_pblock pblock_X0Y0
#  resize_pblock pblock_X0Y0 -add CLOCKREGION_X0Y0:CLOCKREGION_X0Y0
#  add_cells_to_pblock pblock_X0Y0 [get_cells [list top_bd_wrapper_inst/top_bd_i/led_cnt_wrapper_0]] -clear_locs
#  #add_cells_to_pblock pblock_X0Y0 [get_cells [list led_cnt_inst]] -clear_locs

#--------------------------------------------------------------------------------------------------
create_pblock led_cnt_pr
#resize_pblock pblock_x1y0 -add {SLICE_X29Y0:SLICE_X48Y59 DSP48E2_X3Y0:DSP48E2_X4Y23 RAMB18_X3Y0:RAMB18_X5Y23 RAMB36_X3Y0:RAMB36_X5Y11}
#resize_pblock pblock_x1y0 -add {SLICE_X32Y0:SLICE_X48Y56 DSP48E2_X3Y0:DSP48E2_X4Y21 RAMB18_X3Y0:RAMB18_X5Y21 RAMB36_X3Y0:RAMB36_X5Y10}
resize_pblock led_cnt_pr -add {SLICE_X36Y30:SLICE_X42Y43 DSP48E2_X3Y12:DSP48E2_X3Y15}
add_cells_to_pblock led_cnt_pr [get_cells [list led_cnt_pr_inst]] -clear_locs

#--------------------------------------------------------------------------------------------------
create_pblock led_cnt2_pr
resize_pblock led_cnt2_pr -add {SLICE_X1Y122:SLICE_X25Y153 DSP48E2_X0Y50:DSP48E2_X1Y59 RAMB18_X0Y50:RAMB18_X2Y59 RAMB36_X0Y25:RAMB36_X2Y29}
add_cells_to_pblock led_cnt2_pr [get_cells [list led_cnt2_pr_inst]] -clear_locs

#--------------------------------------------------------------------------------------------------
create_pblock led_cnt3_pr
resize_pblock led_cnt3_pr -add {SLICE_X31Y120:SLICE_X48Y157 CFGIO_SITE_X0Y0:CFGIO_SITE_X0Y0 DSP48E2_X3Y48:DSP48E2_X4Y61 RAMB18_X3Y48:RAMB18_X5Y61 RAMB36_X3Y24:RAMB36_X5Y30}
add_cells_to_pblock led_cnt3_pr [get_cells [list led_cnt3_pr_inst]] -clear_locs

#--------------------------------------------------------------------------------------------------
#  # X0Y1
#  create_pblock pblock_X0Y1
#  resize_pblock pblock_X0Y1 -add CLOCKREGION_X1Y1:CLOCKREGION_X0Y1
#  add_cells_to_pblock pblock_X0Y1 [get_cells [list axil_reg32_A_inst]] -clear_locs

#--------------------------------------------------------------------------------------------------
create_pblock axil_reg32_2
resize_pblock axil_reg32_2 -add {SLICE_X0Y61:SLICE_X27Y89 DSP48E2_X0Y26:DSP48E2_X1Y35 RAMB18_X0Y26:RAMB18_X2Y35 RAMB36_X0Y13:RAMB36_X2Y17}
add_cells_to_pblock axil_reg32_2 [get_cells [list axil_reg32_2_inst]]

#--------------------------------------------------------------------------------------------------
