
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]

set_property PACKAGE_PIN A9         [get_ports {RADIO_LED[0]}];
set_property PACKAGE_PIN B9         [get_ports {RADIO_LED[1]}];

set_property IOSTANDARD LVCMOS18    [get_ports {RADIO_LED[0]}];
set_property IOSTANDARD LVCMOS18    [get_ports {RADIO_LED[1]}];
