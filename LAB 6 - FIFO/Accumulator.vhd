library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accumulator is
  port (
    -- Clocks
    clk0   : in std_logic; -- 5MHz PLL clock
    clk1   : in std_logic; -- 12.5MHz PLL clock
    -- Buttons
    rst   : in std_logic;
    add   : in std_logic;
    -- Input value
    value : in unsigned(9 downto 0);
    -- Accumulated value
    acc   : out unsigned(23 downto 0)
  );
end Accumulator;

architecture rtl of Accumulator is
  -- FSM 1
  type state1_type is (IDDLE, WRITE_FIFO);
  signal state1 : state1_type;
  -- FSM 2
  type state2_type is (WAITING, READ_FIFO, UPDATE_ACC, PRE_READ);
  signal state2 : state2_type;
  -- FIFO signals
  signal aclr	        : std_logic;
  signal rdreq	      : std_logic;
  signal wrreq	      : std_logic;
  signal q	          : std_logic_vector(9 downto 0);
  signal rdempty	    : std_logic;
  signal wrfull	      : std_logic;
  signal rdusedw  : std_logic_vector (2 downto 0);
  -- Control signals
  signal valueAddedFlag   : std_logic;
  signal acc_buf : unsigned(23 downto 0);
  signal sumOfValuesFromFIFO : unsigned(13 downto 0);

begin

  -- FIFO instance
  FIFO_inst : entity work.FIFO 
  port map (
		aclr	  => aclr,
		data	  => std_logic_vector(value),
		rdclk	  => clk1,
		rdreq	  => rdreq,
		wrclk	  => clk0,
		wrreq	  => wrreq,
		q	      => q,
		rdempty	=> rdempty,
		wrfull	=> wrfull,
    rdusedw	 => rdusedw
	);

  -- FSM on 5MHz clock to manage button presses and the write side of the FIFO
  FSM1 : process(clk0)
  begin
    if rising_edge(clk0) then
      if rst = '1' then    -- Reset 
        valueAddedFlag <= '0';
        state1 <= IDDLE;
      else
        case state1 is
          -- IDDLE
          when IDDLE =>
            wrreq <= '0';
            -- Check for new 'add' presses
            if add = '1' then
              if valueAddedFlag = '0' then
                state1 <= WRITE_FIFO;
              end if;
            else 
              valueAddedFlag <= '0';
            end if;

          -- WRITE VALUE INTO FIFO
          when WRITE_FIFO => 
              wrreq <= '1';                           -- write request
              valueAddedFlag <= '1';                  -- set valueAdded flag to 1
              state1 <= IDDLE;
        end case;
      end if;
    end if;
  end process;

  -- FSM on 12.5MHz clock to manage read side of the FIFO
  FSM2 : process(clk1)
  begin
    if rising_edge(clk1) then
      if rst = '1' then -- reset FIFO and Accumulator buffer
        aclr <= '1';  
        acc_buf <= (others => '0');
        state2 <= WAITING;
      else 
        case state2 is
          -- WAITING FOR DRAINING REQUEST
          when WAITING =>
            aclr <= '0';
            sumOfValuesFromFIFO <= (others => '0');
            rdreq <= '0'; 
            if rdusedw = "101" then
              rdreq <= '1'; 
              state2 <= PRE_READ;
            end if;
          -- Delay by one clock cycle to enable read on next clock cycle
          when PRE_READ =>
            state2 <= READ_FIFO;
          -- READ UNTIL EMPTY
          when READ_FIFO =>                                 
            sumOfValuesFromFIFO <= sumOfValuesFromFIFO + unsigned(q);   -- read value from FIFO and add to the sum
            state2 <= READ_FIFO;
            if rdempty = '1' then  
              rdreq <= '0';
              state2 <= UPDATE_ACC;
            end if;
          -- UPDATE THE ACCUMULATOR VALUE WITH THE SUM FROM FIFO
          when UPDATE_ACC =>
            acc_buf <= acc_buf + sumOfValuesFromFIFO;
            state2 <= WAITING;
        end case;
      end if;
    end if;
  end process;

  acc <= acc_buf;

end architecture;