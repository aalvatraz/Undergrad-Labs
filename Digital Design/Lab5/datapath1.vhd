-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: Datapath1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath1 is
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
end datapath1;

architecture DATAPATH1_ARCH of datapath1 is

	signal mux2tmp_x, mux2tmp_y, tmp2sub_x, tmp2sub_y, sub2mux_x, sub2mux_y : std_logic_vector(WIDTH - 1 downto 0);

begin

	U_MUX_X: entity work.mux_2x1 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => x,
					in2 => sub2mux_x,
					sel => x_sel,
					output => mux2tmp_x
					);
					
	U_MUX_Y: entity work.mux_2x1 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => y,
					in2 => sub2mux_y,
					sel => y_sel,
					output => mux2tmp_y
					);
					
	U_TMP_X: entity work.reg 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					input => mux2tmp_x,
					output => tmp2sub_x,
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
					output => tmp2sub_y,
					clk => clk,
					rst => rst,
					load => y_en
					);
					
	U_SUB_X: entity work.sub 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 =>tmp2sub_x,
					in2 => tmp2sub_y,
					output => sub2mux_x
					);
					
	U_SUB_Y: entity work.sub 
		generic map(
				WIDTH => WIDTH
				)
		port map(
				in1 =>tmp2sub_y,
				in2 => tmp2sub_x,
				output => sub2mux_y
				);
				
	U_COMP: entity work.comp 
		generic map(
				WIDTH => WIDTH
				)
		port map (
				in1 => tmp2sub_x,
				in2 => tmp2sub_y,
				in1_lt_in2 => x_lt_y,
				in1_ne_in2 => x_ne_y
				);
	U_REG_OUT: entity work.reg 
		generic map(
				WIDTH => WIDTH
				)
		port map (
				input => tmp2sub_x,
				output => output,
				rst => rst,
				clk => clk,
				load => output_en
				);
				
end DATAPATH1_ARCH;
			