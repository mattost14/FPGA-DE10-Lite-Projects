library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity Accumulator_tb is
end Accumulator_tb;

architecture sim of Accumulator_tb is

  constant clk_hz : integer := 50e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal add : std_logic := '0';
  signal value : unsigned(9 downto 0) := "0000000001";
  signal acc   : unsigned(23 downto 0) := (others => '0');

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.Accumulator(rtl)
  port map (
    clk => clk,
    rst => rst,
    add => add,
    value => value,
    acc => acc
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;
    rst <= '0';
    wait for clk_period * 10;
    add <= '1';
    report "+ 1 to acc";
    wait for clk_period * 5;
    add <= '0';
    wait for clk_period * 5;
    add <= '1';
    report "+ 1 to acc";
    wait for clk_period * 5;
    add <= '0';
    value <= "0000000011";
    wait for clk_period * 5;
    add <= '1';
    report "+ 3 to acc";
    wait for clk_period * 5;
    add <= '0';
    wait for clk_period * 5;
    rst <= '1';
    wait for clk_period * 5;
    rst <= '0';
    add <= '1';
    report "+ 3 to acc";
    wait for clk_period * 10;
    finish;
  end process;

end architecture;