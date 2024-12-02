// for verifying 'axis_stim_syn' only. 

`timescale 1ns / 1ps  // <time_unit>/<time_precision>
  // time_unit: measurement of delays / simulation time (#10 = 10<time_unit>)
  // time_precision: how delay values are rounded before being used in simulation (degree of accuracy of the time unit)

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

module spi_tb ;

  logic clk=0,clk25=0, rstn=0, rst;

  //always #2 clk = ~clk; // 250mhz period = 4ns, invert every 2ns
  always #5 clk = ~clk; // 100mhz 
  always #20 clk25 = ~clk25; 

  initial begin
    rstn <= 0;
    #20;
    rstn <= 1;
  end
  assign rst = !rstn;


//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------
  logic [23:0] data;
  logic sclk, csn, din, clk_en;
  logic [7:0] td0,td1,opcode,addr;


  spi spi(
    .rst      (rst),
    .td0      (td0),
    .td1      (td1),
    .ila_clk  (clk),
    .sclk_i   (sclk),
    .csn_i    (csn),
    .mosi_i   (din),
    .miso_o   ()
  );

  spi2 spi2(
    .rst      (rst),
    .td0      (td0),
    .td1      (td1),
    .ila_clk  (clk),
    .sclk_i   (sclk),
    .csn_i    (csn),
    .mosi_i   (din),
    .miso_o   ()
  );

  spi3 spi3(
    .rst      (rst),
    .td0      (td0),
    .td1      (td1),
    .ila_clk  (clk),
    .sclk_i   (sclk),
    .csn_i    (csn),
    .mosi_i   (din),
    .miso_o   ()
  );

  spi4 spi4(
    .rst      (rst),
    .td0      (td0),
    .td1      (td1),
    .ila_clk  (clk),
    .sclk_i   (sclk),
    .csn_i    (csn),
    .mosi_i   (din),
    .miso_o   ()
  );


  //assign data = 32'b0100_0001_0000_0001_0000_0000_0000_0000;
  //parameter [7:0] OPCODE = 'h41;
  //parameter [7:0] ADDR   = 'h01;
  //assign          data = {OPCODE,ADDR,8'h00};

  initial begin 
    td0     <= 'h81;
    clk_en  <= '0;
    csn     <= '1;
    din     <= '0;
    opcode = 'h41; addr = 'h01;
    #1ns;
    data = {opcode,addr,8'h00};
    wait(rst==0);
    #50ns;
    csn     <= '0; #50ns; @(negedge clk25);
    clk_en  <= '1;
    //for (int idx =  0; idx < $size(data); idx++) begin 
    for (int idx = 23; idx >=0; idx--) begin // only one byte after commands
      din <= data[idx];
      @(negedge clk25);
    end
    clk_en <= '0;#50ns; csn <= '1;din <= '0;

    // ----------
    #200ns;
    opcode = 'h41; addr = 'h81;
    #1ns;
    data = {opcode,addr,8'h00};   
    td0     <= 'hc5;
    wait(rst==0);
    #50ns;
    csn     <= '0; #50ns; @(negedge clk25);
    clk_en  <= '1;
    //for (int idx =  0; idx < $size(data); idx++) begin 
    for (int idx = 23; idx >=0; idx--) begin 
      din <= data[idx];
      @(negedge clk25);
    end
    clk_en <= '0;#50ns; csn <= '1;din <= '0;

    // ----------
    #200ns;
    opcode = 'h40; addr = 'h85;
    #1ns;
    data = {opcode,addr,8'hc5};
    td0     <= 'hC0;
    wait(rst==0);
    #50ns;
    csn     <= '0; #50ns; @(negedge clk25);
    clk_en  <= '1;
    //for (int idx =  0; idx < $size(data); idx++) begin 
    for (int idx = 23; idx >=0; idx--) begin 
      din <= data[idx];
      @(negedge clk25);
    end
    clk_en <= '0;#50ns; csn <= '1;din <= '0;

    // ----------
    #200ns;
    opcode = 'h40; addr = 'hc5;
    #1ns;
    data = {opcode,addr,8'h81};
    td0     <= 'ha5;
    wait(rst==0);
    #50ns;
    csn     <= '0; #50ns; @(negedge clk25);
    clk_en  <= '1;
    //for (int idx =  0; idx < $size(data); idx++) begin 
    for (int idx = 23; idx >=0; idx--) begin 
      din <= data[idx];
      @(negedge clk25);
    end
    clk_en <= '0;#50ns; csn <= '1;din <= '0;

  end 

  assign sclk = (clk_en)? clk25:'0;

endmodule