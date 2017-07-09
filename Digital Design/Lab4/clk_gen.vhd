-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 4: Clock Generator

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_gen is
    generic (
        ms_period : positive);          -- amount of ms for button to be
                                        -- pressed before creating clock pulse
    port (
        clk50MHz : in  std_logic;
        rst      : in  std_logic;
        button_n : in  std_logic;
        clk_out  : out std_logic);
end clk_gen;


architecture CLK_GEN_ARCH of clk_gen is

	signal clkDiv : std_logic;
	signal cycles : integer ;
	signal tempClk : std_logic;
begin		

	U_DIV: entity work.clk_div 
		generic map (
					clk_in_freq  => 50000000,
					clk_out_freq  => 1000
						)
		port map(
					clk_in => clk50MHz,
					rst => rst,
					clk_out => clkDiv
					);
			
	process(rst, clkDiv)
	
	begin
	
		if(rst = '1') then
			tempClk <= '0';
			cycles <= 0;
			
		elsif(rising_edge(clkDiv)) then
			if (button_n = '0') then
			
				if(cycles = ms_period) then
					tempClk <= '1';
					cycles <= 1;
					
				else 
				
					if(tempClk = '1') then
						tempClk <= '0';
					end if;
					cycles <= cycles + 1;
					
				end if;
			else
				cycles <= 0;
				tempClk <= '0';
			end if;
		end if;

	end process;
	
	clk_out <= tempClk;		
				
end CLK_GEN_ARCH;