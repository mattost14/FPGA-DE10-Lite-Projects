library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Common constants, types and functions
use work.common.all;

entity ball is
  generic (
    -- Play area limits
    g_left_bound : integer := 0;
    g_right_bound : integer := c_screen_width;
    g_upper_bound : integer := 0;
    g_lower_bound : integer := c_screen_height;
    -- Update position every 1 frames
    g_frame_update_cnt : integer := 1; -- Defines "smoothness" of animation
    -- Hysteresis params
    g_min_speed_x : integer := 1;
    g_accel_in_max : integer := 2**8 -- Max input value from accelerometer (absolute value)
  );
  port (
    i_clock         : in std_logic;
    i_reset_pulse   : in std_logic;
    i_new_ball_pulse: in std_logic;
    i_update_pulse  : in std_logic;

    -- Current pixel
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    -- Paddle position
    i_paddle_pos_x : in integer;
    i_paddle_pos_y : in integer;
    -- Block colision
    i_block_collision : in std_logic;
    i_block_side_collision : in std_logic;
    -- Output ball position
    o_pos_x   : out integer;
    o_pos_y   : out integer;
    -- Output ball status
    o_ball_fall : out std_logic;

    o_color   : out integer range 0 to 4095;
    o_draw    : out std_logic
  );
end ball;

architecture rtl of ball is
  -- Constants
  constant c_init_pos_x : integer := (g_right_bound - g_left_bound)/2;
  constant c_init_pos_y : integer := (g_lower_bound - g_upper_bound)/2;

  -- Ball status
  signal ball_fall : std_logic := '0';

  -- States: Position and Velocity
  signal r_xPos : integer range 0 to c_screen_width-1 := c_init_pos_x;
  signal r_yPos : integer range 0 to c_screen_height-1 := c_init_pos_y;
  signal r_xSpeed : integer := 0;
  signal r_ySpeed : integer := 0;
  -- Random Num
  signal random10bitNum : unsigned(9 downto 0);
begin

-- Set draw output
process(i_row, i_column, r_xPos, r_yPos, ball_fall)
variable r_draw_tmp : std_logic := '0';
variable r_color_tmp : integer range 0 to 4095 := 0;
begin
    r_draw_tmp := '0';
    r_color_tmp := 0;

    -- is current pixel coordinate inside our box?
    if (i_column >= r_xPos and i_column <= r_xPos + c_ball_width and i_row >= r_yPos and i_row <= r_yPos + c_ball_height) then  -- Inside rectangle
        r_draw_tmp := '1';
        r_color_tmp := g_ball_color;
    end if;

      -- Disable ball drawing if ball_fall
    if (ball_fall = '1') then
        r_draw_tmp := '0';
        r_color_tmp := 0;
    end if;

    -- Assign outputs
    o_draw <= r_draw_tmp;
    o_color <= r_color_tmp;
end process;

  -- Update state
  process(i_clock)
  -- Vars
  variable r_xPos_new : integer;
  variable r_yPos_new : integer;
  variable r_xSpeed_new : integer;
  variable r_ySpeed_new : integer;
  variable r_frame_cnt : integer range 0 to g_frame_update_cnt := 0;
  begin
      if rising_edge(i_clock) then
          if i_reset_pulse = '1' then
              -- Set initial ball position
              r_xPos <= c_init_pos_x; 
              r_yPos <= c_init_pos_y; 
              -- Set initial ball speed
              r_xSpeed <= 0;
              r_ySpeed <= 2;
              ball_fall <= '0'; 
          elsif i_update_pulse = '1' and i_new_ball_pulse = '1' then
              if random10bitNum > g_right_bound then
                r_xPos <= to_integer(random10bitNum/2);
              else
                r_xPos <= to_integer(random10bitNum);
              end if;
              r_yPos <= c_init_pos_y; 
              r_xSpeed <= 0;
              r_ySpeed <= 2;
              ball_fall <= '0';
          -- Time to update state
          elsif i_update_pulse = '1' and ball_fall='0' then  
              r_frame_cnt := r_frame_cnt + 1;
              -- Limit position update rate
              if (r_frame_cnt = g_frame_update_cnt) then
                  r_frame_cnt := 0;
                  -- Update position with velocity
                  r_xPos_new := r_xPos + r_xSpeed;
                  r_yPos_new := r_yPos + r_ySpeed;

                  r_xSpeed_new := r_xSpeed;
                  r_ySpeed_new := r_ySpeed;

                  -- Check for side bounces
                  if (r_xPos_new + c_ball_width > g_right_bound) then -- Right side bounce
                    r_xPos_new := g_right_bound - c_ball_width;
                    r_xSpeed_new := -abs(r_xSpeed);
                  end if;
                  if (r_xPos_new < g_left_bound) then -- Left side bounce
                    r_xPos_new := g_left_bound;
                    r_xSpeed_new := abs(r_xSpeed);
                  end if;

                  -- Check for upper bounce
                  if (r_yPos_new < g_upper_bound) then -- Upper side bounce
                    r_yPos_new := g_upper_bound;
                    r_ySpeed_new := abs(r_ySpeed);
                  end if;

                  -- Check for Paddle bounce
                  if r_yPos_new + c_ball_height >= i_paddle_pos_y then
                    -- Bounce between 0 and 1/3 of the paddle - (LEFT BOUNCE)
                    if r_xPos_new + c_ball_width > i_paddle_pos_x and r_xPos_new <= i_paddle_pos_x + c_paddle_width/3 then                                     
                      if r_xSpeed > -2 then
                        r_xSpeed_new := r_xSpeed - 1;
                      end if;
                      r_ySpeed_new := -r_ySpeed;
                    -- Between 1/3 and 2/3 of the paddle
                    elsif r_xPos_new + c_ball_width > i_paddle_pos_x + c_paddle_width/3 and r_xPos_new < i_paddle_pos_x + 2*c_paddle_width/3 then
                      r_ySpeed_new := -abs(r_ySpeed);
                    elsif r_xPos_new + c_ball_width >= i_paddle_pos_x + 2*c_paddle_width/3 and r_xPos_new <= i_paddle_pos_x + c_paddle_width then
                      if r_xSpeed < 2 then
                        r_xSpeed_new := r_xSpeed + 1;
                      end if;
                      r_ySpeed_new := -r_ySpeed;
                    end if;
                  end if;

                  -- Check for Block collision
                  if i_block_collision = '1' then
                    r_ySpeed_new := -r_ySpeed;
                    if i_block_side_collision = '1' then
                      r_xSpeed_new := -r_xSpeed;
                    end if;
                  end if;

                  -- Check for falling ball
                  if (r_yPos_new > g_lower_bound) then 
                    ball_fall <= '1';
                  end if;

                  -- Assign new values
                  r_xPos <= r_xPos_new;
                  r_yPos <= r_yPos_new;
                  r_xSpeed <= r_xSpeed_new;
                  r_ySpeed <= r_ySpeed_new;
              end if;
          end if;
      end if;
  end process;

  -- Update output
  o_ball_fall <= ball_fall;
  o_pos_x <= r_xPos;
  o_pos_y <= r_yPos;

  random_gen: entity work.randomNumGen 
  generic map(
    N => 10
  )
  port map (
    clk => i_clock,
    rst => i_reset_pulse,
    gen => '1',
    randomNum => random10bitNum
  );

end architecture;