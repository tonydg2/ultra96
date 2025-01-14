-- vhdl 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity led_cnt_vhd19 is 
  port (
    rst   : in  std_logic;
    clk   : in  std_logic;
    wren_i: in  std_logic;
    div_i : in  unsigned(4 downto 0);
    led_o : out std_logic
  );
end led_cnt_vhd19;

architecture rtl of led_cnt_vhd19 is 
-- components
-- constants
  
  constant CNT_1S : unsigned(27 downto 0) := x"5F5E100";
-- types
-- signals

  signal cnt, cnt_max : unsigned(27 downto 0);
  signal led          : std_logic;

----------------------------------------------------------------------------------------------------
begin  -- architecture
-------------------------------------------------------------------------------------------------       

  cnt_max <=  CNT_1S when (div_i = "00000") else
              CNT_1S when (div_i > x"14") else 
              (CNT_1S / div_i);

  ledCntProc : process(clk) begin 
    if rising_edge(clk) then
      if (rst = '1') then 
        cnt <= (others => '0');
        led <= '0';
      else
        if ((cnt = cnt_max) OR (wren_i = '1')) then
          cnt <= (others => '0');
          led <= NOT led;
        else 
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;

  led_o <= led;

end architecture rtl;
