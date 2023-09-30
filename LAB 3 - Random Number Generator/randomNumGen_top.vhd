library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randomNumGen_top is
  port (
    MAX10_CLK1_50 : in std_logic;
    KEY : in std_logic_vector(1 downto 0);
    HEX1, HEX0 : out std_logic_vector(7 downto 0);
    LEDR : out std_logic_vector(9 downto 0)
  );
end randomNumGen_top;

architecture rtl of randomNumGen_top is
  signal rst : std_logic;
  signal gen : std_logic;
  signal randomNum : unsigned(7 downto 0);

begin
  LEDR <= (others => '0'); -- turn all LEDs off
  rst <= not KEY(0);
  gen <= not KEY(1);

  u0 : entity work.randomNumGen(rtl)
  generic map(
    N => 8
  )
  port map (
    clk => MAX10_CLK1_50,
    rst => rst,
    gen => gen,
    randomNum => randomNum
  );


  u_HEX0 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '0'
  )
  port map (
    i_Digit => randomNum(3 downto 0),
    oSEG    => HEX0
  );

  u_HEX1 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '0'
  )
  port map (
    i_Digit => randomNum(7 downto 4),
    oSEG    => HEX1
  );
  
end architecture;