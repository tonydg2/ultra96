
interface axi_if # (
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)(
  input aclk,
  input aresetn 
);

  logic [ADDR_WIDTH-1: 0]     araddr    ;
  logic [1:0]                 arburst   ;
  logic [3:0]                 arcache   ;
//  logic [15:0]                arid      ;
  logic [7:0]                 arlen     ;
  logic [0:0]                 arlock    ;
  logic [2:0]                 arprot    ;
  logic [3:0]                 arregion  ;
  logic [3:0]                 arqos     ;
  logic                       arready   ;
  logic [2:0]                 arsize    ;
//  logic [15:0]                aruser    ;
  logic                       arvalid   ;
  logic [ADDR_WIDTH-1: 0]     awaddr    ;
  logic [1:0]                 awburst   ;
  logic [3:0]                 awcache   ;
//  logic [15:0]                awid      ;
  logic [7:0]                 awlen     ;
  logic [0:0]                 awlock    ;
  logic [2:0]                 awprot    ;
  logic [3:0]                 awregion  ;
  logic [3:0]                 awqos     ;
  logic                       awready   ;
  logic [2:0]                 awsize    ;
//  logic [15:0]                awuser    ;
  logic                       awvalid   ;
//  logic  [15:0]               bid       ;
  logic                       bready    ;
  logic  [1:0]                bresp     ;
  logic                       bvalid    ;
  logic [DATA_WIDTH-1: 0]     rdata     ;
//  logic [15:0]                rid       ;
  logic                       rlast     ;
  logic                       rready    ;
  logic [1:0]                 rresp     ;
  logic                       rvalid    ;
  logic [DATA_WIDTH-1: 0]     wdata     ;
  logic                       wlast     ;
  logic                       wready    ;
  logic [(DATA_WIDTH/8)-1:0]  wstrb     ;
  logic                       wvalid    ;


  // Source (master)
  modport src (
    input   aclk    ,  
    input   aresetn ,
    output  araddr  ,
    output  arburst ,
    output  arcache ,
    //output  arid    ,
    output  arlen   ,
    output  arlock  ,
    output  arprot  ,
    output  arregion,
    output  arqos   ,
    input   arready ,
    output  arsize  ,
    //output  aruser  ,
    output  arvalid ,
    output  awaddr  ,
    output  awburst ,
    output  awcache ,
    //output  awid    ,
    output  awlen   ,
    output  awlock  ,
    output  awprot  ,
    output  awregion,
    output  awqos   ,
    input   awready ,
    output  awsize  ,
    //output  awuser  ,
    output  awvalid ,
    //input bid     ,
    output  bready  ,
    input   bresp   ,
    input   bvalid  ,
    input   rdata   ,
    //input   rid     ,
    input   rlast   ,
    output  rready  ,
    input   rresp   ,
    input   rvalid  ,
    output  wdata   ,
    output  wlast   ,
    input   wready  ,
    output  wstrb   ,
    output  wvalid
  );

  // Sink (slave)
  modport snk (
    input   aclk    ,
    input   aresetn ,
    input   araddr  ,
    input   arburst ,
    input   arcache ,
    //input   arid    ,
    input   arlen   ,
    input   arlock  ,
    input   arprot  ,
    input   arregion,
    input   arqos   ,
    output  arready ,
    input   arsize  ,
    //input   aruser  ,
    input   arvalid ,
    input   awaddr  ,
    input   awburst ,
    input   awcache ,
    //input   awid    ,
    input   awlen   ,
    input   awlock  ,
    input   awprot  ,
    input   awregion,
    input   awqos   ,
    output  awready ,
    input   awsize  ,
    //input   awuser  ,
    input   awvalid ,
    //output  bid     ,
    input   bready  ,
    output  bresp   ,
    output  bvalid  ,
    output  rdata   ,
    //output  rid     ,
    output  rlast   ,
    input   rready  ,
    output  rresp   ,
    output  rvalid  ,
    input   wdata   ,
    input   wlast   ,
    output  wready  ,
    input   wstrb   ,
    input   wvalid
  );

endinterface 
