-- common: Package defining constants, types and functions that are commonly used 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common is
  -- Screen
  constant c_screen_width : integer := 640;
  constant c_screen_height : integer := 480;
  -- Game
  constant c_initial_lives : integer := 5;
  -- Colors
  constant g_bg_color      : integer := 16#000#;
  constant g_paddle_color  : integer := 16#941#;  -- #904010
  constant g_brick_color   : integer := 16#C44#;  -- #C04040
  constant g_mortar_color  : integer := 16#FFF#;  -- #FFFFFF 
  constant g_ball_color    : integer := 16#FFF#;  -- #FFFFFF 
  -- Paddle Size
  constant c_paddle_width : integer := 40;
  constant c_paddle_height : integer := 5;
end package;

package body common is

end package body;