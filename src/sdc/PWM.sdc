### Stage:				"Synthesis and PaR"
### File description:			"Constraints for the design"


# SET LIB UNITS
set_units -time 1.0ns;
set_units -capacitance 1.0pF;

set_max_capacitance 0.5 [all_outputs]

### ====================== CLOCKS ===========================
# CLOCK and UNCERTAINTY
set CLK_NAME   "clk";
set CLK_PERIOD 40.0;
set CLK_UNCERT 0.2;

# CLK WAIVEFORM RISE-FALL TIMES
set MINRISE 0.20
set MAXRISE 0.25
set MINFALL 0.20
set MAXFALL 0.25

# IO DELAYS
set INPUT_DELAY_CLK       [expr ${CLK_PERIOD}/2.0]
set OUTPUT_DELAY_CLK      [expr ${CLK_PERIOD}/2.0]



create_clock -name ${CLK_NAME} -period ${CLK_PERIOD} -waveform "0 [expr ${CLK_PERIOD}/2]" [get_ports ${CLK_NAME}]
set_clock_uncertainty ${CLK_UNCERT} [get_clocks ${CLK_NAME}]

set_clock_transition -rise -min ${MINRISE} [get_clocks ${CLK_NAME}]
set_clock_transition -rise -max ${MAXRISE} [get_clocks ${CLK_NAME}]
set_clock_transition -fall -min ${MINFALL} [get_clocks ${CLK_NAME}]
set_clock_transition -fall -max ${MAXFALL} [get_clocks ${CLK_NAME}]



#set_input_delay  -clock "clk" -max ${INPUT_DELAY_CLK} [all_inputs]
#set_input_delay  -clock "clk" -min ${INPUT_DELAY_CLK} [all_inputs]

set_output_delay -clock "clk" -max ${OUTPUT_DELAY_CLK} [all_outputs]
set_output_delay -clock "clk" -min ${OUTPUT_DELAY_CLK} [all_outputs]



### ====================== RESETS ===========================
set RST_NAME "reset"
set_ideal_network    [get_ports ${RST_NAME}]

