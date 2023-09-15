library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity my_counter_tb is
end my_counter_tb;

architecture sim of my_counter_tb is

  constant clk_hz : integer := 50e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal count : std_logic_vector(9 downto 0);

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.my_counter(rtl)
  generic map (
    N => 10
  )
  port map (
    clk => clk,
    rst => rst,
    count => count
  );

  SEQUENCER_PROC : process
  begin
    rst <= '1';
    wait for clk_period * 2;
    rst <= '0';
    wait for clk_period * 2;
    rst <= '1';
    wait;
    -- wait for clk_period * 10;
    -- assert false
    --   report "Replace this with your test cases"
    --   severity failure;

    -- finish;
  end process;

end architecture;