-- Adrian Alvarez
-- University of Florida
-- EEL4712C
-- Lab1_2: 4-bit ripple carry adder

library ieee;
use ieee.std_logic_1164.all;

------------------------------
-- 	      Entity          --
-- 4-bit Ripple carry Adder --
------------------------------

entity adder is
	port (
			input1 		: in std_logic_vector(3 downto 0);
			input2 		: in std_logic_vector(3 downto 0);
			carry_in		: in std_logic;
			sum			: out std_logic_vector(3 downto 0);
			carry_out 	: out std_logic
			);
end adder;

------------------------------
-- 	   Architecture       --
-- 4-bit Ripple carry Adder --
------------------------------

architecture STR of adder is

	signal fa0_co, fa1_co, fa2_co : std_logic;

begin
		
		FA_0 : entity work.fa port map(
				input1 => input1(0),
				input2 => input2(0),
				carry_in => carry_in,
				sum => sum(0),
				carry_out => fa0_co
				);
				
		FA_1 : entity work.fa port map(
				input1 => input1(1),
				input2 => input2(1),
				carry_in => fa0_co,
				sum => sum(1),
				carry_out => fa1_co
				);
				
		FA_2 : entity work.fa port map(
				input1 => input1(2),
				input2 => input2(2),
				carry_in => fa1_co,
				sum => sum(2),
				carry_out => fa2_co
				);
				
		FA_3 : entity work.fa port map(
				input1 => input1(3),
				input2 => input2(3),
				carry_in => fa2_co,
				sum => sum(3),
				carry_out => carry_out
				);
				
end STR;
				
				
