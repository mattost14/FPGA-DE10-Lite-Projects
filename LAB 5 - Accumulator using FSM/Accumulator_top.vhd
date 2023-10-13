library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accumulator_top is
  port (
    MAX10_CLK1_50                       : in std_logic;
    KEY                                 : in std_logic_vector(1 downto 0);
    SW                                  : in std_logic_vector(9 downto 0);
    HEX5, HEX4, HEX3, HEX2, HEX1, HEX0  : out std_logic_vector(7 downto 0);
    LEDR                                : out std_logic_vector(9 downto 0)
  );
end Accumulator_top;

architecture rtl of Accumulator_top is
  signal rst              : std_logic;
  signal add              : std_logic;
  signal add_debounced    : std_logic;
  signal value            : unsigned(9 downto 0);
  signal acc              : unsigned(23 downto 0);
begin
  rst <= not KEY(0);
  add <= not KEY(1);
  value <= unsigned(SW);
  LEDR <= SW;

  -- Debounce add button
  U0: entity work.ButtonDebounce 
    port map(
      clk       => MAX10_CLK1_50, 
      rst       => rst, 
      input     => add,
      debounce  => add_debounced
    );

  -- Accumulator instance
  U1 : entity work.Accumulator(rtl)
  port map (
    clk   => MAX10_CLK1_50,  
    rst   => rst,   
    add   => add_debounced,  
    value => value,
    acc   => acc  
  );

  -- Seven-Segment Display HEX0
  u_HEX0 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => acc(3 downto 0),
    oSEG    => HEX0
  );
  -- Seven-Segment Display HEX1
  u_HEX1 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => acc(7 downto 4),
    oSEG    => HEX1
  );
  -- Seven-Segment Display HEX2
  u_HEX2 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => acc(11 downto 8),
    oSEG    => HEX2
  );
  -- Seven-Segment Display HEX3
  u_HEX3 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => acc(15 downto 12),
    oSEG    => HEX3
  );
  -- Seven-Segment Display HEX4
  u_HEX4 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => acc(19 downto 16),
    oSEG    => HEX4
  );
  -- Seven-Segment Display HEX5
  u_HEX5 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => acc(23 downto 20),
    oSEG    => HEX5
  );

end architecture;