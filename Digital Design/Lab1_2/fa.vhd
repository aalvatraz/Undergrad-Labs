-- Adrian Alvarez
-- University of Florida
-- EEL4712C
-- Lab1_2: Full adder

library ieee;
use ieee.std_logic_1164.all;

------------------------
-- 	   Entity       --
-- One bit Full Adder --
------------------------

entity fa is
	port (
			input1		: in std_logic;
			input2		: in std_logic;
			carry_in		: in std_logic;
			sum			: out std_logic;
			carry_out	: out std_logic
			);
end fa;

------------------------
--    Architecture    --
-- One bit full adder --
------------------------

architecture BHV of fa is
begin
 sum <= (input1 xor input2) xor carry_in;
 carry_out <= ((input1 xor input2) and carry_in) or (input1 and input2);
end BHV;