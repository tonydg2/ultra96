--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi4 is
  generic (
    gen_val0 : std_logic := '0' ;
    gen_val1 : std_logic := '0'
  );
  port (
    rst     : in  std_logic                     ;
    td0     : in  std_logic_vector(7 downto 0)  ;
    td1     : in  std_logic_vector(7 downto 0)  ;
    ila_clk : in  std_logic                     ;
    sclk_i  : in  std_logic                     ;
    csn_i   : in  std_logic                     ;
    mosi_i  : in  std_logic                     ;
    miso_o  : out std_logic                     
  );
end spi4;

architecture rtl of spi4 is

-- constants

-- types
  type spi_sm_type is (IDLE,GET_OPCODE,GET_ADDR,GET_DATA,SEND_DATA,SWAIT);
  signal spi_state      : spi_sm_type;
  signal spi_state_next : spi_sm_type;

-- signals

  signal opcode     : std_logic_vector(7 downto 0) := (others => '0') ;
  signal addr       : std_logic_vector(7 downto 0) := (others => '0') ;
  signal data_rcv   : std_logic_vector(7 downto 0) := (others => '0') ;
  signal data_snd   : std_logic_vector(7 downto 0)                    ;
  signal data_snd2  : std_logic_vector(7 downto 0)                    ;

  signal dout           : std_logic := '0';
  signal dout_ne        : std_logic := '0';
  signal opcode_done    : std_logic := '0';
  signal addr_done      : std_logic := '0';
  signal data_rcv_done  : std_logic := '0';
  signal csn            : std_logic;
  signal din            : std_logic;

  signal bit_idx  : integer range 0 to 7 := 7;
  
  signal sm     : std_logic_vector(2 downto 0);
  signal idx    : std_logic_vector(2 downto 0);

----------------------------------------------------------------------------------------------------
begin  -- architecture
-------------------------------------------------------------------------------------------------       

  csn     <= csn_i;
  din     <= mosi_i;
  miso_o  <= dout_ne;


miso_fe_proc : process(sclk_i) begin 
  if falling_edge(sclk_i) then
    if (spi_state = SEND_DATA) then
      dout_ne  <= td0(bit_idx); 
    --elsif (spi_state = SWAIT) then 
    else
      dout_ne  <= '0'; 
    end if;
  end if;
end process;

sm_proc : process(sclk_i) begin 
  if rising_edge(sclk_i) then
    if (rst) then 
      spi_state <= IDLE;
    else
      spi_state <= spi_state_next;
    end if;
  end if;
end process;

bit_idx_cnt_proc : process(sclk_i) begin 
  if rising_edge(sclk_i) then
    if (rst) then 
      bit_idx <= 7;
    else 
      if (bit_idx = 0) then 
        bit_idx <= 7;
      else
        bit_idx <= bit_idx - 1;
      end if;
    end if;
  end if;
end process;

data_proc : process(sclk_i) begin 
  if rising_edge(sclk_i) then
    if (rst) then 
      opcode(6 downto 0)  <= (others => '0'); --clear
      addr                <= (others => '0'); --clear
      data_rcv            <= (others => '0');
      opcode_done         <= '0'; --clear
      addr_done           <= '0'; --clear
      data_rcv_done       <= '0';
    else 
      if (spi_state = IDLE) then
        opcode_done   <= '0';
        addr_done     <= '0';
        data_rcv_done <= '0';
      elsif (spi_state = GET_OPCODE) then 
        opcode(bit_idx) <= din;
        if (bit_idx = 0) then 
          opcode_done <= '1';
        else
          opcode_done <= '0';
        end if;
      elsif (spi_state = GET_ADDR) then 
        opcode_done   <= '0';
        addr(bit_idx) <= din; 
        if (bit_idx = 0) then 
          addr_done <= '1';
        else
          addr_done <= '0';
        end if;
      elsif (spi_state = GET_DATA) then 
        addr_done         <= '0';
        data_rcv(bit_idx) <= din; 
        if (bit_idx = 0) then 
          data_rcv_done <= '1';
        else
          data_rcv_done <= '0';
        end if;
      --end else if (spi_state == SEND_DATA) begin 
      --end else if (spi_state == WAIT) begin 
      end if;
    end if;
  end if;
end process;


sm_comb_proc : process(all) begin 
  case spi_state is 
    when IDLE => --0
        spi_state_next <= GET_OPCODE; 
    
    when GET_OPCODE => --1
      if (bit_idx = 0) then
        spi_state_next      <= GET_ADDR; 
      else 
        spi_state_next      <= spi_state;
      end if;
    
    when GET_ADDR => --2
      if (bit_idx = 0) then
        if (opcode(0) = '0') then 
          spi_state_next  <= GET_DATA;  -- write command from SRC, this module will receive data
        else
          spi_state_next  <= SEND_DATA; -- read command from SRC, this module will send data to SRC
        end if;
      else 
        spi_state_next    <= spi_state;
      end if;
    
    when GET_DATA => --3
      if (bit_idx = 0) then
        spi_state_next  <= IDLE;
      else 
        spi_state_next  <= spi_state;
      end if;
     
    when SEND_DATA => --4
      if (bit_idx = 0) then
        spi_state_next  <= IDLE;--SWAIT;
      else 
        spi_state_next  <= spi_state;
      end if;
     
    when SWAIT => 
      spi_state_next  <= IDLE; --6
    
  end case;
end process;

---------------------------------------------------------------------------------------------------
-- debug
---------------------------------------------------------------------------------------------------


  sm <= "000" when (spi_state = IDLE         ) else
        "001" when (spi_state = GET_OPCODE   ) else
        "010" when (spi_state = GET_ADDR     ) else
        "011" when (spi_state = GET_DATA     ) else
        "100" when (spi_state = SEND_DATA    ) else
        "110" when (spi_state = SWAIT        ) else
        "111";

  idx <= std_logic_vector(to_unsigned(bit_idx,3));

--  ila2 : entity work.ila2
--  	port map (
--      clk      => ila_clk         ,
--  	  probe0   => sm              ,
--  	  probe1   => csn             ,
--  	  probe2   => din             ,
--  	  probe3   => dout_ne         ,
--  	  probe4   => idx             ,
--  	  probe5   => data_snd        ,
--  	  probe6   => opcode          ,
--  	  probe7   => addr            ,
--  	  probe8   => data_rcv        ,
--  	  probe9   => opcode_done     ,
--  	  probe10  => addr_done       ,
--      probe11  => sclk_i          ,
--      probe12  => data_rcv_done   ,
--      probe13  => data_rcv       
--  );


end architecture rtl;
