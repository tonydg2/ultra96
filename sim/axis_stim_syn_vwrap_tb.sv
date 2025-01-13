// for verifying 'axis_stim_syn' only. 

`timescale 1ns / 1ps  // <time_unit>/<time_precision>
  // time_unit: measurement of delays / simulation time (#10 = 10<time_unit>)
  // time_precision: how delay values are rounded before being used in simulation (degree of accuracy of the time unit)

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

module axis_stim_syn_vwrap_tb ;

  logic clk=0, rstn=0, rst;

  always #2 clk = ~clk; // 250mhz period = 4ns, invert every 2ns

  initial begin
    rstn <= 0;
    #20;
    rstn <= 1;
  end
  assign rst = !rstn;


//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------


  axis_stim_syn_vwrap #(
    .DATA_WIDTH     (32)
  ) axis_stim_syn_vwrap (
    .clk		         (clk),                  
    .rst		         (~rstn),                  
    .start           ('0),         
    .M_AXIS_tdata    (),         
    .M_AXIS_tdest    (),         
    .M_AXIS_tkeep    (),         
    .M_AXIS_tlast    (),         
    .M_AXIS_tready   ('1),         
    .M_AXIS_tvalid   ()
  );


endmodule