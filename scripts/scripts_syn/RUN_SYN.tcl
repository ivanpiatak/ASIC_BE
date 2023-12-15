### This is a sample RUN TCL file to control the stages of the digital ASIC BE flow
### We are using RTL Compiler (synthesis) and Encounter (PaR) from the the Cadence Inc.
### The current technology is XFAB 180nm

### For current flow the following assumptions are expected:
### - set all USER settings;
### - create requred SDC file with the same name as your RTL top (e.g. RTL_TOP_MODULE.sdc)
### - open the terminal
### - cd to the main folder with the scripts, src, reports etc. (BE_ASIC_DESIGN_CADENCE_SCRIPTS folder) and then cd to the ./WORK_TMP_FOLDER
### - run synthesis with RTL Compiler by typing in the same terminal "RTL_Compiler ../scripts/scripts_syn/RUN_SYN.tcl"



### ================= USER SETTINGS =================
set RTL_TOP_NAME "PWM";                                         # RTL top module name
set RTL_PATH "../src/rtl";                                       # RTL path to the source files

set RTL_FILELIST_NAME "filelist.v";                            # RTL path to the filelist for synthesis

set SYN_SDC_TOP_NAME "${RTL_TOP_NAME}.sdc";                       # SDC top file name
set SYN_SDC_PATH "../src/sdc";                                   # SDC path to the sources

set SYN_CORNER "../scripts/scripts_aux/XFAB180_typ.tcl";         # Synthesis corner (typ by default)

set SYN_REPORTS_FOLDER "../reports/reports_syn";                 # Reports folder
set SYN_RESULTS_FOLDER "../results/results_syn";                 # Results folder
### ================= END of USER SETTINGS ==========



### ================= SYNTHESIS =================
# Source desired corner technology file for synthesis
include ${SYN_CORNER}

# Read in Verilog HDL filelist for synthesis
read_hdl -v2001 ${RTL_PATH}/${RTL_FILELIST_NAME}

# Synthesize (elabirate, no mapping)
elaborate ${RTL_TOP_NAME}

# Rear SDC constraints
read_sdc ${SYN_SDC_PATH}/${SYN_SDC_TOP_NAME}

# Synthesize (technology mapped)
synthesize -to_mapped
synthesize -incremental

# Generate area and timing reports
report timing                > ${SYN_REPORTS_FOLDER}/${RTL_TOP_NAME}_syn_timing_report.rpt
report area                  > ${SYN_REPORTS_FOLDER}/${RTL_TOP_NAME}_syn_area_report.rpt
report_timing -lint -verbose > ${SYN_REPORTS_FOLDER}/${RTL_TOP_NAME}_syn_timing_problems.rpt

# Export synthesized and mapped Verilog netlist - result of the synthesis
write_hdl -mapped > ${SYN_RESULTS_FOLDER}/${RTL_TOP_NAME}_syn_netlist.v

# Export SDC file for the next PaR stages
write_sdc > ${SYN_RESULTS_FOLDER}/${RTL_TOP_NAME}_syn.sdc

# Open RTL Compiler GUI
gui_show

### ================= END of SYNTHESIS ==========

