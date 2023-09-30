library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity randomNumGen_tb is
end randomNumGen_tb;

architecture sim of randomNumGen_tb is

  constant clk_hz : integer := 50e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal gen : std_logic := '0';
  signal randomNum : unsigned(7 downto 0);

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.randomNumGen(rtl)
  generic map (
    N => 8
  )
  port map (
    clk => clk,
    rst => rst,
    gen => gen,
    randomNum => randomNum
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;

    rst <= '0';
    gen <= '1';

    wait for clk_period * 10;
    gen <= '0';
    wait for clk_period * 10;
    gen <= '1';
    wait for clk_period * 10;
    rst <= '1';
    wait for clk_period * 2;
    rst <= '0';
    wait until randomNum = 0;
    report "Find x00 !!! ";
    wait for clk_period * 400;
    finish;
  end process;

end architecture;