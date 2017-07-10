-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: Register
library ieee;
use ieee.std_logic_1164.all;

entity reg is 
	generic(
			WIDTH : positive := 32
			);
	port(
			clk, rst, load :in std_logic;
			input : in std_logic_vector(WIDTH-1 downto 0);
			output : out std_logic_vector(WIDTH-1 downto 0)
		);
end reg;

architecture REG_ARCH of reg is
begin

	process(clk,rst)
	begin
	
		if(rst = '1') then
			output <= (others => '0');
		elsif(rising_edge(clk)) then
			if(load = '1') then
				output <= input;
			end if;
		end if;
		
	end process;
end REG_ARCH;
			