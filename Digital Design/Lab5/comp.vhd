-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: Comparator
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp is
	generic(
			WIDTH : positive := 8
			);
	port(
			in1, in2 : in std_logic_vector(WIDTH-1 downto 0);
			in1_lt_in2, in1_ne_in2 : out std_logic := '0'
			);
end comp;

architecture COMP_ARCH of comp is
begin
	in1_lt_in2 <= '1' when (unsigned(in1) < unsigned(in2)) else '0';
	in1_ne_in2 <= '0' when (unsigned(in1) = unsigned(in2)) else '1';
end COMP_ARCH;