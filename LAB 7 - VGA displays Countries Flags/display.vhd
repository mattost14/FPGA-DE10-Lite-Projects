library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display is
  generic (
    -- Screen size definition
    c_screen_width : integer := 640;
    c_screen_height : integer := 480
  );
  port (
    pixel_clk   : in std_logic;
    rst_n       : in std_logic;
    nextButton  : in std_logic;
    -- VGA controller inputs
    disp_en   : in std_logic;                                   --display enable ('1' = display time, '0' = blanking time)
		column		:	in	integer range 0 to c_screen_width-1;		  --horizontal pixel coordinate
		row				:	in	integer range 0 to c_screen_height-1;			--vertical pixel coordinate
    -- Color outputs to VGA
    red      :  out std_logic_vector(3 downto 0) := (others => '0');  --red magnitude output to DAC
    green    :  out std_logic_vector(3 downto 0) := (others => '0');  --green magnitude output to DAC
    blue     :  out std_logic_vector(3 downto 0) := (others => '0');  --blue magnitude output to DAC
    -- 7-Segment Display
    HEX1, HEX0  : out std_logic_vector(7 downto 0)
  );
end display;

architecture rtl of display is

  -- Contries List
  constant numOfCountries : integer := 13;
  type t_country is (FRANCE, ITALY, IRELAND, BELGIUM, MALI, CHAD, NIGERIA, IVORY, POLAND, GERMANY, AUSTRIA, CONGO, USA);
  type t_countriesList is array (0 to numOfCountries-1) of t_country;
  constant countryList : t_countriesList := (FRANCE, ITALY, IRELAND, BELGIUM, MALI, CHAD, NIGERIA, IVORY, POLAND, GERMANY, AUSTRIA, CONGO,  USA);

  signal countryIndex : natural range 0 to numOfCountries-1 := 0;
  -- Countries colors 
  signal france_color, italy_color, ireland_color, belgium_color, mali_color, chad_color, nigeria_color, ivory_color, poland_color, germany_color, austria_color, congo_color, usa_color : integer range 0 to 4095;
  signal newNextButtonPress : std_logic;

  -- 7-Segment Display Lookup Table
  type RAM is array (0 to 15) of std_logic_vector(7 downto 0);
  constant lut : RAM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"98", X"88", X"83", X"C6", X"A1", X"86", X"8E");


begin

  -- Display Country Number in the 7-Segment Display
  HEX0 <= lut((countryIndex+1) mod 10);
  HEX1 <= lut((countryIndex+1) / 10);

  process(pixel_clk)
  begin
    if rising_edge(pixel_clk) then
      if rst_n ='0' then
        countryIndex <= 0;
        newNextButtonPress <= '1';
      else
        if nextButton = '1' then
          if newNextButtonPress = '1' then
            newNextButtonPress <= '0';
            if countryIndex < numOfCountries-1 then
              countryIndex <= countryIndex + 1;
            else 
              countryIndex <= 0;
            end if;
          end if;
        else 
          newNextButtonPress <= '1';
        end if;
      end if;
    end if;
  end process;

  process(countryIndex, disp_en, france_color, italy_color, ireland_color, belgium_color, mali_color, chad_color, nigeria_color, ivory_color, poland_color, germany_color, austria_color, congo_color, usa_color)
    variable pix_color_tmp  : integer range 0 to 4095 := 0;
    variable pix_color_slv  : std_logic_vector(11 downto 0) := (others => '0');
  begin
    if disp_en = '0' then -- blanking time
      pix_color_tmp := 0; -- black color output
    else                  -- display time
      case countryList(countryIndex) is
        when FRANCE   => pix_color_tmp := france_color;
        when ITALY    => pix_color_tmp := italy_color;
        when IRELAND  => pix_color_tmp := ireland_color;
        when BELGIUM  => pix_color_tmp := belgium_color;
        when MALI     => pix_color_tmp := mali_color;
        when CHAD     => pix_color_tmp := chad_color;
        when NIGERIA  => pix_color_tmp := nigeria_color;
        when IVORY    => pix_color_tmp := ivory_color;
        when POLAND   => pix_color_tmp := poland_color;
        when GERMANY  => pix_color_tmp := germany_color;
        when AUSTRIA  => pix_color_tmp := austria_color;
        when CONGO    => pix_color_tmp := congo_color;
        when USA      => pix_color_tmp := usa_color;
        when others => pix_color_tmp := 16#000#;
      end case;
    end if;

    

    -- Assign from variables into real signals
    pix_color_slv := STD_LOGIC_VECTOR(TO_UNSIGNED(pix_color_tmp, pix_color_slv'LENGTH));
    red <= pix_color_slv(11 downto 8);
    green <= pix_color_slv(7 downto 4);
    blue <= pix_color_slv(3 downto 0);
  end process;


  -- Flags colors
  france_flag   : entity work.france port map (i_row  => row, i_column => column, o_color => france_color);
  italy_flag    : entity work.italy port map  (i_row  => row, i_column => column, o_color => italy_color);
  ireland_flag  : entity work.ireland port map (i_row  => row, i_column => column, o_color => ireland_color);
  belgium_flag  : entity work.belgium port map (i_row  => row, i_column => column, o_color => belgium_color);
  mali_flag     : entity work.mali port map (i_row  => row, i_column => column, o_color => mali_color);
  chad_flag     : entity work.chad port map (i_row  => row, i_column => column, o_color => chad_color);
  nigeria_flag  : entity work.nigeria port map (i_row  => row, i_column => column, o_color => nigeria_color);
  ivory_flag    : entity work.ivory port map (i_row  => row, i_column => column, o_color => ivory_color);
  poland_flag   : entity work.poland port map (i_row  => row, i_column => column, o_color => poland_color);
  germany_flag  : entity work.germany port map (i_row  => row, i_column => column, o_color => germany_color);
  austria_flag  : entity work.austria port map (i_row  => row, i_column => column, o_color => austria_color);
  congo_flag    : entity work.congo port map (i_row  => row, i_column => column, o_color => congo_color);
  usa_flag      : entity work.usa port map (i_row  => row, i_column => column, o_color => usa_color);

end architecture;