library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity usa is
  generic (
    -- Flag colors definition
    white_color  : integer := 16#FFF#;  -- #FFFFFF -> #F0F0F0
    red_color    : integer := 16#B23#;  -- #B22234 -> #B02030
    blue_color   : integer := 16#447#;  -- #3C3B6E -> #404070
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end usa;

architecture rtl of usa is
  type t_point_2d is
  record
      x : integer;
      y : integer;
  end record;


  function star (x : integer; y : integer; x0 : integer; y0 : integer) return std_logic is
    -- This function returns '1' when the pixel coordinates (x,y) corresponds to a internal pixel of a 10px radius 5-point star centered at (x0,y0)
    type listOfInternalPoints is array (0 to 102) of t_point_2d;
    constant p : listOfInternalPoints := ((-9,3),(-8,3),(-7,2),(-7,3),(-6,1),(-6,2),(-5,-7),(-5,-6),(-5,1),(-5,2),(-4,-6),(-4,-5),(-4,-4),(-4,-3),(-4,0),(-4,1),(-4,2),(-3,-5),(-3,-4),(-3,-3),(-3,-2),(-3,-1),(-3,0),(-3,1),(-3,2),(-2,-5),(-2,-4),(-2,-3),(-2,-2),(-2,-1),(-2,0),(-2,1),(-2,2),(-2,3),(-1,-4),(-1,-3),(-1,-2),(-1,-1),(-1,0),(-1,1),(-1,2),(-1,3),(-1,4),(-1,5),(-1,6),(0,-3),(0,-2),(0,-1),(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),(0,7),(0,8),(0,9),(1,-4),(1,-3),(1,-2),(1,-1),(1,0),(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(2,-5),(2,-4),(2,-3),(2,-2),(2,-1),(2,0),(2,1),(2,2),(2,3),(3,-5),(3,-4),(3,-3),(3,-2),(3,-1),(3,0),(3,1),(3,2),(4,-6),(4,-5),(4,-4),(4,-3),(4,0),(4,1),(4,2),(5,-7),(5,-6),(5,1),(5,2),(6,1),(6,2),(7,2),(7,3),(8,3),(9,3));
    variable xp, yp : integer; 

  begin 
    -- Position relative to star center
    xp := x - x0;
    yp := y - y0;

    -- check if pixel coordinates is equal to any of the internal pixels
    for i in 0 to 102 loop
      if xp = p(i).x and yp = -p(i).y then
        return '1';
      end if;
    end loop;

    return '0';
  end function;

  -- Flag parameters definition (standard US flag proportions)
  constant A  :  integer := 337;        -- Flag height
  constant B  :  integer := 640;        -- Flag widht
  constant C  :  integer := 182;--7*A/13;     -- Blue square height - 181.4
  constant D  :  integer := 76*A/100;   -- Blue square widht  - 256.2
  constant E  :  integer := 54*A/1000;  -- Vertical pad       - 8.08
  constant F  :  integer := 54*A/1000;  -- Vertical distance between stars  - 8.08
  constant G  :  integer := 63*A/1000;  -- Horizontal pad   =21.2
  constant H  :  integer := 63*A/1000;  -- Horizontal distance between stars =21.2
  constant L  :  integer := 26;--A/13;       -- Stripe widht =25.9
  -- Screen vertical offset to center the flag 
  constant offset  : integer := 70; -- Top screen offset (70)
begin

  DRAWING : process(i_row, i_column)
  variable x_star, y_star : integer range 0 to 365;
  variable isStar : std_logic_vector(0 to 29);    -- flag array for 6-stars rows
  variable isStar2 : std_logic_vector(0 to 19);   -- flag array for 5-stars rows
  begin
    
    if i_row > offset and i_row < A + offset then
      -- Blue Star Region of the US flag
      if i_column <= D and i_row - offset < C then

        -- 6 Stars Rows
        for col in 0 to 5 loop
          for row in 0 to 4 loop
            x_star := G + 2*H*col;
            y_star := E + 2*F*row;
            isStar(col+row*6) := star(i_column, i_row-offset, x_star, y_star);
          end loop;
        end loop;

        if unsigned(isStar) > 0 then -- check if the pixel is inside any of the 30 stars of the 6-stars rows
          o_color <= white_color;
        else  -- check the 5-stars rows
          -- 5 Stars Rows
          for col in 0 to 4 loop
            for row in 0 to 3 loop
              x_star := G+H + 2*H*col;
              y_star := E+F + 2*F*row;
              isStar2(col+row*5) := star(i_column, i_row-offset, x_star, y_star);
            end loop;
          end loop;

          if unsigned(isStar2) > 0 then -- check if the pixel is inside any of the 20 stars of the 5-stars rows
            o_color <= white_color;
          else
            o_color <= blue_color;
          end if;
        end if;
      else
      -- Red and White Stripes
        if  ((i_row-offset)/L) mod 2 = 0 then
          o_color <= red_color;
        else
          o_color <= white_color;
        end if;
      end if;
    else -- Top and bottom black gap
      o_color <= 16#000#;
    end if;

  end process;

end architecture;