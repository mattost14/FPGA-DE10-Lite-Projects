library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Common constants, types and functions
use work.common.all;

entity display is
  port (
    -- Pixel Clock
    i_pixel_clk   : in std_logic;
    --  User Inputs
    i_KEY       : in std_logic_vector(1 downto 0);
    i_accel_scale_x, i_accel_scale_y : in integer;
    -- VGA controller inputs
    i_disp_en   : in std_logic;                                   --display enable ('1' = display time, '0' = blanking time)
		i_column		:	in	integer range 0 to c_screen_width-1;		  --horizontal pixel coordinate
		i_row				:	in	integer range 0 to c_screen_height-1;			--vertical pixel coordinate
    -- Color outputs to VGA
    o_red      :  out std_logic_vector(3 downto 0) := (others => '0');  --red magnitude output to DAC
    o_green    :  out std_logic_vector(3 downto 0) := (others => '0');  --green magnitude output to DAC
    o_blue     :  out std_logic_vector(3 downto 0) := (others => '0');  --blue magnitude output to DAC
    -- 7-Segment Display outputs
    o_HEX0  : out std_logic_vector(7 downto 0)
  );
end display;

architecture rtl of display is

  -- Types
  type t_state is (ST_NEW_GAME, ST_PLAY, ST_LOST_BALL, ST_NEW_BALL, ST_GAME_OVER);

  -- Game Signals
  signal r_game_state   : t_state := ST_NEW_GAME;
  signal r_num_lives    : integer range 0 to c_initial_lives := c_initial_lives;
  signal r_lost_ball    : std_logic := '0'; 
  signal r_new_ball    : std_logic := '0'; 
  signal r_logic_update : std_logic := '0'; 
  signal r_obj_reset    : std_logic := '0';
  signal r_game_over    : std_logic := '0';
  signal r_obj_update   : std_logic := '1';
  -- signal r_game_active  : std_logic := '0';

  -- Paddle Signals
  signal w_paddle_pos_x : integer;
  signal w_paddle_pos_y : integer;
  signal w_paddleDraw   : std_logic;
  signal w_paddleColor  : integer range 0 to 4095;

  -- Ball Signals
  signal w_block_collision  : std_logic := '0';
  signal w_ball_fall    : std_logic := '0';
  signal w_ball_pos_x : integer;
  signal w_ball_pos_y : integer;
  signal w_ballDraw   : std_logic;
  signal w_ballColor  : integer range 0 to 4095;
  signal w_brickDraw   : std_logic;
  signal w_brickColor  : integer range 0 to 4095;


  -- Control signals
  signal r_disp_en_d : std_logic := '0';   -- Registered disp_en input
  signal r_disp_en_fe : std_logic;         -- Falling edge of disp_en input
  signal r_key_d : std_logic_vector(1 downto 0);
  signal r_key_press : std_logic_vector(1 downto 0); -- Pulse, keypress event

  -- 7-Segment Display Lookup Table
  type RAM is array (0 to 15) of std_logic_vector(7 downto 0);
  constant lut : RAM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"98", X"88", X"83", X"C6", X"A1", X"86", X"8E");
  
begin

    -- Concurrent assignments
    -- disp_en falling edge
    r_disp_en_d <= i_disp_en when rising_edge(i_pixel_clk); -- DFF
    r_disp_en_fe <= r_disp_en_d and not i_disp_en;   -- One-cycle strobe

    -- KEY falling edge
    r_key_d <= i_KEY when rising_edge(i_pixel_clk) and r_logic_update='1'; -- DFF, value of keys at last logical update
    r_key_press <= r_key_d and not i_KEY;   -- One-cycle strobe, for next logical update

    -- Display Country Number in the 7-Segment Display
    o_HEX0 <= lut(r_num_lives);

    -- Handle lives
    process(i_pixel_clk)
    begin   
        if rising_edge(i_pixel_clk) and r_logic_update = '1' and r_lost_ball = '0' then
            if r_obj_reset = '1' then
              r_num_lives <= c_initial_lives;
            elsif w_ball_fall = '1' then
              if r_num_lives > 0 then
                r_num_lives <= r_num_lives-1;
              end if;
            end if;   
        end if;
    end process;

    -- Main game FSM
    process(i_pixel_clk)
    begin
        if rising_edge(i_pixel_clk) and r_logic_update = '1' then
            if i_KEY(0) = '0' then
              r_game_state  <= ST_NEW_GAME;
              r_lost_ball <= '0';
              r_obj_reset   <= '1';
              r_game_over   <= '0';
            else
              case r_game_state is
                  when ST_NEW_GAME =>
                    r_obj_reset   <= '0';
                    r_game_state <= ST_PLAY;
                  when ST_PLAY => 
                    if w_ball_fall = '1' then
                      r_lost_ball <= '1';
                      r_game_state <= ST_LOST_BALL;
                    else
                      r_game_state <= ST_PLAY;
                    end if;
                  when ST_LOST_BALL => 
                    if r_num_lives = 0 then
                      r_game_state <= ST_GAME_OVER;
                    elsif i_KEY(1) = '0'  then
                      r_new_ball <= '1';
                      r_lost_ball <= '0';
                      r_game_state <= ST_NEW_BALL;
                    else
                      r_game_state <= ST_LOST_BALL;
                    end if;
                  when ST_NEW_BALL => 
                    r_new_ball <= '0';
                    r_game_state <= ST_PLAY;
                  when ST_GAME_OVER => 
                    r_game_state <= ST_GAME_OVER;
                    r_game_over <= '1';
              end case;
            end if;
        end if;
    end process;

  -- Combi-Logic, draw each pixel for current frame
  process(i_disp_en, i_row, i_column)
  -- Variables
  variable pix_color_tmp  : integer range 0 to 4095 := 0;
  variable pix_color_slv  : std_logic_vector(11 downto 0) := (others => '0');
  begin
    -- Display time
    if i_disp_en = '1' then
      -- Background
      pix_color_tmp := g_bg_color;
      -- Render each object
      if (w_paddleDraw = '1') then
          pix_color_tmp := w_paddleColor;
      end if;
      if (w_ballDraw = '1') then
        pix_color_tmp := w_ballColor;
      end if;
      if (w_brickDraw = '1') then
        pix_color_tmp := w_brickColor;
      end if;
    -- Blanking time
    else                           
      pix_color_tmp := 0;
    end if;

    -- Assign from variables into real signals
    pix_color_slv := std_logic_vector(to_unsigned(pix_color_tmp, pix_color_slv'LENGTH));
    o_red   <= pix_color_slv(11 downto 8);
    o_green <= pix_color_slv(7 downto 4);
    o_blue  <= pix_color_slv(3 downto 0);
      
  end process;

  -- Update game state at end of each frame
  process(i_pixel_clk)
  begin
      if rising_edge(i_pixel_clk) then
          -- Just finished drawing frame, command a logical update
          if (r_disp_en_fe = '1' and i_row = c_screen_height-1 and i_column = c_screen_width-1) then
              r_logic_update <= '1';
          else
              r_logic_update <= '0';
          end if;
      end if;
  end process;

  -- Object update signals
  r_obj_update <= r_logic_update and not r_game_over;

  -- Game objects
  paddle_obj: entity work.paddle port map(
      i_clock         => i_pixel_clk,
      i_reset_pulse   => r_obj_reset,
      i_update_pulse  => r_obj_update,
      i_accel_scale_x => i_accel_scale_x,
      i_row           => i_row,
      i_column        => i_column,
      o_pos_x         => w_paddle_pos_x,
      o_pos_y         => w_paddle_pos_y,
      o_color         => w_paddleColor,
      o_draw          => w_paddleDraw
  );

  ball_obj: entity work.ball port map(
    i_clock           => i_pixel_clk,
    i_reset_pulse     => r_obj_reset,
    i_new_ball_pulse  => r_new_ball,
    i_update_pulse    => r_obj_update,
    i_row             => i_row,
    i_column          => i_column,
    i_paddle_pos_x    => w_paddle_pos_x,
    i_paddle_pos_y    => w_paddle_pos_y,
    i_block_collision => w_block_collision,
    o_pos_x           => w_ball_pos_x,
    o_pos_y           => w_ball_pos_y,
    o_ball_fall       => w_ball_fall,
    o_color           => w_ballColor,
    o_draw            => w_ballDraw
);

  brick_wall_obj: entity work.brick_wall port map(
  i_clock           => i_pixel_clk,
  i_reset_pulse     => r_obj_reset,
  i_update_pulse    => r_obj_update,
  i_row             => i_row,
  i_column          => i_column,
  i_ball_pos_x      => w_ball_pos_x,
  i_ball_pos_y      => w_ball_pos_y,
  o_color           => w_brickColor,
  o_draw            => w_brickDraw,
  o_block_collision => w_block_collision
);


end architecture;