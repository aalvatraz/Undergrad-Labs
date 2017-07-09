-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 6: VGA Top Level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.VGA_LIB.all;

entity vga is
	port (  clk              : in  std_logic;
           rst              : in  std_logic;
           buttons_n        : in  std_logic_vector(2 downto 0);
           red, green, blue : out std_logic_vector(3 downto 0);
           h_sync, v_sync   : out std_logic
        );

end vga;

architecture VGA_ARCH of vga is

	signal clk_25M, video_on, hsync_temp, vsync_temp, colEn, rowEn : std_logic;
	signal hcount, vcount : unsigned(9 downto 0);
	signal address : std_logic_vector(13 downto 0);
	signal colors : std_logic_vector(11 downto 0);

begin

	h_sync <= hsync_temp;
	v_sync <= vsync_temp;

	U_CLK: entity work.clk_div
		generic map (
            clk_in_freq  => 50000000,
            clk_out_freq => 25000000)
		port map(
				clk_in => clk,
				clk_out => clk_25M,
				rst => rst
			);

	U_SYNC: entity work.vga_sync_gen
	   port map(
	   		clk => clk,
	   		rst => rst,
	   		horiz_sync => hsync_temp,
	   		vert_sync => vsync_temp,
	   		video_on => video_on,
	   		hcount => hcount,
	   		vcount => vcount
	   	);

   U_COL: entity work.vga_coldec
   	port map(
   			buttons => buttons_n,
   			hcount => hcount,
   			addrL => address(6 downto 0),
   			video_on => video_on,
   			column_en => colEn
   			);

	U_ROW: entity work.vga_rowdec
   	port map(
   			buttons => buttons_n,
   			vcount => vcount,
   			addrH => address(13 downto 7),
   			video_on => video_on,
   			row_en => rowEn
   			);

	U_ROM: entity work.meme_rom
		port map(
				clock => clk,
				address => address,
				q => colors   
			);

	red <= colors(11 downto 8) when colEn = '1' else
			 "0000";

	green <= colors(7 downto 4) when colEn = '1' else
			"0000";

	blue <= colors(3 downto 0) when colEn = '1' else
			"0000";

end VGA_ARCH;