-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 4: Clock Divider

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_div is
    generic(clk_in_freq  : natural ;
            clk_out_freq : natural );
    port (
        clk_in  : in  std_logic;
        clk_out : out std_logic;
        rst     : in  std_logic);
end clk_div;

architecture CLK_DIV_ARCH of clk_div is

	constant cycles_max : integer := ( clk_in_freq / (clk_out_freq) ) - 1;
	signal counter : integer range 0 to cycles_max := 0;
	signal temp : std_logic;

begin

	process(rst, clk_in)
	begin
	
		if( rst = '1') then
			counter <= 0;
			temp <= '0';
			
		elsif rising_edge(clk_in) then
			if(counter = cycles_max) then
				temp <= '1';
				counter <= 0;
			else
				if(temp = '1') then
					temp <= '0';
				end if;
				counter <= counter + 1;
			end if;
			
		end if;
	end process;
	
	clk_out <= temp;
	
end CLK_DIV_ARCH;
