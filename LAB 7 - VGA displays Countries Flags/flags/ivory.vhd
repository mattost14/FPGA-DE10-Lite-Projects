library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ivory is
  generic (
    -- Flag colors definition
    green_color     : integer := 16#1A6#;  -- #0E9D62 -> #10A060
    white_color     : integer := 16#FFF#;  -- #FFFFFF -> #F0F0F0
    orange_color    : integer := 16#F94#;  -- #FF8A3C -> #F09040
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end ivory;

architecture rtl of ivory is

begin

  DRAWING : process(i_row, i_column)
  begin
    if i_column <= c_screen_width/3 then
      o_color <= orange_color;
    elsif i_column <= 2*c_screen_width/3 then
      o_color <= white_color;
    else
      o_color <= green_color;
    end if;
  end process;

end architecture;