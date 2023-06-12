# create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo
# set_property -dict [list \
#    CONFIG.TDATA_NUM_BYTES {4} \
#    CONFIG.HAS_TKEEP {1} \
#    CONFIG.HAS_TLAST {1} \
#    CONFIG.Component_Name {axis_data_fifo} \
# ] [get_ips axis_data_fifo]
# 
# create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio
# set_property -dict [list \
#    CONFIG.C_NUM_PROBE_OUT {3} \
#    CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
#    CONFIG.C_NUM_PROBE_IN {0} \
# ] [get_ips vio]
# 
# create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_data_gen
# set_property -dict [list \
#    CONFIG.C_PROBE7_WIDTH {2} \
#    CONFIG.C_PROBE6_WIDTH {4} \
#    CONFIG.C_PROBE3_WIDTH {4} \
#    CONFIG.C_PROBE2_WIDTH {32} \
#    CONFIG.C_NUM_OF_PROBES {8} \
#    CONFIG.Component_Name {ila_data_gen} \
# ] [get_ips ila_data_gen]
# 
# create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_data_recv
# set_property -dict [list \
#    CONFIG.C_PROBE7_WIDTH {2} \
#    CONFIG.C_PROBE6_WIDTH {4} \
#    CONFIG.C_PROBE3_WIDTH {4} \
#    CONFIG.C_PROBE2_WIDTH {32} \
#    CONFIG.C_NUM_OF_PROBES {8} \
#    CONFIG.Component_Name {ila_data_gen} \
# ] [get_ips ila_data_recv]

create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect
set_property -dict [list \
  CONFIG.C_M00_AXIS_BASETDEST {0x00000000} \
  CONFIG.C_M00_AXIS_HIGHTDEST {0x00000000} \
  CONFIG.C_M01_AXIS_BASETDEST {0x00000001} \
  CONFIG.C_M01_AXIS_HIGHTDEST {0x00000001} \
  CONFIG.C_M02_AXIS_BASETDEST {0x00000002} \
  CONFIG.C_M02_AXIS_HIGHTDEST {0x00000002} \
  CONFIG.C_NUM_MI_SLOTS {3} \
  CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} \
  CONFIG.C_SWITCH_TDEST_WIDTH {2} \
  CONFIG.HAS_TDEST {true} \
  CONFIG.HAS_TID {false} \
  CONFIG.HAS_TSTRB {false} \
  CONFIG.M01_S00_CONNECTIVITY {true} \
  CONFIG.M02_S00_CONNECTIVITY {true} \
] [get_ips axis_interconnect]