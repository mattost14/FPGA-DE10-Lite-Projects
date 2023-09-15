library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_counter is
  generic (
    N : integer := 10  -- number of bits to store the counting number
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    count : out std_logic_vector((N-1) downto 0)
  );
  constant numberClkTicksToCount : integer := 25_000_000; -- For a clock at 50Mhz, 25M ticks -> 2Hz
end my_counter;

architecture rtl of my_counter is
  signal ticks : unsigned(24 downto 0); 
  signal counts : unsigned((N-1) downto 0); 
begin

  -- process (clk, rst) is
  -- begin
  --   if rst = '0' then
  --     ticks <= (others => '0');
  --     counts <= (others => '0');
  --   elsif ticks = numberClkTicksToCount then 
  --     counts <= counts + 1;
  --     ticks <= (others => '0');
  --   elsif rising_edge(clk) then
  --     ticks <= ticks + 1;
  --   end if;
  -- end process;

  process (clk, rst) is
    begin
      if rising_edge(clk) then
        if rst = '0' then
          ticks <= (others => '0');
          counts <= (others => '0');
        else
          ticks <= ticks + 1;
        end if;
        -- If ticks reach the maximum ticks to count, then increment 1 to count and reset ticks
        if ticks = numberClkTicksToCount then 
          counts <= counts + 1;
          ticks <= (others => '0');
        end if;
      end if;
    end process;

  count <= std_logic_vector(counts);

end architecture;