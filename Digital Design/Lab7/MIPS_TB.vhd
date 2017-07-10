-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_tb is
end mips_tb;

architecture TB of mips_tb is

	signal inportA							: std_logic_vector(31 downto 0);
	signal inportB							: std_logic_vector(31 downto 0);
	signal outport0						: std_logic_vector(31 downto 0);
	signal inportA_en						: std_logic;
	signal clk, rst, done  			 	: std_logic := '0';
	signal inportB_en						: std_logic;

begin

	U_MIPS: entity work.mips 
		port map(
				inportA	=> inportA,
				inportB => inportB,
				outport0	=>outport0,
				inportA_en => inportA_en,
				clk => clk,
				rst => rst,
				inportB_en => inportB_en
			);

	clk <= not clk and not done after 20 ns;

	process
	begin

		inportA			<= (others => '0');	
		inportB			<= (others => '0');
		inportA_en		<= '0';
		inportB_en		<= '0';
		rst <= '1';

		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;

		rst <= '0';
		
		inportA			<= "00000000000000000000000000001010";	
		inportB			<= "00000000000000000000000000000101";
		inportA_en		<= '1';
		inportB_en		<= '1';

		for i in 0 to 1000 loop
			wait until rising_edge(clk);
		end loop;

		done <= '1';

	end process;

end TB;