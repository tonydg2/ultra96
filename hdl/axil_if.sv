
interface axil_if # (
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
)(
  input aclk,
  input aresetn 
);

  logic [ADDR_WIDTH-1: 0]     awaddr    ;
  logic [ 2: 0]               awprot    ;
  logic                       awvalid   ;
  logic                       awready   ;
  logic [DATA_WIDTH-1: 0]     wdata     ;
  logic [(DATA_WIDTH/8)-1:0]  wstrb     ;
  logic                       wvalid    ;
  logic                       wready    ;
  logic [ 1: 0]               bresp     ;
  logic                       bvalid    ;
  logic                       bready    ;
  logic [ADDR_WIDTH-1: 0]     araddr    ;
  logic [ 2: 0]               arprot    ;
  logic                       arvalid   ;
  logic                       arready   ;
  logic [DATA_WIDTH-1: 0]     rdata     ;
  logic [ 1: 0]               rresp     ;
  logic                       rvalid    ;
  logic                       rready    ;

  // Source (master)
  modport src (
    input  aclk     ,  
    input  aresetn  ,
    output awaddr   ,
    output awprot   ,
    output awvalid  ,
    input  awready  ,
    output wdata    ,
    output wstrb    ,
    output wvalid   ,
    input  wready   ,
    input  bresp    ,
    input  bvalid   ,
    output bready   ,
    output araddr   ,
    output arprot   ,
    output arvalid  ,
    input  arready  ,
    input  rdata    ,
    input  rresp    ,
    input  rvalid   ,
    output rready   
  );

  // Sink (slave)
  modport snk (
    input   aclk    ,  
    input   aresetn ,
    input   awaddr  ,
    input   awprot  ,
    input   awvalid ,
    output  awready ,
    input   wdata   ,
    input   wstrb   ,
    input   wvalid  ,
    output  wready  ,
    output  bresp   ,
    output  bvalid  ,
    input   bready  ,
    input   araddr  ,
    input   arprot  ,
    input   arvalid ,
    output  arready ,
    output  rdata   ,
    output  rresp   ,
    output  rvalid  ,
    input   rready   
  );



endinterface 