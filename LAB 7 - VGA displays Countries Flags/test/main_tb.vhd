library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity main_tb is
end main_tb;

architecture sim of main_tb is

  constant clk_hz : integer := 1e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

  signal KEY      : std_logic_vector(1 downto 0);
  signal rst_n    : std_logic := '0';
  signal nextFlag : std_logic := '0';
  signal h_sync   : std_logic;
  signal v_sync   : std_logic;
  signal red      : std_logic_vector(3 downto 0) := (others => '0');
  signal green    : std_logic_vector(3 downto 0) := (others => '0');
  signal blue     : std_logic_vector(3 downto 0) := (others => '0');
  signal HEX0, HEX1 : std_logic_vector(7 downto 0);

begin

  clk <= not clk after clk_period / 2;

  KEY(0) <= rst_n;
  KEY(1) <= not nextFlag;

  DUT : entity work.main(rtl)
  port map (
    MAX10_CLK1_50   => clk,
    KEY             => KEY,  
    VGA_HS          => h_sync, 	       
    VGA_VS	        => v_sync,    
    VGA_R           => red,   
    VGA_G           => green,         
    VGA_B           => blue,
    HEX0        => HEX0,
    HEX1        => HEX1        
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;
    rst_n <= '1';

    wait for clk_period * 40000;

    nextFlag <= '1';
    wait for clk_period * 500;
    nextFlag <= '0';

    wait for clk_period * 40000;

    finish;
  end process;

end architecture;