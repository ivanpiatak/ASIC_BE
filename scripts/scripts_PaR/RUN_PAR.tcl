### This is a sample RUN TCL file to control the stages of the digital ASIC BE flow
### We are using RTL Compiler (synthesis) and Encounter (PaR) from the the Cadence Inc.
### The current technology is XFAB 180nm

### For current flow the following assumptions are expected:
### - set all USER settings;
### - check that netlist and exported synthesis SDC are exisits with consistent names;
### - open the terminal
### - cd to the main folder with the scripts, src, reports etc. (BE_ASIC_DESIGN_CADENCE_SCRIPTS folder)
### - run Place-and-Route with Encounter by typing in the same terminal "Encounter ./RUN_PAR.tcl"



### ================= USER SETTINGS =================
set NETLIST_TOP_NAME "PWM_syn_netlist.v";                       # RTL top module name
set NETLIST_PATH "./results/results_syn";                       # RTL path to the source files

set PAR_SDC_TOP_NAME "PWM_syn.sdc";                             # SDC top file name
set PAR_SDC_PATH "./results/results_syn";                       # SDC path to the sources

set PAR_MMMC_FILE "./scripts/scripts_aux/XFAB180_typ.tcl";                         # Multi-mode multi-corner file
set PAR_NETLIST_TOP_PORT_FILE "./scripts/scripts_aux/PaR_NETLIST_TOP_PORT_FILE";   # Synthesis corner (typ by default)

set PAR_INIT_LEF_FILESET "/Cadence/Libs/X_FAB/XKIT/xt018/cadence/v7_0/techLEF/v7_0_1_1/xt018_xx43_MET4_METMID_METTHK.lef \
                          /Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/LEF/v4_0_0/xt018_D_CELLS_HD.lef \
                          /Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/LEF/v4_0_0/xt018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef";

set PAR_REPORTS_FOLDER "./reports/reports_par";                 # Reports folder
set PAR_RESULTS_FOLDER "./results/results_par";                 # Results folder

set FLOORPLAN_DIMENSIONS "2000 2000";    # FP chip area
set FLOORPLAN_MARGINS    "50 50 50 50";  # FP chip margins
### ================= END of USER SETTINGS =============



### ================= INITIAL SETTINGS =================
win
set init_pwr_net VDD                                          # Define supply VDD net 
set init_gnd_net VSS                                          # Define supply VSS net
set init_lef_file ${PAR_INIT_LEF_FILESET}                     # Physical libraries - LEF fileset from XFAB 180nm
set init_design_settop 0

set init_verilog ${NETLIST_PATH}/${NETLIST_TOP_NAME}          # SYN netlist file
set init_mmmc_file ${PAR_MMMC_FILE}                           # Techmological file for multi-mode multi-corner PaR
set init_io_file ${PAR_NETLIST_TOP_PORT_FILE}                 # File with location of the TOP level ports on the floorplan
 
init_design
fit
### ================= END of INITIAL SETTINGS  =========



### ================= FLOORPLANNING ====================
floorPlan -site core_hd -s ${FLOORPLAN_DIMENSIONS} ${FLOORPLAN_MARGINS}
floorPlan -coreMarginsBy die -site core_hd -s ${FLOORPLAN_DIMENSIONS} ${FLOORPLAN_MARGINS}
fit
### ================= END of FLOORPLANNING  ============



### ================= POWER DELIVERY SYSTEM ====================
#GLOBAL CONNECTIONS
clearGlobalNets
globalNetConnect VDD -type pgpin -pin vdd -inst * -module {}
globalNetConnect VSS -type pgpin -pin gnd -inst * -module {}
globalNetConnect VDD -type tiehi -pin vdd -inst * -module {}
globalNetConnect VSS -type tielo -pin gnd -inst * -module {}
# POWER RING
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -stacked_via_top_layer METTPL -type core_rings -jog_distance 3.15 -threshold 3.15 -nets {VDD VSS} -follow core -stacked_via_bottom_layer MET1 -layer {bottom MET1 top MET1 right MET2 left MET2} -width 15 -spacing 0.6 -offset 3.15 
# POWER STRAPS
addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit MET3 -max_same_layer_jog_length 6 -padcore_ring_bottom_layer_limit MET1 -set_to_set_distance 1000 -skip_via_on_pin Standardcell -stacked_via_top_layer METTPL -padcore_ring_top_layer_limit MET3 -spacing 5 -merge_stripes_value 3.15 -layer MET2 -block_ring_bottom_layer_limit MET1 -width 20 -nets {VSS VDD} -stacked_via_bottom_layer MET1	
# REMOVE UNUNSED
selectWire 39.6900 6.5100 59.6900 5073.6900 2 VSS #TODO
deleteSelectedFromFPlan #TODO
selectWire 64.6900 22.1100 84.6900 5058.0900 2 VDD #TODO
deleteSelectedFromFPlan #TODO
# MAKE A PG CONNECTIONS
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { MET1 METTPL } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { MET1 METTPL } -allowLayerChange 1 -nets { VDD VSS } -blockPin useLef -targetViaLayerRange { MET1 METTPL }
editPowerVia -skip_via_on_pin Standardcell -bottom_layer MET1 -add_vias 1 -top_layer METTPL


# AFTER-STAGE STA
timeDesign -prePlace -idealClock -pathReports -drvReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_FP_PG_SETUP -outDir ${PAR_REPORTS_FOLDER}   # SETUP STA
suspend
### ================= END of POWER DELIVERY SYSTEM  ============



### ================= PLACEMENT ====================
# GENERAL SETTINGS - CPU num etc.
setMultiCpuUsage -localCpu 8 -cpuPerRemoteHost 1 -remoteHost 0 -keepLicense true 
setDistributeHost -local
setPlaceMode -fp false
### PLACE
placeDesign -inPlaceOpt 


# POST-PLACE STA
timeDesign -preCTS -idealClock -pathReports -drvReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_PLACE_SETUP -outDir ${PAR_REPORTS_FOLDER}   # SETUP STA
timeDesign -preCTS -hold -idealClock -pathReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_PLACE_HOLD        -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend

# OPTIMIZATION
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS		

# POST-OPTIMIZATION STA
timeDesign -preCTS -hold -idealClock -pathReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_PLACE_HOLD_OPT -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend
### ================= END of PLACEMENT =============



### ================= CTS ====================
# BUFFER SORTING
createClockTreeSpec -bufferList {BUHDX0 BUHDX1 BUHDX12 BUHDX2 BUHDX3 BUHDX4 BUHDX6 BUHDX8 DLY1HDX0 DLY1HDX1 DLY2HDX0 DLY2HDX1 DLY4HDX0 DLY4HDX1 DLY8HDX0 DLY8HDX1 INHDX0 INHDX1 INHDX12 INHDX2 INHDX3 INHDX4 INHDX6 INHDX8 STEHDX0 STEHDX1 STEHDX2 STEHDX4} -file Clock.ctstch		
# CTS
setCTSMode -engine ck
clockDesign -specFile Clock.ctstch -outDir ${PAR_REPORTS_FOLDER} -fixedInstBeforeCTS
# POST-CTS STA
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_CTS_SETUP -outDir ${PAR_REPORTS_FOLDER}   # SETUP STA
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_CTS_HOLD        -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend

### OPTIMIZATION
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS				
optDesign -postCTS -hold
# POST-OPT STA	
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_CTS_HOLD_OPT -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend

# INCREMENTAL OPT
optDesign -postCTS -hold -incr	
# POST-INCR STA	
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix ${NETLIST_TOP_NAME}_CTS_HOLD_INCR_OPT -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend
### ================= END of CTS =============



### ================= ROUTE ====================
# GENERAL SETTINGS
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
# ANTENNA VILOATION FIX - BRIDGE
setNanoRouteMode -quiet -drouteFixAntenna true
# ANTENNA VILOATION FIX - DIODES
setNanoRouteMode -quiet -routeInsertAntennaDiode true

# ROUTE
routeDesign -globalDetail

# POST-ROUTE STA	
setAnalysisMode -analysisType onChipVariation -skew true -clockPropagation sdcControl
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix  ${NETLIST_TOP_NAME}_ROUTE_SETUP -outDir ${PAR_REPORTS_FOLDER}   # SETUP STA
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix  ${NETLIST_TOP_NAME}_ROUTE_HOLD        -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend

# OPTIMIZATION
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postRoute				
optDesign -postRoute -hold
# POST-OPT STA			
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix  ${NETLIST_TOP_NAME}_ROUTE_HOLD_OPT    -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend

# INCREMENTAL OPT
optDesign -postRoute -incr				
optDesign -postRoute -hold -incr
# POST-INCR STA	
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix  ${NETLIST_TOP_NAME}_ROUTE_HOLD_INCR_OPT -outDir ${PAR_REPORTS_FOLDER}   # HOLD STA
suspend
### ================= END of ROUTE ====================



### ================= FINALIZATION ====================
# FILLER CELLS
getFillerMode -quiet
addFiller -cell FEED7HD FEED5HD FEED3HD FEED2HD FEED25HD FEED1HD FEED15HD FEED10HD -prefix FILLER
suspend

# CHECK SIMPLE DRC
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg true -diffCellViol false -sameCellViol true -padFillerCellsOverlap false -routingBlkgPinOverlap false -routingCellBlkgOverlap false -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
verify_drc -report ${PAR_REPORTS_FOLDER}/${NETLIST_TOP_NAME}_DRC.rpt -limit 1000
verifyConnectivity -type all -error 1000 -warning 50

# EXTRACT RC
setExtractRCMode -engine postRoute -effortLevel signoff
extractRC	
### ================= END of FINALIZATION ====================



### ================= OUTPUT ====================
# STA
timeDesign -signoff -pathReports -drvReports -slackReports -numPaths 50 -prefix  ${NETLIST_TOP_NAME}_SIGNOFF_SETUP -outDir ${PAR_REPORTS_FOLDER}   # "-signoff" SETUP STA
timeDesign -signoff -hold -pathReports -slackReports -numPaths 50       -prefix  ${NETLIST_TOP_NAME}_SIGNOFF_HOLD  -outDir ${PAR_REPORTS_FOLDER}   # "-signoff" HOLD STA

all_hold_analysis_views 
all_setup_analysis_views 

# EXPORT RESULTS of the PaR stage
write_sdf -view TYPview ${PAR_RESULTS_FOLDER}/${NETLIST_TOP_NAME}.sdf
saveNetlist ${PAR_RESULTS_FOLDER} -includePhysicalCell {FEED7HD FEED10HD FEED15HD FEED1HD FEED25HD FEED2HD FEED3HD FEED5HD}
defOut -floorplan -netlist -routing ${PAR_RESULTS_FOLDER}/${NETLIST_TOP_NAME}.def
### ================= END of OUTPUT ====================
