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
    cc_0 : out unsigned(3 downto 0);
    cc_1 : out unsigned(3 downto 0);
    ss_0 : out unsigned(3 downto 0);
    ss_1 : out unsigned(3 downto 0);
    mm_0 : out unsigned(3 downto 0);
    mm_1 : out unsigned(3 downto 0)
  );
end my_stopwatch;

architecture rtl of my_stopwatch is
  -- signal ticks : unsigned(19 downto 0) := (others => '0');
  signal cc_count_0 : unsigned(3 downto 0);
  signal cc_count_0_roll : std_logic;
  signal cc_count_1 : unsigned(3 downto 0);
  signal cc_count_1_roll : std_logic;
  signal ss_count_0 : unsigned(3 downto 0);
  signal ss_count_0_roll : std_logic;
  signal ss_count_1 : unsigned(3 downto 0);
  signal ss_count_1_roll : std_logic;
  signal mm_count_0 : unsigned(3 downto 0);
  signal mm_count_0_roll : std_logic;
  signal mm_count_1 : unsigned(3 downto 0);
  signal mm_count_1_roll : std_logic;
begin
  
  process(clk, rst, stp, mm_count_1_roll) is
    variable ticks : unsigned(19 downto 0);
  begin
    if rst = '1' or mm_count_1_roll ='1' then -- Reset is pressed!
        -- Reset the Watch
        cc_count_0 <= (others => '0');
        cc_count_0_roll <= '0';
        ticks := (others => '0');
    elsif rising_edge(clk) and stp ='0' then
    -- if rising_edge(clk) then
    --   if rst = '1' or mm_count_1_roll ='1' then -- Reset is pressed!
    --     -- Reset the Watch
    --     cc_count_0 <= (others => '0');
    --     cc_count_0_roll <= '0';
    --     ticks := (others => '0');
        
      -- elsif stp = '0' then -- Go is pressed!
        if ticks = (N_tickCycles-1) then
          if cc_count_0 = 9 then 
            cc_count_0 <= (others => '0');
            cc_count_0_roll <= '1';
          else 
            cc_count_0 <= cc_count_0 + 1;
            cc_count_0_roll <= '0';
          end if;
          ticks := (others => '0');
        else
          ticks := ticks + 1;
        end if;
      end if;
    -- end if;
  end process;

  process(cc_count_0_roll, rst, mm_count_1_roll)
  begin
    if rst = '1' or mm_count_1_roll ='1' then
      cc_count_1 <= (others => '0');
      cc_count_1_roll <= '0';
    elsif cc_count_0_roll = '1' then
        if cc_count_1 = 9  then 
          cc_count_1 <= (others => '0');
          cc_count_1_roll <= '1';
        else 
          cc_count_1 <= cc_count_1 + 1;
          cc_count_1_roll <= '0';
        end if;
    end if;
  end process;

  process(cc_count_1_roll, rst, mm_count_1_roll)
  begin
    if rst = '1' or mm_count_1_roll ='1' then
      ss_count_0 <= (others => '0');
      ss_count_0_roll <= '0';
    elsif cc_count_1_roll = '1' then
      if ss_count_0 = 9  then 
        ss_count_0 <= (others => '0');
        ss_count_0_roll <= '1';
      else 
        ss_count_0 <= ss_count_0 + 1;
        ss_count_0_roll <= '0';
      end if;
    end if;
  end process;

  process(ss_count_0_roll, rst, mm_count_1_roll)
  begin
    if rst = '1' or mm_count_1_roll ='1' then 
      ss_count_1 <= (others => '0');
      ss_count_1_roll <= '0';
    elsif ss_count_0_roll = '1' then
      if ss_count_1 = 5  then 
        ss_count_1 <= (others => '0');
        ss_count_1_roll <= '1';
      else 
        ss_count_1 <= ss_count_1 + 1;
        ss_count_1_roll <= '0';
      end if;
    end if;
  end process;

  process(ss_count_1_roll, rst, mm_count_1_roll)
  begin
    if rst = '1' or mm_count_1_roll ='1'  then
      mm_count_0 <= (others => '0');
      mm_count_0_roll <= '0';
    elsif ss_count_1_roll = '1' then
      if mm_count_0 = 9  then 
        mm_count_0 <= (others => '0');
        mm_count_0_roll <= '1';
      else 
        mm_count_0 <= mm_count_0 + 1;
        mm_count_0_roll <= '0';
      end if;
    end if;
  end process;

  process(mm_count_0_roll, rst, mm_count_1_roll)
  begin
    if rst = '1' or mm_count_1_roll ='1'  then 
      mm_count_1 <= (others => '0');
      mm_count_1_roll <= '0';
    elsif mm_count_0_roll = '1' then
      if mm_count_1 = 9  then 
        mm_count_1 <= (others => '0');
        mm_count_1_roll <= '1';
      else 
        mm_count_1 <= mm_count_1 + 1;
        mm_count_1_roll <= '0';
      end if;
    end if;
  end process;

  cc_0 <= cc_count_0;
  cc_1 <= cc_count_1;
  ss_0 <= ss_count_0;
  ss_1 <= ss_count_1;
  mm_0 <= mm_count_0;
  mm_1 <= mm_count_1;

  -- if ticks = (N_tickCycles-1) then
  --   ticks := (others => '0');
  --   if cc_count < 99 then
  --     cc_count <= cc_count + 1;
  --   else
  --     cc_count <= (others => '0');
  --     if ss_count < 59 then
  --       ss_count <= ss_count + 1;
  --     else
  --       ss_count <= (others => '0');
  --       if mm_count < 99 then
  --         mm_count <= mm_count + 1;
  --       else
  --         mm_count <= (others => '0');
  --       end if;
  --     end if;
  --   end if;
  -- else
  --   ticks := ticks + 1;
  -- end if;

end architecture;