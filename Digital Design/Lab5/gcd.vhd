-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: GCD Calculator 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
    generic (
        WIDTH : positive := 16);
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        go     : in  std_logic;
        done   : out std_logic := '0';
        x      : in  std_logic_vector(WIDTH-1 downto 0);
        y      : in  std_logic_vector(WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH-1 downto 0) := (others => '0'));
end gcd;

architecture FSMD of gcd is

type gcd_state is (S_INIT, S_WAIT1, S_START, S_GCD, S_DONE, S_WAIT2);
signal state : gcd_state := S_INIT;
signal tmpx, tmpy: std_logic_vector(WIDTH-1 downto 0);

begin  -- FSMD

	process(rst, clk)
	begin
		if(rst = '1') then
			output <= (others => '0');
			done <= '0';
			tmpx <= (others => '0');
			tmpy <= (others => '0');
			state <= S_WAIT1;
		
		elsif(rising_edge(clk)) then
			case state is
			when S_INIT =>
				output <= (others => '0');
				done <= '0';
				state <= S_WAIT1;
				
			when S_WAIT1 =>
				if(go = '1') then
					state <= S_START;
				end if;
				
			when S_START =>
				done <= '0';
				tmpx <= x;
				tmpy <= y;
				state <= S_GCD;
			
			when S_GCD =>
				if(tmpx /= tmpy) then
				
					if(tmpx < tmpy) then
						tmpy <= std_logic_vector(unsigned(tmpy) - unsigned(tmpx));
					else
						tmpx <= std_logic_vector(unsigned(tmpx) - unsigned(tmpy));
					end if;
					
				else
					state <= S_DONE;
				end if;
			
			when S_DONE =>
				output <= tmpx;
				done <= '1';
				state <= S_WAIT2;
			
			when S_WAIT2 =>
				if(go = '0') then
					state <= S_START;
				end if;
			
			when others => null;
			end case;
		
		end if;
	end process;

end FSMD;

architecture FSM_D1 of gcd is

signal x_sel, y_sel, y_en, x_en, output_en, x_lt_y, x_ne_y : std_logic;

begin  -- FSM_D1

 U_CTRL1: entity work.ctrl1
		port map(
			clk => clk,
			rst => rst,
			done => done,
			go => go,
			x_sel => x_sel,
			x_en => x_en,
			y_sel => y_sel,
			y_en => y_en,
			output_en => output_en,
			x_lt_y => x_lt_y,
			x_ne_y => x_ne_y
			);
			
	U_DATAPATH1: entity work.datapath1 	
		generic map(
			WIDTH => WIDTH
			)
		port map(
		clk => clk,
		rst => rst,
		x => x,
		y => y,
		output => output,
		x_sel => x_sel,
		x_en => x_en,
		y_sel => y_sel,
		y_en => y_en,
		output_en => output_en,
		x_lt_y => x_lt_y,
		x_ne_y => x_ne_y
		);
			

end FSM_D1;

architecture FSM_D2 of gcd is

signal x_sel, y_sel, y_en, x_en, output_en, x_lt_y, x_ne_y : std_logic;

begin  -- FSM_D2

 U_CTRL1: entity work.ctrl2
		port map(
			clk => clk,
			rst => rst,
			done => done,
			go => go,
			x_sel => x_sel,
			x_en => x_en,
			y_sel => y_sel,
			y_en => y_en,
			output_en => output_en,
			x_lt_y => x_lt_y,
			x_ne_y => x_ne_y
			);
			
	U_DATAPATH1: entity work.datapath2 	
		generic map(
			WIDTH => WIDTH
			)
		port map(
		clk => clk,
		rst => rst,
		x => x,
		y => y,
		output => output,
		x_sel => x_sel,
		x_en => x_en,
		y_sel => y_sel,
		y_en => y_en,
		output_en => output_en,
		x_lt_y => x_lt_y,
		x_ne_y => x_ne_y
		);

end FSM_D2;


-- EXTRA CREDIT
architecture FSMD2 of gcd is

begin  -- FSMD2



end FSMD2;