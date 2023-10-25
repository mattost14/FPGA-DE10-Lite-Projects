library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ButtonDebounce is
  generic(
    delay : natural := 50000
  );
  port (
    clk       : in std_logic;
    rst       : in std_logic;
    input     : in std_logic;
    debounce  : out std_logic
  );
end ButtonDebounce;

architecture rtl of ButtonDebounce is
  signal sample : std_logic_vector(9 downto 0) := "1110001110";
  type state_type is (PRESSED, OFF);
  signal state : state_type;
  signal count : natural  range 0 to delay-1;
  signal debounce_buf : std_logic := '0';

begin

  FSM_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= OFF;
        debounce_buf <= '0';
        count <= 0;
      else
        -- Count update
        if count = delay-1 then
          sample <= sample(8 downto 0) & input;
          count <= 0;
        else
          count <= count + 1;
        end if;
        -- FSM
        case state is
            when OFF => 
              if count = delay-1 and sample = "1111111111"  then
                state <= PRESSED;
                debounce_buf <= '1';
              end if;
            when PRESSED => 
              if count = delay-1 and sample = "0000000000"  then
                state <= OFF;
                debounce_buf <= '0';
              end if;
        end case;
      end if;
    end if;
  end process;

  debounce <= debounce_buf;

end architecture;