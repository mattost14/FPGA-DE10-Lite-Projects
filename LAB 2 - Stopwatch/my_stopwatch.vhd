library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_stopwatch is
  generic (
    N_tickCycles : integer := 500_000  -- this define the number of ticks to increment the cc counter
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    stp : in std_logic;
    cc : out unsigned(7 downto 0);
    ss : out unsigned(7 downto 0);
    mm : out unsigned(7 downto 0)
  );
end my_stopwatch;

architecture rtl of my_stopwatch is
  -- signal ticks : unsigned(19 downto 0) := (others => '0');
  signal cc_count : unsigned(7 downto 0);
  signal ss_count : unsigned(7 downto 0);
  signal mm_count : unsigned(7 downto 0);
begin
  
  process(clk, rst, stp) is
    variable ticks : unsigned(19 downto 0);
  begin
    if rst = '1' then -- Reset is pressed!
        -- Reset the Watch
        ticks := (others => '0');
        cc_count <= (others => '0');
        ss_count <= (others => '0');
        mm_count <= (others => '0');
    elsif rising_edge(clk) and stp ='0' then
      if ticks = (N_tickCycles-1) then
        ticks := (others => '0');
        if cc_count < 99 then
          cc_count <= cc_count + 1;
        else
          cc_count <= (others => '0');
          if ss_count < 59 then
            ss_count <= ss_count + 1;
          else
            ss_count <= (others => '0');
            if mm_count < 99 then
              mm_count <= mm_count + 1;
            else
              mm_count <= (others => '0');
            end if;
          end if;
        end if;
      else
        ticks := ticks + 1;
      end if;
    end if;
    -- end if;
  end process;


  cc <= cc_count;
  ss <= ss_count;
  mm <= mm_count;

end architecture;