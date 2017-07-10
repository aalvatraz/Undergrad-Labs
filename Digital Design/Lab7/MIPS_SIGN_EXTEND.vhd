-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7:Sign Extend

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_sign_extend is
	generic(
			WIDTH : positive := 16
		);
	port(
		is_signed: in std_logic;
		input : in std_logic_vector(WIDTH-1 downto 0);
		output : out std_logic_vector(2*WIDTH - 1 downto 0)
		);
end mips_sign_extend;

architecture MIPS_SIGN_EXTEND_ARCH of mips_sign_extend is

begin

	process(is_signed, input)
	begin
	
		if(is_signed = '0') then
			output <= std_logic_vector(resize(unsigned(input), 2*WIDTH));
		else
			output <= std_logic_vector(resize(signed(input), 2*WIDTH));
		end if;
	end process;

end MIPS_SIGN_EXTEND_ARCH;