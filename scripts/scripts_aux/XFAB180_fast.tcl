### Technology:			"X-FAB 180 nm CMOS, XT018 1243"
### Library:			"D_CELLS_HD, 1.8V"
### Tools:			"Cadence RTL Compiler"
###
### Stage:			"Synthesis"
### File description:		"Contains paths to the library of digital cells (slow corner)"


# Setup path for liberty CPF directory
set_attribute lib_search_path /Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/liberty_LP5MOS/v4_0_0/PVT_1_80V_range

# Setup PVT corner .lib file
set_attribute library {/Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/liberty_LP5MOS/v4_0_0/PVT_1_80V_range/D_CELLS_HD_LP5MOS_fast_1_98V_m40C.lib}

# Setup LEF files
set_attribute lef_library { \
/Cadence/Libs/X_FAB/XKIT/xt018/cadence/v7_0/techLEF/v7_0_1_1/xt018_xx43_MET4_METMID_METTHK.lef \ 
/Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/LEF/v4_0_0/xt018_D_CELLS_HD.lef \
/Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/LEF/v4_0_0/xt018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef \
}

# Setup capacitance table file
set_attribute cap_table_file /Cadence/Libs/X_FAB/XKIT/xt018/cadence/v7_0/capTbl/v7_0_1/xt018_xx43_MET4_METMID_METTHK_fast.capTbl

# Setup error on blackbox
set_attribute hdl_error_on_blackbox true
