-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: CTRL2
library ieee;
use ieee.std_logic_1164.all;

entity ctrl2 is
	port(
		 clk, rst, go, x_lt_y, x_ne_y : in std_logic;
		 x_sel, y_sel, x_en, y_en, output_en,  done : out std_logic
		);
end ctrl2;

architecture CTRL2_ARCH of ctrl2 is
	
	type ctrl2_state is (S_INIT, S_START, S_GCD, S_DONE);
	signal state, next_state : ctrl2_state;

begin
	
	process(clk, rst)
	begin
		if(rst = '1') then
			state <= S_START;
		elsif(rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;
	
	process(go, x_lt_y, x_ne_y, state)
	begin
		x_en <= '0';
			y_en <= '0';
			x_sel <= '0';
			y_sel <= '0';
			output_en <= '0';
			done <= '0';
			next_state <= state;
	
		case state is
		when S_INIT =>
			x_en <= '0';
			y_en <= '0';
			x_sel <= '0';
			y_sel <= '0';
			output_en <= '0';
			done <= '0';
			next_state <= S_START;
			
		when S_START =>
			if(go = '1') then
				next_state <= S_START;
			end if;

			done <= '0';
			output_en <= '0';
			x_sel <= '0';
			y_sel <= '0';
			x_en <= '1';
			y_en <= '1';
			next_state <= S_GCD;
			
			
		when S_GCD =>
			if(x_ne_y = '1') then
			
				if(x_lt_y = '1') then
					y_en <= '1';
					x_en <= '0' ;
					y_sel <= '1';
					x_sel <= '0';
				elsif(x_lt_y = '0') then
					x_en <= '1';
					y_en <= '0' ;
					x_sel <= '1';
					y_sel <= '0';
				end if;
				
			elsif(x_ne_y = '0') then
				next_state <= S_DONE;
				output_en <= '1';
			end if;
				
		when S_DONE =>
			done <= '1';
			x_en <= '0';
			y_en <= '0';
			output_en <= '0';
			if(go = '0') then
					next_state <= S_START;
			end if;
			
		end case;
		
	end process;


	end CTRL2_ARCH;