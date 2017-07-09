library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab5_quiz_tb is
end lab5_quiz_tb;

architecture TB of lab5_quiz_tb is

	signal clk : std_logic := '0';
	signal rst, done : std_logic;
	signal output : std_logic_vector(3 downto 0);

begin

	UUT: entity work.lab4_quiz
		 port map (
					clk => clk,
					rst => rst,
					output => output
					);
					
	clk <= not clk and not done after 10 ns;
		
	process
	begin
	
	done <= '0';
	rst <= '1';
	wait for 60 ns;
	rst <= '0';
	--wait for 10 ns;
	
	for i in 1 to 3 loop
		for j in 1 to 3 loop
		
		
		wait until clk'event and clk='1';
	end loop;
	
	report "DONE";
	 
	done <= '1';
	wait;
	 
	end process;
	 
 end TB;