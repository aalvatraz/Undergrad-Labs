-- Adrian Alvarez
-- University of Florida
-- EEL4712C Digital Design
-- Lab 2: 7 Segment Decoder


library ieee;
use ieee.std_logic_1164.all;

-----------------------
--       ENTITY      --
-- 7 segment decoder --
-----------------------

entity decoder7seg is
	port (
			input  : in  std_logic_vector(3 downto 0);
			output : out std_logic_vector(6 downto 0)
	);
end decoder7seg; 

-----------------------
--    Architecture   --
-- 7 segment decoder --
-----------------------

architecture SEG7 of decoder7seg is 
begin
	
	 with input select
    output <= "0000001" when x"0",
		  	    "1001111" when x"1",
			    "0010010" when x"2",
			    "0000110" when x"3",
			    "1001100" when x"4",
			    "0100100" when x"5",
			    "0100000" when x"6",
			    "0001111" when x"7",
			    "0000000" when x"8",
			    "0001100" when x"9",
			    "0001000" when x"A",
			    "1100000" when x"B",
			    "0110001" when x"C",
			    "1000010" when x"D",
			    "0110000" when x"E",
			    "0111000" when x"F";
	 
end SEG7;
