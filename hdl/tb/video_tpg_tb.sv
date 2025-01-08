// for verifying 'axis_stim_syn' only. 

`timescale 1ns / 1ps  // <time_unit>/<time_precision>
  // time_unit: measurement of delays / simulation time (#10 = 10<time_unit>)
  // time_precision: how delay values are rounded before being used in simulation (degree of accuracy of the time unit)

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

module video_tpg_tb ;

  logic clk=0, rstn=0, rst,tready,en;
  logic  [12:0] subh=0,addh=0,subw=0,addw=0;

  //always #2 clk = ~clk; // 250mhz period = 4ns, invert every 2ns
  always #5 clk = ~clk; // 100mhz 

  initial begin
    rstn <= 0;
    tready <= 0;
    en <= 0;
    #20;
    rstn <= 1;
    #200;
    en <= 1;
    #200;
    tready <= 1;
    #200;tready <= 0;
    #5;tready <= 1;
    #40;tready <= 0;
    #10;tready <= 1;
    #5;tready <= 1;
    #40;tready <= 0;
    #10;tready <= 1;
    #5;tready <= 1;
    #40;tready <= 0;
    #10;tready <= 1;
    #5;tready <= 1;
    #40;tready <= 0;
    #10;tready <= 1;
    #5;tready <= 1;
    #40;tready <= 0;
    #10;tready <= 1;
    #5;tready <= 1;
    #40;tready <= 0;
    #10;tready <= 1;
    #5;tready <= 1;
    #40;tready <= 0;
    #10;tready <= 1;

    subh <= 10;
    #100;
    addh <= 1;
    #100;


  end
  assign rst = !rstn;


//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------
  video_tpg # (
    .DATAW      (24)
  ) video_tpg (
    .rst            (rst),
    .clk            (clk),
    .en             (en),
    .subh           (subh),
    .addh           (addh),
    .subw           (subw),
    .addw           (addw),
    .m_axis_tdata   (),
    .m_axis_tvalid  (),
    .m_axis_tready  (tready),
    .m_axis_tuser   (),
    .m_axis_tlast   (),
    .m_axis_tstrb   (),
    .m_axis_tkeep   (),
    .m_axis_tid     (),
    .m_axis_tdest   ()

);


endmodule