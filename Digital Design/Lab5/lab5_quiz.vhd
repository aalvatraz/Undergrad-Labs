-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: power Calculator  QUIZ

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
    generic (
        WIDTH : positive := 4);
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        go     : in  std_logic;
        done   : out std_logic := '0';
        x      : in  std_logic_vector(WIDTH-1 downto 0);
        y      : in  std_logic_vector(WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH-1 downto 0) := (others => '0'));
end gcd;

architecture FSM_D2 of gcd is

signal y_sel, y_en, x_en, output_en, y_zero : std_logic;

begin  -- FSM_D2

 U_CTRL1: entity work.quiz_ctrl
		port map(
			clk => clk,
			rst => rst,
			done => done,
			go => go,
			x_en => x_en,
			y_sel => y_sel,
			y_en => y_en,
			output_en => output_en,
			y_zero => y_zero
			);
			
	U_DATAPATH1: entity work.quiz_dp 	
		generic map(
			WIDTH => WIDTH
			)
		port map(
		clk => clk,
		rst => rst,
		x => x,
		y => y,
		output => output,
		x_en => x_en,
		y_sel => y_sel,
		y_en => y_en,
		output_en => output_en,
		y_zero => y_zero
		);

end FSM_D2;