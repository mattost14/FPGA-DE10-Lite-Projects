library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity Accumulator_top_tb is
end Accumulator_top_tb;

architecture sim of Accumulator_top_tb is

  constant clk_hz : integer := 50e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal KEY : std_logic_vector(1 downto 0) := "11";
  signal HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : std_logic_vector(7 downto 0);
  signal SW  : std_logic_vector(9 downto 0) := (others => '0');
  signal LEDR : std_logic_vector(9 downto 0) := (others => '0');

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.Accumulator_top(rtl)
  port map (
    MAX10_CLK1_50 => clk,
    KEY => KEY,
    LEDR => LEDR,
    SW => SW,
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
    SW <= "0000000001"; 
    wait for clk_period * 2;
    for i in 1 to 10 loop
      report "Add 1";
      KEY(1) <= '0'; -- add button is pressed
      wait for clk_period * 2; 
      KEY(1) <= '1'; -- add button is released
      wait for clk_period * 2;
    end loop;
    wait for clk_period * 2;

    SW <= "0000000000"; 
    wait for clk_period * 2;
    for i in 1 to 10 loop
      report "Add 1";
      KEY(1) <= '0'; -- add button is pressed
      wait for clk_period * 2; 
      KEY(1) <= '1'; -- add button is released
      wait for clk_period * 2;
    end loop;

    report "Change value to 3";
    SW <= "0000000011"; 

    for i in 1 to 10 loop
      report "Add 3";
      KEY(1) <= '0'; -- add button is pressed
      wait for clk_period * 2; 
      KEY(1) <= '1'; -- add button is released
      wait for clk_period * 2;
    end loop;

    report "Reset";
    KEY(0) <= '0'; -- reset is  pressed
    wait for clk_period * 2; 
    finish;
  end process;

end architecture;