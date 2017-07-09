-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 4: 4-bit Up/Down Counter with Load

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        up_n   : in  std_logic;         -- active low
        load_n : in  std_logic;         -- active low
        input  : in  std_logic_vector(3 downto 0);
        output : out std_logic_vector(3 downto 0));
end counter;


architecture COUNTER_ARCH of counter is

signal temp : unsigned(3 downto 0);

begin

	process(clk, rst)
	begin	
		if(rst = '1') then
			temp <= to_unsigned(0, 4);
		elsif(rising_edge(clk)) then
			if(load_n = '0') then
				temp <= unsigned(input);
			elsif(up_n = '0') then
				temp <= temp + to_unsigned(1, 4);
			else
				temp <= temp - to_unsigned(1, 4);
			end if;
		end if;
	end process;
	
	output <= std_logic_vector(temp);

end COUNTER_ARCH;