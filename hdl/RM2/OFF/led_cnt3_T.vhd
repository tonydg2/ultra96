-- vhdl wrapper

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity led_cnt3_pr is 
  port (
    rst     :  in  std_logic;
    clk100  :  in  std_logic;
    led_o   :  out std_logic
  );
end led_cnt3_pr;

architecture rtl of led_cnt3_pr is 
-- components
-- constants
-- types
-- signals

----------------------------------------------------------------------------------------------------
begin  -- architecture
-------------------------------------------------------------------------------------------------       

led_cnt_inst : entity work.led_cnt
  port map (
    rst     => rst      ,
    clk100  => clk100   ,
    div_i   => x"3"     ,
    wren_i  => '0'      ,
    led_o   => led_o    
 );

end architecture rtl;
