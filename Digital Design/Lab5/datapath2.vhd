-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: Datapath2
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath2 is
	generic(
			WIDTH : positive := 8
			);
	port(
			clk, rst : in std_logic;
			x, y : in std_logic_vector(WIDTH-1 downto 0);
			output : out std_logic_vector(WIDTH-1 downto 0);
			
			x_sel, y_sel, x_en, y_en, output_en : in std_logic;
			x_lt_y, x_ne_y : out std_logic
		);
end datapath2;

architecture DATAPATH2_ARCH of datapath2 is

	signal mux2tmp_x, mux2tmp_y, tmp2mux_x, tmp2mux_y,  mux2sub_a, mux2sub_b, sub2mux : std_logic_vector(WIDTH - 1 downto 0);
	signal lt : std_logic;

begin

	U_MUX_X: entity work.mux_2x1 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => x,
					in2 => sub2mux,
					sel => x_sel,
					output => mux2tmp_x
					);
					
	U_MUX_Y: entity work.mux_2x1 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => y,
					in2 => sub2mux,
					sel => y_sel,
					output => mux2tmp_y
					);
					
	U_TMP_X: entity work.reg 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					input => mux2tmp_x,
					output => tmp2mux_x,
					clk => clk,
					rst => rst,
					load => x_en
					);
					
	U_TMP_Y: entity work.reg 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					input => mux2tmp_y,
					output => tmp2mux_y,
					clk => clk,
					rst => rst,
					load => y_en
					);
					
	U_MUX_A: entity work.mux_2x1 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => tmp2mux_x,
					in2 => tmp2mux_y,
					sel => lt,
					output => mux2sub_a
					);
					
	U_MUX_B: entity work.mux_2x1 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => tmp2mux_y,
					in2 => tmp2mux_x,
					sel => lt,
					output => mux2sub_b
					);
					
	U_SUB: entity work.sub 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => mux2sub_a,
					in2 => mux2sub_b,
					output => sub2mux
					);
				
	U_COMP: entity work.comp 
		generic map(
				WIDTH => WIDTH
				)
		port map (
				in1 => tmp2mux_x,
				in2 => tmp2mux_y,
				in1_lt_in2 => lt,
				in1_ne_in2 => x_ne_y
				);
				
	U_REG_OUT: entity work.reg 
		generic map(
				WIDTH => WIDTH
				)
		port map (
				input => tmp2mux_x,
				output => output,
				rst => rst,
				clk => clk,
				load => output_en
				);
				
	x_lt_y <= lt;
	
end DATAPATH2_ARCH;
			