-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 6: VGA Column Decoder


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_lib.all;

entity vga_coldec is

	port(
			buttons : in std_logic_vector(2 downto 0);
			hcount : in unsigned(9 downto 0);
			video_on : in std_logic;
			column_en : buffer std_logic;
			addrL : out std_logic_vector(5 downto 0)
		);
end vga_coldec;

architecture VGA_COLDEC_ARCH of vga_coldec is

	signal hcount_int : integer;
	signal addrL_temp : unsigned(5 downto 0);
	--signal count

begin

	hcount_int <= to_integer(hcount); --convert hcount to integer type for comparison
	addrL <= std_logic_vector(addrL_temp);


	process(buttons, hcount_int, video_on)
	begin

			if(buttons = "001") then
 
				if((hcount_int >= TOP_LEFT_X_START) and (hcount_int <= TOP_LEFT_X_END)) then --gteq, lteq
					addrL_temp <= to_unsigned((hcount_int - TOP_LEFT_X_START) / 2, 6);
					column_en <= '1';
				else
					addrL_temp <= to_unsigned(0, 6);
					column_en <= '0';
				end if;

			elsif(buttons = "010") then

				if((hcount_int >= TOP_RIGHT_X_START) and (hcount_int <=TOP_RIGHT_X_END)) then
					addrL_temp <= to_unsigned((hcount_int - TOP_RIGHT_X_START) / 2, 6);
					column_en <= '1';
				else
					addrL_temp <= to_unsigned(0, 6);
					column_en <= '0';
				end if;

			elsif(buttons = "011") then

				if((hcount_int >= BOTTOM_LEFT_X_START) and (hcount_int <= BOTTOM_LEFT_X_END)) then
					addrL_temp <= to_unsigned((hcount_int - BOTTOM_LEFT_X_START) / 2, 6);
					column_en <= '1';
				else
					addrL_temp <= to_unsigned(0, 6);
					column_en <= '0';
				end if;

			elsif(buttons = "100") then

				if((hcount_int >= BOTTOM_RIGHT_X_START) and (hcount_int <= BOTTOM_RIGHT_X_END)) then
					addrL_temp <= to_unsigned((hcount_int - BOTTOM_RIGHT_X_START) / 2, 6);
					column_en <= '1';
				else
					addrL_temp <= to_unsigned(0, 6);
					column_en <= '0';
				end if;

			else --buttons = "000" and all others

				if((hcount_int >= CENTERED_X_START) and (hcount_int <= CENTERED_X_END)) then
					addrL_temp <= to_unsigned((hcount_int - CENTERED_X_START) / 2, 6);
					column_en <= '1';
				else
					addrL_temp <= to_unsigned(0, 6);
					column_en <= '0';
				end if;

			end if;

	end process;

end VGA_COLDEC_ARCH;

