-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 6: VGA_sync_gen127

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity vga_sync_gen is
	port(
		clk, rst : in std_logic;
		horiz_sync, vert_sync, video_on : out std_logic;
		hcount, vcount : out unsigned(9 downto 0)
		);
end vga_sync_gen;

architecture VGA_SYNC_GEN_ARCH of vga_sync_gen is

signal hcount_temp, vcount_temp : integer := 0;

begin

	hcount <= to_unsigned(hcount_temp, 10);
	vcount <= to_unsigned(vcount_temp, 10);

	process(clk,rst)
	begin
		if(rst = '1') then
			hcount_temp <= 0;
			vcount_temp <= 0;

		elsif(rising_edge(clk)) then
			if(hcount_temp < H_MAX) then
				if(hcount_temp = H_VERT_INC) then
					vcount_temp <= vcount_temp + 1;
				end if;
				hcount_temp <= hcount_temp + 1;
			else
				hcount_temp <= 0;
			end if;

			if(vcount_temp = V_MAX) then 
				vcount_temp <= 0;
			end if;

		end if;
	end process;

	process(hcount_temp, vcount_temp)
	begin
		if((hcount_temp < H_DISPLAY_END) )  then
			if(vcount_temp < V_DISPLAY_END) then
				video_on <= '1';
			else
				video_on <= '0';
			end if;
			
		else
			video_on <= '0';
		end if;

		if((hcount_temp >= HSYNC_BEGIN) and (hcount_temp < HSYNC_END)) then 
			horiz_sync <= '0';
		else
			horiz_sync <= '1';
		end if;

		if((vcount_temp >= VSYNC_BEGIN) and (vcount_temp < VSYNC_END)) then 
			vert_sync <= '0';
		else
			vert_sync <= '1';
		end if;
	end process;

end VGA_SYNC_GEN_ARCH;



