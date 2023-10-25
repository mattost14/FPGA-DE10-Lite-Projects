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
  signal clk0             : std_logic;
  signal clk1             : std_logic;
  signal rst              : std_logic;
  signal add              : std_logic;
  signal add_debounced    : std_logic;
  signal value            : unsigned(9 downto 0);
  signal acc              : unsigned(23 downto 0);
  -- 7-Segment Display Lookup Table
  type RAM is array (0 to 15) of std_logic_vector(7 downto 0);
  constant lut : RAM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"98", X"88", X"83", X"C6", X"A1", X"86", X"8E");

begin
  -- Buttons, Switches, and LEDs assigments
  rst <= not KEY(0);
  add <= not KEY(1);
  value <= unsigned(SW);
  LEDR <= SW;

  -- 7-Segment Displays assigments
  HEX5 <= lut(to_integer(acc(23 downto 20)));
  HEX4 <= lut(to_integer(acc(19 downto 16)));
  HEX3 <= lut(to_integer(acc(15 downto 12)));
  HEX2 <= lut(to_integer(acc(11 downto 8)));
  HEX1 <= lut(to_integer(acc(7 downto 4)));
  HEX0 <= lut(to_integer(acc(3 downto 0)));

  -- Debounce add button
  U0: entity work.ButtonDebounce 
  generic map (
    delay => 500  -- 0.001 ms of press button for 5MHz clock
  )
  port map(
    clk       => clk0, 
    rst       => rst, 
    input     => add,
    debounce  => add_debounced
  );

  -- PLL Clocks
  PLL_Clocks_inst : entity work.PLL_Clocks 
  port map (
		inclk0	 => MAX10_CLK1_50,
		c0	 => clk0,
		c1	 => clk1
	);
    
  -- Accumulator with FIFO
  U1 : entity work.Accumulator(rtl)
  port map (
    clk0   => clk0, -- Write FIFO clock
    clk1   => clk1, -- Read FIFO clock
    -- Buttons
    rst   => rst,
    add   => add_debounced,  
    -- Input value
    value => value,
    -- Accumulated value
    acc   => acc
  );

end architecture;