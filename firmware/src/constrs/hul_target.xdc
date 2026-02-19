#create_pblock pblock_1
#add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list u_Region1_Inst/u_MultiplexerOut1 u_Region1_Inst/u_Selector]]

#create_generated_clock -name G_TEST_INT -source [get_pins u_ClkMan_Trg_Inst/inst/mmcm_adv_inst/CLKIN1] -multiply_by 2 [get_pins u_ClkMan_Trg_Inst/inst/mmcm_adv_inst/CLKOUT2]
#create_generated_clock -name G_TEST_OUT4 -source [get_pins u_ClkMan_Trg_Inst/inst/mmcm_adv_inst/CLKIN1] -divide_by 5 [get_pins u_ClkMan_Trg_Inst/inst/mmcm_adv_inst/CLKOUT3]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]

