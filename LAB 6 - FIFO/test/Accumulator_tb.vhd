library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity Accumulator_tb is
end Accumulator_tb;

architecture sim of Accumulator_tb is

  constant clk_hz0 : integer := 5e6;
  constant clk_period0 : time := 1 sec / clk_hz0;

  constant clk_hz1 : integer := 125e5;
  constant clk_period1 : time := 1 sec / clk_hz1;

  -- Clocks
  signal clk0 : std_logic := '1';
  signal clk1 : std_logic := '1';
  -- Buttons
  signal rst      : std_logic := '1';
  signal add      : std_logic := '0';
  -- Input value
  signal value    : unsigned(9 downto 0) := "0000000001";
  -- Accumulated value
  signal acc      : unsigned(23 downto 0) := (others => '0');
  -- FIFO signals
  -- signal aclr	    : std_logic;
  -- signal data	    : std_logic_vector(9 downto 0);
  -- signal rdreq	  : std_logic;
  -- signal wrreq	  : std_logic;
  -- signal q	      : std_logic_vector(9 downto 0);
  -- signal rdempty	: std_logic;
  -- signal wrfull	  : std_logic;
begin

  clk0 <= not clk0 after clk_period0 / 2;
  clk1 <= not clk1 after clk_period1 / 2;


  DUT : entity work.Accumulator(rtl)
  port map (
    clk0 => clk0,
    clk1 => clk1,
    rst => rst,
    add => add,
    value => value,
    acc => acc
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period0 * 2;
    rst <= '0';
    wait for clk_period0 * 10;


    for i in 1 to 30 loop
      add <= '1';
      wait for clk_period0 * 20;
      add <= '0';
      wait for clk_period0 * 2;
      -- value <= value + 1;
    end loop;

    wait for clk_period0 * 5;
    rst <= '1';
    wait for clk_period0 * 5;
    rst <= '0';
    wait for clk_period0 * 10;
    finish;
  end process;

end architecture;