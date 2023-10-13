library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SEG7_LUT is
  generic (
    decimalPoint : std_logic := '0'
  );
  port (
    i_Digit : in unsigned(3 downto 0);
    oSEG    : out std_logic_vector(7 downto 0)
  );
end SEG7_LUT;

architecture rtl of SEG7_LUT is
begin
  process(i_Digit)
  begin
    case i_Digit is
      when x"1" => oSEG <= "11111001";    -- F9
      when x"2" => oSeg <= "10100100"; 	  -- A4
      when x"3" => oSeg <= "10110000"; 	  -- B0
      when x"4" => oSeg <= "10011001"; 	  -- 99
      when x"5" => oSeg <= "10010010"; 	  -- 92
      when x"6" => oSeg <= "10000010"; 	  -- 82
      when x"7" => oSeg <= "11111000"; 	  -- F8
      when x"8" => oSeg <= "10000000"; 	  -- 80
      when x"9" => oSeg <= "10011000"; 	  -- 98
      when x"A" => oSeg <= "10001000";    -- 88
      when x"B" => oSeg <= "10000011";    -- 83
      when x"C" => oSeg <= "11000110";    -- C6
      when x"D" => oSeg <= "10100001";    -- A1
      when x"E" => oSeg <= "10000110";    -- 86
      when x"F" => oSeg <= "10001110";    -- 8E
      when x"0" => oSeg <= "11000000";    -- C0
      when others => oSEG  <= "10000000"; -- 80 
    end case;

    if decimalPoint = '1' then -- enable decimal point
      oSEG(7) <= '0';
    end if;

  end process;
end architecture;
