-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab: 4x1 mux
library ieee;
use ieee.std_logic_1164.all;

entity mux_4x1 is
	generic(
			WIDTH : positive := 1
			);
	port(
			in1, in2, in3, in4 : in std_logic_vector(WIDTH - 1 downto 0);
			sel : in std_logic_vector(1 downto 0);
			output : out std_logic_vector(WIDTH - 1 downto 0)
		);
end mux_4x1;

architecture MUX_4x1_ARCH of mux_4x1 is
begin
	with sel select
		output <= in1 when "00",
		in2 when "01",
		in3 when "10",
		in4 when others;
end MUX_4x1_ARCH;