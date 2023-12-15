### This is a sample RUN TCL file to control the stages of the digital ASIC BE flow
### We are using RTL Compiler (synthesis) and Encounter (PaR) from the the Cadence Inc.
### The current technology is XFAB 180nm

### For current flow the following assumptions are expected:
### - set all USER settings;
### - check that netlist and exported synthesis SDC are exisits with consistent names;
### - open the terminal
### - cd to the main folder with the scripts, src, reports etc. (BE_ASIC_DESIGN_CADENCE_SCRIPTS folder) and then cd to the ./WORK_TMP_FOLDER
### - run Place-and-Route with Encounter by typing in the same terminal "Encounter ../scripts/scripts_PaR/RUN_PAR.tcl"



### ================= USER SETTINGS =================
set NETLIST_TOP_NAME "PWM_syn_netlist.v";                       # RTL top module name
set NETLIST_PATH "../results/results_syn";                       # RTL path to the source files

set PAR_SDC_TOP_NAME "PWM_syn.sdc";                             # SDC top file name
set PAR_SDC_PATH "../results/results_syn";                       # SDC path to the sources

set PAR_MMMC_FILE "../scripts/scripts_aux/XFAB180_MMMC.tcl";                        # Multi-mode multi-corner file
set PAR_NETLIST_TOP_PORT_FILE "../scripts/scripts_aux/PaR_NETLIST_TOP_PORT_FILE";   # Synthesis corner (typ by default)

set PAR_INIT_LEF_FILESET "/Cadence/Libs/X_FAB/XKIT/xt018/cadence/v7_0/techLEF/v7_0_1_1/xt018_xx43_MET4_METMID_METTHK.lef \
                          /Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/LEF/v4_0_0/xt018_D_CELLS_HD.lef \
                          /Cadence/Libs/X_FAB/XKIT/xt018/diglibs/D_CELLS_HD/v4_0/LEF/v4_0_0/xt018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef";

set PAR_REPORTS_FOLDER "../reports/reports_PaR";                 # Reports folder
set PAR_RESULTS_FOLDER "../results/results_PaR";                 # Results folder

set FLOORPLAN_DIMENSIONS {200 200};    # FP chip area
set FLOORPLAN_MARGINS    {50 50 50 50};  #FP chip margins
### ================= END of USER SETTINGS =============



### ================== PROC to run PaR =================
### Set TRUE/FALSE and re-source RUN_PAR.tcl again in the interactive Encounter TCL shell
set PaR_INIT  "TRUE";
set PaR_FP    "TRUE";
set PaR_PWR   "TRUE";
set PaR_PLACE "TRUE";
set PaR_CTS   "TRUE";
set PaR_ROUTE "TRUE";
set PaR_FINAL "TRUE";
set PaR_OUT   "TRUE";
### ============== END of PROC to run PaR ==============

source ../scripts/scripts_PaR/FLOW_PAR.tcl;                    # Source PaR steps from the user TCL file

