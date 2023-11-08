library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
  port (
    --- CLOCK ---
    ADC_CLK_10     :  in std_logic;
    MAX10_CLK1_50  :  in std_logic;
    MAX10_CLK2_50  :  in std_logic;
    --- SEG7 ---
    HEX0, HEX1, HEX2  :  out std_logic_vector(7 downto 0);
    --- KEY ---
    KEY               :  in std_logic_vector(1 downto 0);
  );
end main;

architecture rtl of main is

  component ADC is
		port (
			clock_clk              : in  std_logic                     := 'X';             -- clk
			reset_sink_reset_n     : in  std_logic                     := 'X';             -- reset_n
			adc_pll_clock_clk      : in  std_logic                     := 'X';             -- clk
			adc_pll_locked_export  : in  std_logic                     := 'X';             -- export
			command_valid          : in  std_logic                     := 'X';             -- valid
			command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
			command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			command_ready          : out std_logic;                                        -- ready
			response_valid         : out std_logic;                                        -- valid
			response_channel       : out std_logic_vector(4 downto 0);                     -- channel
			response_data          : out std_logic_vector(11 downto 0);                    -- data
			response_startofpacket : out std_logic;                                        -- startofpacket
			response_endofpacket   : out std_logic                                         -- endofpacket
		);
	end component ADC;

  -- Constants --
  constant N : integer := 10_000_000; -- This gives 1Hz update time considering the ADC clock at 10MHz

  --- Signals ---
  signal pll_clk_25Mhz        : std_logic;
  signal adc_clk_10Mhz        : std_logic;
  signal adc_clk_locked_sig   : std_logic;
  signal command_valid        : std_logic;
  signal response_valid       : std_logic;
  signal response_data        : std_logic_vector(11 downto 0);
  signal vol_reg              : unsigned(11 downto 0);
  signal voltage              : unsigned(11 downto 0);
  signal counter              : natural range 0 to N-1;

begin

  -- ADC PLL CLOCK 2MHz --
  adc_pll_clock_inst : entity work.adc_pll_clock port map (
		inclk0	  => MAX10_CLK1_50,
		c0	      => pll_clk_25Mhz,
    c1	      => adc_clk_10Mhz,
		locked	  => adc_clk_locked_sig
	);

  -- ADC Core --
  adc_core_inst : component ADC
  port map (
    clock_clk              => pll_clk_25Mhz,        --          clock.clk
    reset_sink_reset_n     => '1',                  --     reset_sink.reset_n
    adc_pll_clock_clk      => adc_clk_10Mhz,         --  adc_pll_clock.clk
    adc_pll_locked_export  => adc_clk_locked_sig,   -- adc_pll_locked.export
    command_valid          => '1',        --        command.valid
    command_channel        => "00001",              --  ADC_IN0
    command_startofpacket  => '1',                  --               .startofpacket
    command_endofpacket    => '1',                  --               .endofpacket
    command_ready          => open,                 --               .ready
    response_valid         => response_valid,       --       response.valid
    response_channel       => open,     --               .channel
    response_data          => response_data,        --               .data
    response_startofpacket => open,                 --               .startofpacket
    response_endofpacket   => open                  --               .endofpacket
  );

  process(adc_clk_10Mhz)
  begin
    if rising_edge(adc_clk_10Mhz) then
      if KEY(0) = '0' then
        voltage <= (others => '1');
        counter <= 0;
      else
        if response_valid = '1' then
          vol_reg <= unsigned(response_data); 
        end if;
        -- Update voltage at 1Hz
        if counter = N - 1 then
          counter <= 0;
          voltage <= vol_reg;
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process;

  u_HEX0 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => voltage(3 downto 0),
    oSEG    => HEX0
  );

  u_HEX1 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => voltage(7 downto 4),
    oSEG    => HEX1
  );

  u_HEX2 : entity work.SEG7_LUT(rtl)
  port map (
    i_Digit => voltage(11 downto 8),
    oSEG    => HEX2
  );

end architecture;