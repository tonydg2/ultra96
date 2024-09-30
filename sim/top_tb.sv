// test5
`timescale 1ns / 1ps  // <time_unit>/<time_precision>
  // time_unit: measurement of delays / simulation time (#10 = 10<time_unit>)
  // time_precision: how delay values are rounded before being used in simulation (degree of accuracy of the time unit)

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

module top_tb ;

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


initial begin 
  wait(rst==0);
//  #200ns;tready=1;
  wait(axil_done == 1);
  #20ns;start_en;
end


task start_en;
  begin 
    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
  end 
endtask
  

endmodule