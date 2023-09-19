library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_stopwatch is
  port (
    clk : in std_logic;
    rst : in std_logic;
    stp : in std_logic;
    hh : out unsigned(19 downto 0) -- output signal - hundreds of a second
  );
end my_stopwatch;

architecture rtl of my_stopwatch is
  signal ticks : unsigned(19 downto 0);
  signal hh_count : unsigned(19 downto 0);

begin
  
  process(clk, rst, stp)
  begin
    if rising_edge(clk) then
      if rst = '1' and stp ='0' then
        hh_count <= (others => '0');
        ticks <= (others => '0');
      else
        ticks <= ticks + 1;
      end if;
    end if;
  end process;

  process(ticks)
  begin
    if ticks = 500_000 then
      hh_count <= hh_count + 1;
    end if;
  end process;
end architecture;