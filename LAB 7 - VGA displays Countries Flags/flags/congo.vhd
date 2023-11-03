library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity congo is
  generic (
    -- Flag colors definition
    green_color  : integer := 16#1A5#;  -- #109647 -> #10A050
    yellow_color : integer := 16#FE5#;  -- #F9E04A -> #F0E050
    red_color    : integer := 16#E32#;  -- #DC2726 -> #E03020
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    i_row     : in integer range 0 to c_screen_height-1;
    i_column  : in integer range 0 to c_screen_width-1;
    o_color   : out integer range 0 to 4095
  );
end congo;

architecture rtl of congo is

begin

  DRAWING : process(i_row, i_column)
  begin
    -- Slant Line 1
    -- y = -(480/(640-214))x + 480 -> 213*y = -240*x + 102240
    -- Slant Line 2
    -- 213*y = -240*(x-214) + 102240
    if 213*i_row <= -240*i_column + 102240 then  -- green
      o_color <= green_color;
    elsif 213*i_row <= -240*(i_column-214) + 102240 then -- yellow
      o_color <= yellow_color;
    else -- red             
      o_color <= red_color;
    end if;
  end process;

end architecture;