# From vivado project gui tcl console:
# source ip.tcl

create_ip -name axi_protocol_converter -vendor xilinx.com -library ip -version 2.1 -module_name axi_protocol_converter_0
set_property -dict [list \
  CONFIG.ADDR_WIDTH {40} \
  CONFIG.DATA_WIDTH {64} \
  CONFIG.MI_PROTOCOL {AXI4} \
  CONFIG.SI_PROTOCOL {AXI4LITE} \
  CONFIG.TRANSLATION_MODE {2} \
] [get_ips axi_protocol_converter_0]

create_ip -name axi_dwidth_converter -vendor xilinx.com -library ip -version 2.1 -module_name axi_dwidth_converter_0
set_property -dict [list \
  CONFIG.ADDR_WIDTH {40} \
  CONFIG.MAX_SPLIT_BEATS {16} \
  CONFIG.MI_DATA_WIDTH {64} \
  CONFIG.PROTOCOL {AXI4LITE} \
  CONFIG.SI_DATA_WIDTH {32} \
] [get_ips axi_dwidth_converter_0]

create_ip -name axi_dwidth_converter -vendor xilinx.com -library ip -version 2.1 -module_name axi_dwidth_converter_axi4_64to128
set_property -dict [list \
  CONFIG.ADDR_WIDTH {40} \
  CONFIG.MAX_SPLIT_BEATS {16} \
  CONFIG.MI_DATA_WIDTH {128} \
  CONFIG.PROTOCOL {AXI4} \
  CONFIG.SI_DATA_WIDTH {64} \
] [get_ips axi_dwidth_converter_axi4_64to128]



