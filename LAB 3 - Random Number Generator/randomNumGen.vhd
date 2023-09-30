library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity randomNumGen is
  generic (
    N     : integer := 8
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    gen : in std_logic;
    randomNum:  out unsigned(N-1 downto 0)
  );
  constant  seed : unsigned(31 downto 0) := x"1F0F0F79";
end randomNumGen;

architecture rtl of randomNumGen is
  signal lfsr : unsigned(31 downto 0);
begin
  genRandomNum : process(clk)
  variable bit : std_logic;
  begin
    if rst = '1' then
      lfsr <=  seed;
    elsif rising_edge(clk) and gen = '1' then
      -- Feedback polynomial : x^32 + x^30 + x^19 + x^17 + x^11 +  x^7 + x^5 + x^3 + 1
      bit := lfsr(32-32) xor lfsr(32-30) xor lfsr(32-19) xor lfsr(32-17) xor lfsr(32-11)  xor lfsr(32-7) xor lfsr(32-5) xor lfsr(32-3);
      lfsr <= shift_right(lfsr, 1);
      lfsr(31) <= bit;
    end if;
  end process;
  randomNum <= lfsr(N downto 1);
end architecture;