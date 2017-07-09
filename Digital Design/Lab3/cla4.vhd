-- Adrian Alvarez
-- University of Florida
-- EEL4712C
-- Lab3: Heirarchical 4 bit CLA 

library ieee;
use ieee.std_logic_1164.all;

entity cla4 is
	port(
			input1, input2 : in std_logic_vector(3 downto 0);
			cin : in std_logic;
			sum : out std_logic_vector(3 downto 0);
			cout, bg, bp : out std_logic
			);
end cla4;


architecture CLA4_ARCH of cla4 is

	signal bp0, bp1, bg0, bg1, c0, c1: std_logic;
	
begin

	U_CLA0: entity work.cla2 
				port map(
							x => input1(1 downto 0),
							y => input2(1 downto 0),
							cin => cin,
							sum => sum(1 downto 0),
							bg => bg0,
							bp => bp0
							);
		
	U_CLA1: entity work.cla2
				port map(
							x => input1(3 downto 2),
							y => input2(3 downto 2),
							cin => c1,
							sum => sum(3 downto 2),
							bg => bg1,
							bp => bp1
							);
							
	U_CGEN: entity work.cgen2
				port map(
							ci => cin,
							pi => bp0,
							gi => bg0,
							pi_1 => bp1,
							gi_1 => bg1,
							ci_1 => c1,
							ci_2 => cout,
							bp => bp,
							bg => bg
							);
							
end CLA4_ARCH;
