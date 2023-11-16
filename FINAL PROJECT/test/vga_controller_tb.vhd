library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity vga_controller_tb is
end vga_controller_tb;

architecture sim of vga_controller_tb is

  constant clk_hz : integer := 25e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

  signal VGA_HS   : std_logic;
  signal VGA_VS   : std_logic;
  signal disp_en  : std_logic;
  signal column   : integer range 0 to 640-1;
  signal row      : integer range 0 to 480-1;


  signal r_disp_en_d : std_logic := '0';   -- Registered disp_en input
  signal r_disp_en_fe : std_logic;         -- Falling edge of disp_en input
  signal r_logic_update : std_logic := '0'; 
begin

  clk <= not clk after clk_period / 2;

  r_disp_en_d <= disp_en when rising_edge(clk); -- DFF
  r_disp_en_fe <= r_disp_en_d and not disp_en;   -- One-cycle strobe

  DUT  : entity work.vga_controller
  port map (
    pixel_clk	  => clk,
    reset_n		  => '1',
    h_sync		  => VGA_HS,
    v_sync		  => VGA_VS,
    disp_ena	  => disp_en,
    column		  => column,
    row				  => row
  );

  process(clk)
  begin
      if rising_edge(clk) then
          -- Just finished drawing frame, command a logical update
          if (r_disp_en_fe = '1' and row = 480-1 and column = 640-1) then
              r_logic_update <= '1';
          else
              r_logic_update <= '0';
          end if;
      end if;
  end process;



  SEQUENCER_PROC : process
  begin
    wait for 420000 * 2* clk_period;

    finish;
  end process;

end architecture;