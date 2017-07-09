-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 4: Counter TB

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tb is
end counter_tb;

architecture TB of counter_tb is


	signal clk, rst, done, up_n, load_n : std_logic := '0';
	signal input : std_logic_vector(3 downto 0) := "0000";
	signal output : std_logic_vector(3 downto 0);

begin

	UUT: entity work.counter
		port map(
				rst => rst,
				clk => clk,
				up_n => up_n,
				load_n => load_n,
				input => input,
				output => output
				);
				
	clk <= not clk and not done after 10 ns;
				
				
	process
	begin
		load_n <= '1';
		rst <= '1';
		wait for 50 ns;
		
		rst <= '0';
		up_n <= '1';
		for i in 0 to 15 loop
			wait until rising_edge(clk);
		end loop;
		
		up_n <= '0';
		for i in 0 to 15 loop
			wait until rising_edge(clk);
		end loop;
		
		input <= "1010";
		load_n <= '0';
		wait until rising_edge(clk);
		
		input <= "1111";
		wait until rising_edge(clk);
		
		load_n <= '1';
		up_n <= '0';
		for i in 0 to 15 loop
			wait until rising_edge(clk);
		end loop;
		
		done <= '1';
		wait;
	end process;
	
end TB;
		
			