library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity ButtonDebounce_tb is
end ButtonDebounce_tb;

architecture sim of ButtonDebounce_tb is

  constant clk_hz : integer := 50e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '0';
  signal input : std_logic := '0';
  signal debounce : std_logic := '0';
begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.ButtonDebounce(rtl)
  generic map(
    delay => 5
  )
  port  map(
    clk  => clk,
    rst  => rst,
    input => input,
    debounce  => debounce
  );


  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;
    rst <= '1';
    wait for clk_period * 2;
    rst <= '0';
    wait for clk_period * 2;
    input <= '1';
    wait for clk_period * 100;
    input <= '0';
    wait for clk_period * 40;
    input <= '1';
    wait for clk_period * 100;
    input <= '0';
    wait for clk_period * 100;

    finish;
  end process;

end architecture;