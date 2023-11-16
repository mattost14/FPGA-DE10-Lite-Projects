-- paddle: Logic and graphics generation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Common constants, types and functions
use work.common.all;

entity paddle is
  generic (
    -- Play area limits
    g_left_bound : integer := 0;
    g_right_bound : integer := c_screen_width;
    -- Update position every 1 frames
    g_frame_update_cnt : integer := 1; -- Defines "smoothness" of animation
    g_speed_scale_x : integer := 10; -- Defines the speed range for the tilt, higher value = faster paddle movement for same tilt
    -- Hysteresis params
    g_min_speed_x : integer := 1;
    g_accel_in_max : integer := 2**8 -- Max input value from accelerometer (absolute value)
  );
  port (
    i_clock         : in std_logic;
    i_reset_pulse   : in std_logic;
    i_update_pulse  : in std_logic;
    i_accel_scale_x : in integer;

    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;

    o_pos_x   : out integer;
    o_pos_y   : out integer;

    o_color   : out integer range 0 to 4095;
    o_draw    : out std_logic
  );
end paddle;

architecture rtl of paddle is
  -- Constants
  constant c_init_pos_x : integer := (g_right_bound - g_left_bound)/2;
  constant c_init_pos_y : integer := c_screen_height-5;

  -- States: Position and Velocity
  signal r_xPos : integer range 0 to c_screen_width-1 := c_init_pos_x;
  signal r_yPos : integer range 0 to c_screen_height-1 := c_init_pos_y;
  signal r_xSpeed : integer := 0;
begin

  -- Set draw output
  process(i_row, i_column, r_xPos, r_yPos)
      variable r_draw_tmp : std_logic := '0';
      variable r_color_tmp : integer range 0 to 4095 := 0;
  begin

      r_draw_tmp := '0';
      r_color_tmp := 0;

      -- is current pixel coordinate inside our box?
      if (i_column >= r_xPos and i_column <= r_xPos+c_paddle_width and i_row >= r_yPos and i_row <= r_yPos+c_paddle_height) then  -- Inside rectangle
          r_draw_tmp := '1';
          r_color_tmp := g_paddle_color;
      end if;
      
      -- Assign outputs
      o_draw <= r_draw_tmp;
      o_color <= r_color_tmp;
  end process;

  -- Update state
  process(i_clock)
  -- Vars
  variable r_xPos_new : integer;
  variable r_frame_cnt : integer range 0 to g_frame_update_cnt := 0;
  begin
      if rising_edge(i_clock) then
        if i_reset_pulse = '1' then
            r_xPos <= c_init_pos_x;      
          -- Time to update state
        elsif i_update_pulse = '1' then
            r_frame_cnt := r_frame_cnt + 1;
              -- Limit position update rate
              if (r_frame_cnt = g_frame_update_cnt) then
                  r_frame_cnt := 0;
                  -- Update position with velocity
                  r_xPos_new := r_xPos + r_xSpeed;
                  -- Check bounds and clip
                  -- X bounds
                  if (r_xPos_new + c_paddle_width > g_right_bound) then
                      r_xPos_new := g_right_bound - c_paddle_width;
                  end if;
                  if (r_xPos_new < g_left_bound) then
                      r_xPos_new := g_left_bound;
                  end if;
                  -- Assign new values
                  r_xPos <= r_xPos_new;
              end if;
          end if;
      end if;
  end process;


  -- Set paddle speed from user input
  process(i_accel_scale_x)
  -- Vars
  variable r_xSpeed_new : integer;
  begin
      -- Scaled 0 to g_speed_scale
      r_xSpeed_new := abs(i_accel_scale_x) * g_speed_scale_x / g_accel_in_max;
      -- Hysteresis, require a tilt of a certain steepness before any movement occurs
      if (r_xSpeed_new < g_min_speed_x) then
          r_xSpeed_new := 0;
      end if;
      -- Direction of tilt
      -- x+ : left,    x- : right
      -- Negative speed means LEFT 
      if (i_accel_scale_x > 0) then
          r_xSpeed_new := -r_xSpeed_new;
      end if;
      -- Assign new values
      r_xSpeed <= r_xSpeed_new;
  end process;

    -- State Outputs
    o_pos_x <= r_xPos;
    o_pos_y <= r_yPos;

end architecture;