library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity my_stopwatch_tb is
end my_stopwatch_tb;

architecture sim of my_stopwatch_tb is

  constant clk_hz : integer := 50e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal stp : std_logic := '1';
  signal cc : unsigned(7 downto 0);
  signal ss : unsigned(7 downto 0);
  signal mm : unsigned(7 downto 0);

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.my_stopwatch(rtl)
  generic map (
    N_tickCycles => 1
  )
  port map (
    clk => clk,
    rst => rst,
    stp => stp,
    cc  => cc,
    ss  => ss,
    mm => mm
  );

  SEQUENCER_PROC : process
  begin
    -- nothing should happen
    wait for clk_period * 2;
    report "Start counting";
    rst <= '0';
    stp <= '0';
    wait for clk_period * 20000; 
    report "Pause counting";
    stp <= '1';
    wait for clk_period * 100;
    report "Continue counting";
    stp <= '0';
    wait for clk_period * 50000;
    report "Restart";
    rst <= '1';
    wait for clk_period * 100;
    report "Continue counting";
    rst <= '0';
    wait;
    -- assert false
    --   report "Replace this with your test cases"
    --   severity failure;

    -- finish;
  end process;

end architecture;