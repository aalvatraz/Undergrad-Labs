-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab: 2x1 mux
library ieee;
use ieee.std_logic_1164.all;

entity mux_2x1 is
	generic(
			WIDTH : positive := 1
			);
	port(
			in1, in2 : in std_logic_vector(WIDTH -1 downto 0);
			sel : in std_logic;
			output : out std_logic_vector(WIDTH -1 downto 0)
		);
end mux_2x1;

architecture MUX_2x1_ARCH of mux_2x1 is
begin
	with sel select
		output <= in1 when '0',
		in2 when others;
end MUX_2x1_ARCH;