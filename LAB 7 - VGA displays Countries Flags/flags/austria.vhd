library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity austria is
  generic (
    -- Flag colors definition
    white_color  : integer := 16#FFF#;  -- #FFFFFF -> #F0F0F0
    red_color    : integer := 16#E14#;  -- #DC0C3A -> #E01040
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end austria;

architecture rtl of austria is

begin

  DRAWING : process(i_row, i_column)
  begin
    if i_row <= c_screen_height/3 then
      o_color <= red_color;
    elsif i_row <= 2*c_screen_height/3 then
      o_color <= white_color;
    else
      o_color <= red_color;
    end if;
  end process;

end architecture;