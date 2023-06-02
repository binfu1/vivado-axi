create_clock -period 10.000	 [get_ports init_clk]
set_clock_groups -asynchronous -group [get_clocks init_clk -include_generated_clocks]
set_property PACKAGE_PIN G18     [get_ports init_clk]
set_property IOSTANDARD LVCMOS18 [get_ports init_clk]