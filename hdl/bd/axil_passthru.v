
	module axil_passthru #
	(
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 7
	)
	(
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 			S_AXI_AWADDR,
		input wire [2 : 0] 													S_AXI_AWPROT,
		input wire  																S_AXI_AWVALID,
		output wire  																S_AXI_AWREADY,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] 			S_AXI_WDATA,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] 	S_AXI_WSTRB,
		input wire  																S_AXI_WVALID,
		output wire  																S_AXI_WREADY,
		output wire [1 : 0] 												S_AXI_BRESP,
		output wire  																S_AXI_BVALID,
		input wire  																S_AXI_BREADY,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] 			S_AXI_ARADDR,
		input wire [2 : 0] 													S_AXI_ARPROT,
		input wire  																S_AXI_ARVALID,
		output wire  																S_AXI_ARREADY,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] 			S_AXI_RDATA,
		output wire [1 : 0] 												S_AXI_RRESP,
		output wire  																S_AXI_RVALID,
		input wire  																S_AXI_RREADY,

		output wire [C_S_AXI_ADDR_WIDTH-1 : 0] 			M_AXI_AWADDR,
		output wire [2 : 0] 												M_AXI_AWPROT,
		output wire  																M_AXI_AWVALID,
		input wire  																M_AXI_AWREADY,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] 			M_AXI_WDATA,
		output wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0]	M_AXI_WSTRB,
		output wire  																M_AXI_WVALID,
		input wire  																M_AXI_WREADY,
		input wire [1 : 0] 													M_AXI_BRESP,
		input wire  																M_AXI_BVALID,
		output wire  																M_AXI_BREADY,
		output wire [C_S_AXI_ADDR_WIDTH-1 : 0] 			M_AXI_ARADDR,
		output wire [2 : 0] 												M_AXI_ARPROT,
		output wire  																M_AXI_ARVALID,
		input wire  																M_AXI_ARREADY,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] 			M_AXI_RDATA,
		input wire [1 : 0] 													M_AXI_RRESP,
		input wire  																M_AXI_RVALID,
		output wire  																M_AXI_RREADY
	);

  assign M_AXI_AWADDR   = S_AXI_AWADDR  ;
  assign M_AXI_AWPROT   = S_AXI_AWPROT  ;
  assign M_AXI_AWVALID  = S_AXI_AWVALID ;
  assign M_AXI_WDATA    = S_AXI_WDATA   ;
  assign M_AXI_WSTRB    = S_AXI_WSTRB   ;
  assign M_AXI_WVALID   = S_AXI_WVALID  ;
  assign M_AXI_BREADY   = S_AXI_BREADY  ;
  assign M_AXI_ARADDR   = S_AXI_ARADDR  ;
  assign M_AXI_ARPROT   = S_AXI_ARPROT  ;
  assign M_AXI_ARVALID  = S_AXI_ARVALID ;
  assign M_AXI_RREADY   = S_AXI_RREADY  ;

  assign S_AXI_AWREADY  = M_AXI_AWREADY ;
  assign S_AXI_WREADY   = M_AXI_WREADY  ;
  assign S_AXI_BRESP    = M_AXI_BRESP   ;
  assign S_AXI_BVALID   = M_AXI_BVALID  ;
  assign S_AXI_ARREADY  = M_AXI_ARREADY ;
  assign S_AXI_RDATA    = M_AXI_RDATA   ;
  assign S_AXI_RRESP    = M_AXI_RRESP   ;
  assign S_AXI_RVALID   = M_AXI_RVALID  ;


	endmodule
