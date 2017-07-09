-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 2: 7 Segment Decoder Testbench

library ieee;
use ieee.std_logic_1164.all;

entity decoder7seg_tb is
end decoder7seg_tb;

architecture TB of decoder7seg_tb is

	component decoder7seg
		port(
				input  : in  std_logic_vector(3 downto 0);
				output : out std_logic_vector(6 downto 0)
			);
	end component;
	
	signal input  : std_logic_vector(3 downto 0);
	signal output : std_logic_vector(6 downto 0);
	
begin  -- TB

	UUT : decoder7seg
		port map(
				input => input,
				output => output
				);
	
	process
	begin
	
	-- test input "0"
	input <= x"0";
	wait for 20 ns;
	assert(output = "0000001")
	 report "Error 0" severity warning;
	
	-- test input "1"
	input <= x"1";
	wait for 20 ns;
	assert(output = "1001111")
	 report "Error 1" severity warning;
	
	-- test input "2"
	input <= x"2";
	wait for 20 ns;
	assert(output = "0010010")
	 report "Error 2" severity warning;
	
	-- test input "3"
	input <= x"3";
	wait for 20 ns;
	assert(output = "0000110")
	 report "Error 3" severity warning;
	
	-- test input "4"
	input <= x"4";
	wait for 20 ns;
	assert(output = "1001100")
	 report "Error 4" severity warning;
	
	-- test input "5"
	input <= x"5";
	wait for 20 ns;
	assert(output = "0100100")
	 report "Error 5" severity warning;
	
	-- test input "6"
	input <= x"6";
	wait for 20 ns;
	assert(output = "0100000")
	 report "Error 6" severity warning;
	
	-- test input "7"
	input <= x"7";
	wait for 20 ns;
	assert(output = "0001111")
	 report "Error 7" severity warning;
	
	-- test input "8"
	input <= x"8";
	wait for 20 ns;
	assert(output = "0000000")
	 report "Error 8" severity warning;
	
	-- test input "9"
	input <= x"9";
	wait for 20 ns;
	assert(output = "0001100")
	 report "Error 9" severity warning;
	
	-- test input "A"
	input <= x"A";
	wait for 20 ns;
	assert(output = "0001000")
	 report "Error A" severity warning;
	
	-- test input "B"
	input <= x"B";
	wait for 20 ns;
	assert(output = "1100000")
	 report "Error B" severity warning;
	
	-- test input "C"
	input <= x"C";
	wait for 20 ns;
	assert(output = "0110001")
	 report "Error C" severity warning;
	
	-- test input "D"
	input <= x"D";
	wait for 20 ns;
	assert(output = "1000010")
	 report "Error D" severity warning;
	
	-- test input "E"
	input <= x"E";
	wait for 20 ns;
	assert(output = "0110000")
	 report "Error E" severity warning;
	
	-- test input "F"
	input <= x"F";
	wait for 20 ns;
	assert(output = "0111000")
	 report "Error F" severity warning;
	 
	--finished	 
	report "Simulation Finished";
	 
	 wait;
	 	 
	 end process;
	 
end TB;