library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity my_stopwatch_top_tb is
end my_stopwatch_top_tb;

architecture sim of my_stopwatch_top_tb is

  constant clk_hz : integer := 50e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal KEY : std_logic_vector(1 downto 0) := "11";

  signal HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : std_logic_vector(7 downto 0);

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.my_stopwatch_top(rtl)
  port map (
    MAX10_CLK1_50 => clk,
    KEY => KEY,
    HEX0 => HEX0,
    HEX1 => HEX1,
    HEX2 => HEX2,
    HEX3 => HEX3,
    HEX4 => HEX4,
    HEX5 => HEX5
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;
    report "Reset";
    KEY(0) <= '0'; -- reset is pressed
    KEY(1) <= '1'; -- go is not pressed
    wait for clk_period * 2; 
    report "Reset button is released";
    KEY(0) <= '1'; -- reset is not pressed
    wait for clk_period * 2; 
    report "Go button is pressed";
    KEY(1) <= '0'; -- go is pressed
    wait for clk_period * 12000;
    report "Go button is released";
    KEY(1) <= '1'; -- go is not pressed
    wait for clk_period * 100;
    report "Reset button is pressed";
    KEY(0) <= '0'; -- reset is pressed
    wait for clk_period * 100;

    finish;
  end process;

end architecture;