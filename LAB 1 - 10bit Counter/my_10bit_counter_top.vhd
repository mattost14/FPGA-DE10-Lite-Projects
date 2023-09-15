library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_10bit_counter_top is
  port (
    MAX10_CLK1_50 : in std_logic;
    KEY : in std_logic_vector(1 downto 0);
    LEDR : out std_logic_vector(9 downto 0)
  );
end my_10bit_counter_top;

architecture rtl of my_10bit_counter_top is
begin

  u0 : entity work.my_counter 
  generic map (N => 10)
  port map (clk => MAX10_CLK1_50, rst => KEY(0), count => LEDR);

end architecture;