-- Adrian Alvarez
-- University of Florida
-- EEL4712C
-- Lab3: CLA Carry generator

library ieee;
use ieee.std_logic_1164.all;

entity cgen2 is 
	port(
			ci , pi, gi, pi_1, gi_1 : in std_logic;
			ci_1 , ci_2, bp, bg : out std_logic
		 );
end cgen2;


architecture CGEN_ARCH of cgen2 is

	signal p, g, c : std_logic;

begin

	p <= pi and pi_1;
	g <= gi_1 or (pi_1 and gi);
	c <= gi or (pi and ci);
	
	ci_1 <= c;
	ci_2 <= g or (p and c);
	bp <= p;
	bg <= g;

end CGEN_ARCH;