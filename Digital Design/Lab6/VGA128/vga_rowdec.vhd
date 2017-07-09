-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 6: VGA Row Decoder

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity vga_rowdec is

	port(
			buttons : in std_logic_vector(2 downto 0);
			vcount : in unsigned(9 downto 0);
			video_on : in std_logic;
			row_en  : buffer std_logic;
			addrH : out std_logic_vector(6 downto 0)
		);
end vga_rowdec;

architecture VGA_ROWDEC_ARCH of vga_rowdec is

	signal vcount_int : integer;
	signal addrH_temp : unsigned(6 downto 0);

begin

	vcount_int <= to_integer(vcount); --convert vcount to integer type for comparison
	addrH <= std_logic_vector(addrH_temp);

	process(buttons, vcount_int, video_on)
	begin
		if( video_on = '1') then --skip every other line
			if(buttons = "001") then

				if((vcount_int >= TOP_LEFT_Y_START) and (vcount_int <= TOP_LEFT_Y_END)) then
					addrH_temp <= to_unsigned((vcount_int - TOP_LEFT_Y_START) , 7);  
					row_en <= '1';
				else
					addrH_temp <= to_unsigned(0, 7);
					row_en <= '0';
				end if;

			elsif(buttons = "010") then

				if((vcount_int >= TOP_RIGHT_Y_START) and (vcount_int <= TOP_RIGHT_Y_END)) then
					addrH_temp <= to_unsigned((vcount_int - TOP_RIGHT_Y_START) , 7); 
					row_en <= '1';
				else
					addrH_temp <= to_unsigned(0, 7);
					row_en <= '0';
				end if;

			elsif(buttons = "011") then

				if((vcount_int >= BOTTOM_LEFT_Y_START) and (vcount_int <= BOTTOM_LEFT_Y_END)) then
					addrH_temp <= to_unsigned((vcount_int - BOTTOM_LEFT_Y_START) , 7);
					row_en <= '1';
				else
					addrH_temp <= to_unsigned(0, 7);
					row_en <= '0';
				end if;

			elsif(buttons = "100") then

				if((vcount_int >= BOTTOM_RIGHT_Y_START) and (vcount_int <= BOTTOM_RIGHT_Y_END)) then
					addrH_temp <= to_unsigned((vcount_int - BOTTOM_RIGHT_Y_START) , 7);
					row_en <= '1';
				else
					addrH_temp <= to_unsigned(0, 7);
					row_en <= '0';
				end if;

			else --buttons = "000" and all others

				if((vcount_int >= CENTERED_Y_START) and (vcount_int <= CENTERED_Y_END)) then
					addrH_temp <= to_unsigned((vcount_int - CENTERED_Y_START) , 7); 
					row_en <= '1';
				else
					addrH_temp <= to_unsigned(0, 7);
					row_en <= '0';
				end if;

			end if;

		else
			addrH_temp <= (others => '0');
			row_en <= '0';

		end if;

	end process;

end VGA_ROWDEC_ARCH;

