-- Adrian Alvarez
-- University of Florida
-- EEL4712C
-- Lab3: 3 Bit adder Quiz

library ieee;
use ieee.std_logic_1164.all;

entity lab3_quiz is

	port(
		input1, input2 : in std_logic_vector( 3 downto 0);
		cin : in std_logic;
		sum : out std_logic_vector(3 downto 0);
		cout : out std_logic);
		
end lab3_quiz;


architecture QUIZ_ARCH of lab3_quiz is

	signal ca, cb :std_logic;
	
begin
		U_FA0: entity work.fa port map(	
				input1 => input1(0),
				input2 => input2(0),
				sum => sum(0),
				carry_in => cin,
				carry_out => ca
				);
				
		U_FA1: entity work.fa port map(	
				input1 => input1(1),
				input2 => input2(1),
				sum => sum(1),
				carry_in => cin,
				carry_out => cb
				);

		U_FA2: entity work.fa port map(	
				input1 => input1(2),
				input2 => input2(2),
				sum => sum(2),
				carry_in => ca
				);

		U_FA3: entity work.fa port map(	
				input1 => input1(3),
				input2 => input2(3),
				sum => sum(3),
				carry_in => cb,
				carry_out => cout
				);
				
end QUIZ_ARCH;

