library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mali is
  generic (
    -- Flag colors definition
    green_color  : integer := 16#1C4#;  -- #0AB737 -> #10C040
    yellow_color : integer := 16#FD1#;  -- #FDD210 -> #F0D010
    red_color    : integer := 16#D12#;  -- #CF0821 -> #D01020
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end mali;

architecture rtl of mali is

begin

  DRAWING : process(i_row, i_column)
  begin
    if i_column <= c_screen_width/3 then
      o_color <= green_color;
    elsif i_column <= 2*c_screen_width/3 then
      o_color <= yellow_color;
    else
      o_color <= red_color;
    end if;
  end process;

end architecture;