-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: Quiz Datapath
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity quiz_dp is
	generic(
			WIDTH : positive := 8
			);
	port(
			clk, rst : in std_logic;
			x, y : in std_logic_vector(WIDTH-1 downto 0);
			output : out std_logic_vector(2*WIDTH-1 downto 0);
			
			y_sel, x_en, y_en, output_en : in std_logic;
			y_zero : out std_logic
		);
end quiz_dp;

architecture QUIZ_DP_ARCH of quiz_dp is

	signal mux2reg_y, sub2mux_y, reg2mult, reg2sub_y :std_logic_vector(WIDTH - 1 downto 0);
	signal mult2out_x :std_logic_vector(2*WIDTH - 1 downto 0);
	signal lt : std_logic;

begin
					
	U_MUX_Y: entity work.mux_2x1 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => y,
					in2 => sub2mux_y,
					sel => y_sel,
					output => mux2reg_y
					);
					
	U_TMP_X: entity work.reg 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					input => x,
					output => reg2mult,
					clk => clk,
					rst => rst,
					load => x_en
					);
					
	U_TMP_Y: entity work.reg 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					input => mux2reg_y,
					output => reg2sub_y,
					clk => clk,
					rst => rst,
					load => y_en
					);
					
	U_SUB: entity work.sub 
			generic map(
					WIDTH => WIDTH
					)
			port map(
					in1 => reg2sub_y,
					in2 => (others => '0') & '1',
					output => sub2mux_y
					);
				
	U_COMP: entity work.comp 
		generic map(
				WIDTH => WIDTH
				)
		port map (
				in1 => sub2mux_y,
				in2 => (others => '0'),
				in1_lt_in2 => open,
				in1_ne_in2 => y_zero
				);
				
	U_MULT: entity work.mult 
		generic map(
				WIDTH => WIDTH
				)
		port map (
				in1 => reg2mult,
				in2 => reg2mult,
				output => output
				);
				
	U_REG_OUT: entity work.reg 
		generic map(
				WIDTH => 2*WIDTH
				)
		port map (
				input => mult2out_x,
				output => output,
				rst => rst,
				clk => clk,
				load => output_en
				);
	
end QUIZ_DP_ARCH;
			