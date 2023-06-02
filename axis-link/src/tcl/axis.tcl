create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo
set_property -dict [list \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.Component_Name {axis_data_fifo} \
] [get_ips axis_data_fifo]

create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio
set_property -dict [list \
   CONFIG.C_NUM_PROBE_OUT {3} \
   CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
   CONFIG.C_NUM_PROBE_IN {0} \
] [get_ips vio]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_data_gen
set_property -dict [list \
   CONFIG.C_PROBE7_WIDTH {2} \
   CONFIG.C_PROBE6_WIDTH {4} \
   CONFIG.C_PROBE3_WIDTH {4} \
   CONFIG.C_PROBE2_WIDTH {32} \
   CONFIG.C_NUM_OF_PROBES {8} \
   CONFIG.Component_Name {ila_data_gen} \
] [get_ips ila_data_gen]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_data_recv
set_property -dict [list \
   CONFIG.C_PROBE7_WIDTH {2} \
   CONFIG.C_PROBE6_WIDTH {4} \
   CONFIG.C_PROBE3_WIDTH {4} \
   CONFIG.C_PROBE2_WIDTH {32} \
   CONFIG.C_NUM_OF_PROBES {8} \
   CONFIG.Component_Name {ila_data_gen} \
] [get_ips ila_data_recv]