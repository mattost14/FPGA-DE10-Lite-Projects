library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_stopwatch_top is
  port (
    MAX10_CLK1_50 : in std_logic;
    KEY : in std_logic_vector(1 downto 0);
    HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : out std_logic_vector(7 downto 0);
    LEDR : out std_logic_vector(9 downto 0)
  );
end my_stopwatch_top;

architecture rtl of my_stopwatch_top is
  signal rst : std_logic;
  signal stp : std_logic;
  signal cc : unsigned(7 downto 0);
  signal ss : unsigned(7 downto 0);
  signal mm : unsigned(7 downto 0);

  signal cc_0 : unsigned(3 downto 0);
  signal cc_1 : unsigned(3 downto 0);
  signal ss_0 : unsigned(3 downto 0);
  signal ss_1 : unsigned(3 downto 0);
  signal mm_0 : unsigned(3 downto 0);
  signal mm_1 : unsigned(3 downto 0);
begin
  LEDR <= (others => '0'); -- turn all LEDs off
  rst <= not KEY(0);
  stp <= KEY(1);

  u0 : entity work.my_stopwatch(rtl)
  generic map (
    N_tickCycles => 500_000
  )
  port map (
    clk => MAX10_CLK1_50,
    rst => rst,
    stp => stp,
    cc  => cc,
    ss  => ss,
    mm  => mm
  );

  cc_0 <= resize(cc mod 10, cc_0'length);
  cc_1 <= resize(cc / 10, cc_1'length);
  ss_0 <= resize(ss mod 10, ss_0'length);
  ss_1 <= resize(ss / 10, ss_1'length);
  mm_0 <= resize(mm mod 10, mm_0'length);
  mm_1 <= resize(mm / 10, mm_1'length);

  u_HEX0 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '0'
  )
  port map (
    i_Digit => cc_0,
    oSEG    => HEX0
  );

  u_HEX1 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '0'
  )
  port map (
    i_Digit => cc_1,
    oSEG    => HEX1
  );

  u_HEX2 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '1'
  )
  port map (
    i_Digit => ss_0,
    oSEG    => HEX2
  );

  u_HEX3 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '0'
  )
  port map (
    i_Digit => ss_1,
    oSEG    => HEX3
  );

  u_HEX4 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '1'
  )
  port map (
    i_Digit => mm_0,
    oSEG    => HEX4
  );

  u_HEX5 : entity work.SEG7_LUT(rtl)
  generic map(
    decimalPoint => '0'
  )
  port map (
    i_Digit => mm_1,
    oSEG    => HEX5
  );


end architecture;