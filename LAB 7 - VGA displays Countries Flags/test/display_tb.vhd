library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity display_tb is
end display_tb;

architecture sim of display_tb is

  constant clk_hz : integer := 25e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk      : std_logic := '1';
  signal rst_n    : std_logic := '0';
  signal nextFlag : std_logic := '0';
  signal h_sync   : std_logic;
  signal v_sync   : std_logic;
  signal disp_en  : std_logic;
  signal column   : integer range 0 to 640-1;
  signal row      : integer range 0 to 480-1;
  signal red      : std_logic_vector(3 downto 0) := (others => '0');
  signal green    : std_logic_vector(3 downto 0) := (others => '0');
  signal blue     : std_logic_vector(3 downto 0) := (others => '0');
begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.display(rtl)
  port map (
    pixel_clk => clk,
    rst_n     => rst_n,
    nextFlag  => nextFlag,
    disp_en   => disp_en,
		column		=> column,
		row				=> row,
    red       => red,
    green     => green,
    blue      => blue
  );

  U1 : entity work.vga_controller
  port map (
    pixel_clk	=> clk,
		rst_n		  => rst_n,
		h_sync		=> h_sync,
		v_sync		=> v_sync,
		disp_en	  => disp_en,
		column		=> column,
		row				=> row
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;
    rst_n <= '1';

    wait for clk_period * 40000;

    nextFlag <= '1';
    wait for clk_period * 1;
    nextFlag <= '0';

    wait for clk_period * 40000;

    -- for i in 1 to 30 loop
    --   add <= '1';
    --   wait for clk_period0 * 20;
    --   add <= '0';
    --   wait for clk_period0 * 2;
    --   -- value <= value + 1;
    -- end loop;

    finish;
  end process;

end architecture;