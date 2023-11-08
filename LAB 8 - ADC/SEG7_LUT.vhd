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
      when x"2" => oSeg <= "10100100"; 	
      when x"1" => oSEG <= "11111001";
      when x"3" => oSeg <= "10110000"; 	
      when x"4" => oSeg <= "10011001"; 	
      when x"5" => oSeg <= "10010010"; 	
      when x"6" => oSeg <= "10000010"; 	
      when x"7" => oSeg <= "11111000"; 	
      when x"8" => oSeg <= "10000000"; 	
      when x"9" => oSeg <= "10011000"; 	
      when x"A" => oSeg <= "10001000";
      when x"B" => oSeg <= "10000011";
      when x"C" => oSeg <= "11000110";
      when x"D" => oSeg <= "10100001";
      when x"E" => oSeg <= "10000110";
      when x"F" => oSeg <= "10001110";
      when x"0" => oSeg <= "11000000"; 
      when others => oSEG  <= "10000000";   
    end case;

    if decimalPoint = '1' then -- enable decimal point
      oSEG(7) <= '0';
    end if;

  end process;
end architecture;
