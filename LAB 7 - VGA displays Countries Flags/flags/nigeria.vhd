library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nigeria is
  generic (
    -- Flag colors definition
    green_color  : integer := 16#085#;  -- #04834F -> #008050
    white_color  : integer := 16#FFF#;  -- #FFFFFF -> #F0F0F0
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end nigeria;

architecture rtl of nigeria is

begin

  DRAWING : process(i_row, i_column)
  begin
    if i_column <= c_screen_width/3 then
      o_color <= green_color;
    elsif i_column <= 2*c_screen_width/3 then
      o_color <= white_color;
    else
      o_color <= green_color;
    end if;
  end process;

end architecture;