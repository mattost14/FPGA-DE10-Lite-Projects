library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Common constants, types and functions
use work.common.all;

entity brick_wall is
  generic (
    -- Update position every 1 frames
    g_frame_update_cnt : integer := 1 -- Defines "smoothness" of animation
  );
  port (
    i_clock         : in std_logic;
    i_reset_pulse   : in std_logic;
    i_update_pulse  : in std_logic;
    -- Current pixel
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    -- Ball position
    i_ball_pos_x : in integer;
    i_ball_pos_y : in integer;

    o_color   : out integer range 0 to 4095;
    o_draw    : out std_logic;

    o_block_collision       : out std_logic; -- signals if a collision between ball and brick has happened
    o_block_side_collision  : out std_logic  -- signals if the collision was a side collision with the block 
  );
end brick_wall;

architecture rtl of brick_wall is

  
  constant numOfBricksCol_EvenRows    : integer := 40;
  constant numOfBricksCol_OddRows     : integer := 41;
  constant numOfBricksRows            : integer := 30;
  constant numOfOddRows               : integer := numOfBricksRows / 2;
  constant numOfEvenRows              : integer := numOfBricksRows - numOfOddRows;
  constant numOfBricks                : integer := numOfEvenRows*numOfBricksCol_EvenRows + numOfOddRows*numOfBricksCol_OddRows;--1200;

  type brick is
  record
      x : integer range -c_brick_width to c_screen_width-1;
      y : integer range 0 to c_screen_height/2;
      visible : boolean;
  end record;

  type wall is array (0 to numOfBricks-1) of brick;

  signal mywall : wall;

begin

-- Set draw output
process(i_row, i_column, mywall)
variable r_draw_tmp : std_logic := '0';
variable r_color_tmp : integer range 0 to 4095 := 0;
-- variable mat  : t_material := BG;
variable isBrick     : unsigned(numOfBricks-1 downto 0) := (others => '0');
variable isMortar     : unsigned(numOfBricks-1 downto 0) := (others => '0');
begin

    r_draw_tmp := '0';
    r_color_tmp := 0;

    for i in 0 to numOfBricks-1 loop
      if mywall(i).visible then -- check if it pixel is inside the brick or its part of the mortar
        if (i_column >= mywall(i).x and i_column <= mywall(i).x + c_brick_width and i_row >= mywall(i).y and i_row <= mywall(i).y + c_brick_height) then  -- Inside rectangle
          if i_column = mywall(i).x + c_brick_width or i_row = mywall(i).y + c_brick_height then
            isMortar(i) := '1';
            isBrick(i) := '0';
          else
            isMortar(i) := '0';
            isBrick(i) := '1';
          end if;
        else
          isMortar(i) := '0';
          isBrick(i) := '0';
        end if;
      else -- It is not a brick, now check if it is between two visible bricks
        isMortar(i) := '0';
        isBrick(i) := '0';
      end if;
    end loop;

    if isBrick > 0 then      
      r_draw_tmp := '1';
      r_color_tmp := g_brick_color;
    end if;

    if isMortar > 0 then      
      r_draw_tmp := '1';
      r_color_tmp := g_mortar_color;
    end if;

    -- Assign outputs
    o_draw <= r_draw_tmp;
    o_color <= r_color_tmp;
end process;

  -- Update state
  process(i_clock)
  variable r_frame_cnt : integer range 0 to g_frame_update_cnt := 0;
  variable numEvenRows  : integer :=0;
  variable numOddRows   : integer :=0;
  variable idx0         : integer :=0;
  begin
      if rising_edge(i_clock) then
        if i_reset_pulse = '1' then
          -- Initialize Complete Wall
          numEvenRows :=0;
          numOddRows  :=0;
          idx0        :=0;
          for row in 0 to numOfBricksRows-1 loop
            idx0 := numEvenRows*numOfBricksCol_EvenRows + numOddRows*numOfBricksCol_OddRows;
            if row mod 2 = 0 then -- Even Rows: 0, 2, 4....
              for col in 0 to numOfBricksCol_EvenRows-1 loop
                mywall(col + idx0).x <= col*c_brick_width + col;
                mywall(col + idx0).y <= row*c_brick_height + row;
                mywall(col + idx0).visible <= true;
              end loop;
              numEvenRows := numEvenRows + 1;
            else -- Odd Rows: 1, 3, 5....
              for col in 0 to numOfBricksCol_OddRows-1 loop
                mywall(col + idx0).x <= col*c_brick_width+col-c_brick_width/2;
                mywall(col + idx0).y <= row*c_brick_height + row;
                mywall(col + idx0).visible <= true;
              end loop;
              numOddRows := numOddRows + 1;
            end if;
          end loop;

        elsif i_update_pulse = '1' then
            r_frame_cnt := r_frame_cnt + 1;
            o_block_collision <= '0';
            o_block_side_collision <= '0';
              -- Limit position update rate
              if (r_frame_cnt = g_frame_update_cnt) then
                -- check for ball collision into visible bricks
                for i in 0 to numOfBricks-1 loop
                  if mywall(i).visible then 
                    if (mywall(i).x <= i_ball_pos_x + c_ball_width and mywall(i).x + c_brick_width >= i_ball_pos_x and mywall(i).y <= i_ball_pos_y + c_ball_height and mywall(i).y + c_brick_height >= i_ball_pos_y) then
                      mywall(i).visible <= false;
                      o_block_collision <= '1';
                      -- Check if the collision is a side collision by check if the overlap happened close to the brick sides
                      if (i_ball_pos_x + c_ball_width <= mywall(i).x + 2  or i_ball_pos_x >= mywall(i).x + c_brick_width - 2) then
                        o_block_side_collision <= '1';
                      end if;
                    end if;
                  end if;
                end loop;

              end if;
          end if;
      end if;
  end process;

end architecture;