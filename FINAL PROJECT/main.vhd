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
    HEX0             :  out std_logic_vector(7 downto 0);
    -- Accelerometer I/O
    GSENSOR_CS_N      : out   std_logic;
    GSENSOR_SCLK      : out   std_logic;
    GSENSOR_SDI       : inout std_logic;
    GSENSOR_SDO       : inout std_logic
  );
end main;

architecture rtl of main is

  -- Component declarations
  component ADXL345_controller is
  port( reset_n     : in  std_logic;
        clk         : in  std_logic;
        data_valid  : out std_logic;
        data_x      : out std_logic_vector(15 downto 0);
        data_y      : out std_logic_vector(15 downto 0);
        data_z      : out std_logic_vector(15 downto 0);
        SPI_SDI     : out std_logic;
        SPI_SDO     : in  std_logic;
        SPI_CSN     : out std_logic;
        SPI_CLK     : out std_logic);
  end component;

  -- Signal declarations
  signal pixel_clk            : std_logic;
  signal disp_en              : std_logic;
  signal column               : integer range 0 to 640-1;
  signal row                  : integer range 0 to 480-1;

  -- Accelerometer signals
  signal data_x, data_y                 : std_logic_vector(15 DOWNTO 0);
  signal data_valid                     : std_logic;
  signal accel_scale_x, accel_scale_y   : integer;
begin


  -- VGA
  VGA_CLK   : entity work.vga_pll_clock port map(inclk0	=> MAX10_CLK1_50, c0 => pixel_clk);
  VGA_CTRL  : entity work.vga_controller
  port map (
    pixel_clk	  => pixel_clk,
    reset_n		  => '1',
    h_sync		  => VGA_HS,
    v_sync		  => VGA_VS,
    disp_ena	  => disp_en,
    column		  => column,
    row				  => row
  );

  -- Accelerometer
  ACC_CTRL : ADXL345_controller 
  port map (
    reset_n => '1', 
    clk => MAX10_CLK1_50, 
    data_valid => data_valid, 
    data_x => data_x,  
    data_y => data_y, 
    data_z => open, 
    SPI_SDI => GSENSOR_SDI, 
    SPI_SDO => GSENSOR_SDO, 
    SPI_CSN => GSENSOR_CS_N, 
    SPI_CLK => GSENSOR_SCLK
  );
  ACC_PROC :  entity work.accel_proc  
  port map (
    data_x => data_x, 
    data_y => data_y, 
    data_valid => data_valid, 
    accel_scale_x => accel_scale_x, 
    accel_scale_y => accel_scale_y
  );


-- Control what is display
  DISP : entity work.display(rtl)
  port map (
    i_pixel_clk     => pixel_clk,
    i_KEY           => KEY,
    i_disp_en       => disp_en,
		i_column		    => column,
		i_row				    => row,
    i_accel_scale_x => accel_scale_x,
    i_accel_scale_y => accel_scale_y,
    o_red           => VGA_R,
    o_green         => VGA_G,
    o_blue          => VGA_B,
    o_HEX0          => HEX0
  );





end architecture;