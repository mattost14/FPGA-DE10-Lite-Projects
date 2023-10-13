library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accumulator is
  port (
    clk   : in std_logic;
    rst   : in std_logic;
    add   : in std_logic;
    value : in unsigned(9 downto 0);
    acc   : out unsigned(23 downto 0)
  );
end Accumulator;

architecture rtl of Accumulator is
  type state_type is (ADDING, IDDLE);
  signal state : state_type;
  signal valueAddedFlag : std_logic;
  signal acc_buf : unsigned(23 downto 0);
begin

  FSM_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        acc_buf <= (others => '0');
        valueAddedFlag <= '0';
        state <= IDDLE;
      else
        case state is
          when ADDING => 
            acc_buf <= acc_buf + value;   -- add value to accumulator
            valueAddedFlag <= '1';
            state <= IDDLE;
          when IDDLE =>
            if add = '1' then
              if valueAddedFlag = '0' then
                state <= ADDING;
              else
                state <= IDDLE;
              end if;
            else 
              valueAddedFlag <= '0';
              state <= IDDLE;
            end if;
        end case;
      end if;
    end if;
  end process;

  acc <= acc_buf;

end architecture;