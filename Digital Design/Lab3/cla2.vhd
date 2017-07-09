-- Adrian Alvarez
-- University of Florida
-- EEL4712C
-- Lab3: Carry Look Ahead adder

library ieee;
use ieee.std_logic_1164.all;

entity cla2 is
	port (
			x		: in std_logic_vector(1 downto 0);
			y		: in std_logic_vector(1 downto 0);
		   cin	: in std_logic;
		   sum	: out std_logic_vector(1 downto 0);
			cout	: out std_logic;
			bp 	: out std_logic;
			bg 	: out std_logic
			);
end cla2;

architecture CLA_ARCH of cla2 is

signal p0, g0, c0, p1, g1 : std_logic;

begin
	sum(0) <= (x(0) xor y(0)) xor cin;
	p0 <= (x(0) xor y(0));
	g0 <= (x(0) and y(0));
	c0 <= g0 or (p0 and cin);
	
	sum(1) <= (x(1) xor y(1)) xor c0;
	p1 <= (x(1) xor y(1));
	g1 <= (x(1) and y(1));
	
	bp <= p1 and p0;
	bg <= g1 or (p1 and g0);
	cout <= g1 or (p1 and g0) or (p1 and p0 and cin); -- cout <= bg + bp*cin

	
end CLA_ARCH;