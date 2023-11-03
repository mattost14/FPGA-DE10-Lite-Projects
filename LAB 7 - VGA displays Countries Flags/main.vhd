library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
  port (
    MAX10_CLK1_50    :  in   std_logic;
    KEY              :  in   std_logic_vector(1 downto 0);
    -- VGA I/O  
    VGA_HS		       :  out	 std_logic;	                    -- horizontal sync pulse
    VGA_VS		       :	out	 std_logic;                     -- vertical sync pulse 
    VGA_R            :  out  std_logic_vector(3 downto 0);  -- red magnitude output to DAC
    VGA_G            :  out  std_logic_vector(3 downto 0);  -- green magnitude output to DAC
    VGA_B            :  out  std_logic_vector(3 downto 0);  -- blue magnitude output to DAC
    -- 7-Segment Display
    HEX1, HEX0       :  out std_logic_vector(7 downto 0)
  );
end main;

architecture rtl of main is
  signal pixel_clk            : std_logic;
  signal nextButton           : std_logic;
  signal nextButtonDebounced  : std_logic;
  signal rst_n                : std_logic;
  signal rst                  : std_logic;
  signal disp_en              : std_logic;
  signal column               : integer range 0 to 640-1;
  signal row                  : integer range 0 to 480-1;
begin

  rst_n       <= KEY(0);
  rst         <= not KEY(0);
  nextButton  <= not KEY(1);

  -- PLL Clock at 25.175Mhz for running the VGA
  -- pixel_clk <= MAX10_CLK1_50;
  VGA_CLK : entity work.vga_pll_clock
  port map(
    inclk0	=> MAX10_CLK1_50,
		c0		  => pixel_clk
  );

  -- Debounce next button
  DEBOUNCE_BUT: entity work.ButtonDebounce 
  -- generic map(
  --   delay => 5
  -- )
  port map(
    clk       => pixel_clk, 
    rst       => rst,
    input     => nextButton,
    debounce  => nextButtonDebounced
  );

-- Control what is display
  DISP : entity work.display(rtl)
  port map (
    pixel_clk   => pixel_clk,
    rst_n       => rst_n,
    nextButton  => nextButtonDebounced,
    disp_en     => disp_en,
		column		  => column,
		row				  => row,
    red         => VGA_R,
    green       => VGA_G,
    blue        => VGA_B,
    HEX0        => HEX0,
    HEX1        => HEX1
  );

  -- VGA Controller to generate sync signals 
  VGA_CTRL : entity work.vga_controller
  port map (
    pixel_clk	=> pixel_clk,
    reset_n		  => rst_n,
    h_sync		=> VGA_HS,
    v_sync		=> VGA_VS,
    disp_ena	  => disp_en,
    column		=> column,
    row				=> row
  );


end architecture;