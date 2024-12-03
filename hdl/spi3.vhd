--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi3 is
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
end spi3;

architecture rtl of spi3 is

-- constants

-- types
  type spi_sm_type is (IDLE,GET_OPCODE,GET_ADDR,GET_DATA,SEND_DATA,SWAIT);
  signal spi_sm : spi_sm_type;

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


  signal testd  : std_logic_vector(7 downto 0):= x"38";
  signal testo  : std_logic_vector(7 downto 0):= x"00";
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
    dout_ne <= dout;
  end if;
end process;

sm_proc : process(sclk_i) begin 
  if (csn) then 
    SPI_SM <= IDLE; -- if clock is running but this CS is not active, make sure in IDLE
  elsif rising_edge(sclk_i) then
    case SPI_SM is 
      when IDLE => --0
        data_snd            <= td0;
        data_snd2           <= td1;
        opcode(6 downto 0)  <= (others => '0'); --clear
        addr                <= (others => '0'); --clear
        data_rcv            <= (others => '0');
        opcode_done         <= '0'; --clear
        addr_done           <= '0'; --clear
        data_rcv_done       <= '0';
        bit_idx             <= 7;
        if (NOT csn) then 
          opcode(7) <= din; -- 1st bit
          bit_idx   <= bit_idx - 1;
          SPI_SM    <= GET_OPCODE; 
        end if;
      
      when GET_OPCODE => --1
        if (bit_idx = 0) then
          opcode(0)   <= din;  --last bit
          bit_idx     <= 7;
          opcode_done <= '1';
          SPI_SM      <= GET_ADDR; 
        else
          opcode(bit_idx) <= din;
          bit_idx         <= bit_idx - 1;
        end if;
      
      when GET_ADDR => --2
        if (bit_idx = 0) then
          addr(0)   <= din;  --last bit
          addr_done <= '1';
          if (opcode(0) = '0') then 
            bit_idx     <= 7;
            --data_rcv(7) <= din;
            SPI_SM      <= GET_DATA;  -- write command from SRC, this module will receive data
          else
            bit_idx   <= 6;
            dout      <= data_snd(7);
            SPI_SM    <= SEND_DATA; -- read command from SRC, this module will send data to SRC
          end if;
        else
          addr(bit_idx) <= din; 
          bit_idx       <= bit_idx - 1;
        end if;
      
      when GET_DATA => --3
        if (bit_idx = 0) then
          data_rcv(0)   <= din;  --last bit
          bit_idx       <= 7;
          SPI_SM        <= IDLE;
          opcode        <= (others => '0'); --clear
          addr          <= (others => '0'); --clear
          opcode_done   <= '0'; --clear
          addr_done     <= '0'; --clear
          data_rcv_done <= '1';
        else
          data_rcv(bit_idx) <= din; 
          bit_idx           <= bit_idx - 1;
        end if;
       
      when SEND_DATA => --4
        if (bit_idx = 0) then
          dout        <= data_snd(0);  --last bit
          bit_idx     <= 7;
          --SPI_SM      <= SEND_DATA2;
          SPI_SM <= SWAIT;
          opcode      <= (others => '0'); --clear
          addr        <= (others => '0'); --clear
          opcode_done <= '0'; --clear
          addr_done   <= '0'; --clear
        else
          dout    <= data_snd(bit_idx);
          bit_idx <= bit_idx - 1;
        end if;
       
      when SWAIT => 
        dout    <= '0';         
        SPI_SM  <= IDLE; --6
      
    end case;
  end if;
end process;

---------------------------------------------------------------------------------------------------
-- debug
---------------------------------------------------------------------------------------------------


  sm <= "000" when (SPI_SM = IDLE         ) else
        "001" when (SPI_SM = GET_OPCODE   ) else
        "010" when (SPI_SM = GET_ADDR     ) else
        "011" when (SPI_SM = GET_DATA     ) else
        "100" when (SPI_SM = SEND_DATA    ) else
        "110" when (SPI_SM = SWAIT        ) else
        "111";

  idx <= std_logic_vector(to_unsigned(bit_idx,3));
  
--  ila2 : entity work.ila2
--  	port map (
--      clk      => ila_clk        ,
--  	  probe0   => sm             ,
--  	  probe1   => csn            ,
--  	  probe2   => din            ,
--  	  probe3   => dout_ne        ,
--  	  probe4   => idx            ,
--  	  probe5   => data_snd       ,
--  	  probe6   => opcode         ,
--  	  probe7   => addr           ,
--  	  probe8   => data_rcv       ,
--  	  probe9   => opcode_done    ,
--  	  probe10  => addr_done      ,
--      probe11  => sclk_i         ,
--      probe12  => data_rcv_done  ,
--      probe13  => data_rcv       
--  );



end architecture rtl;
