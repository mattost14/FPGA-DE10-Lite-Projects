library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chad is
  generic (
    -- Flag colors definition
    blue_color    : integer := 16#027#;  -- #002569 -> #002070
    yellow_color  : integer := 16#FD0#;  -- #FECE00 -> #F0D000
    red_color     : integer := 16#D13#;  -- #D31034 -> #D01030
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end chad;

architecture rtl of chad is

begin

  DRAWING : process(i_row, i_column)
  begin
    if i_column <= c_screen_width/3 then
      o_color <= blue_color;
    elsif i_column <= 2*c_screen_width/3 then
      o_color <= yellow_color;
    else
      o_color <= red_color;
    end if;
  end process;

end architecture;