library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity germany is
  generic (
    -- Flag colors definition
    black_color  : integer := 16#000#;  -- #000000 -> #000000
    yellow_color : integer := 16#FD3#;  -- #FDDB1F -> #F0D030
    red_color    : integer := 16#F34#;  -- #EF303E -> #F03040
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end germany;

architecture rtl of germany is

begin

  DRAWING : process(i_row, i_column)
  begin
    if i_row <= c_screen_height/3 then
      o_color <= black_color;
    elsif i_row <= 2*c_screen_height/3 then
      o_color <= red_color;
    else
      o_color <= yellow_color;
    end if;
  end process;

end architecture;