-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 5: Top Level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	 generic( WIDTH : positive := 4);
    port (
        clk50MHz : in  std_logic;
        switch   : in  std_logic_vector(9 downto 0);
        button   : in  std_logic_vector(2 downto 0);
        led0     : out std_logic_vector(6 downto 0);
        led0_dp  : out std_logic;
        led1     : out std_logic_vector(6 downto 0);
        led1_dp  : out std_logic;
        led2     : out std_logic_vector(6 downto 0);
        led2_dp  : out std_logic;
        led3     : out std_logic_vector(6 downto 0);
        led3_dp  : out std_logic);
end top_level;

architecture STR of top_level is

    component decoder7seg
        port (
            input  : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0));
    end component;

    constant C0              : std_logic_vector(3 downto 0) := (others => '0');
	 signal outputD, outputD1, outputD2 : std_logic_vector (WIDTH-1 downto 0);
    
begin  -- STR
	
    U_GCD1: entity work.gcd(FSMD)
	 generic map( 
			WIDTH => WIDTH
			)
	port map(		
			clk => clk50MHz,
			rst => button(2),
			go  => button(1),
			x => switch(7 downto 4),
			y => switch(3 downto 0),
			output => outputD,
			done => led3_dp
			);
			
		U_GCD2: entity work.gcd(FSM_D1)
	 generic map( 
			WIDTH => WIDTH
			)
	port map(		
			clk => clk50MHz,
			rst => button(2),
			go  => button(1),
			x => switch(7 downto 4),
			y => switch(3 downto 0),
			output => outputD1,
			done => led2_dp
			);
			
	 U_GCD3: entity work.gcd(FSM_D2)
	 generic map( 
			WIDTH => WIDTH
			)
	port map(		
			clk => clk50MHz,
			rst => button(2),
			go  => button(1),
			x => switch(7 downto 4),
			y => switch(3 downto 0),
			output => outputD2,
			done => led1_dp
			);

    U_LED3 : decoder7seg port map (
        input  => outputD,
        output => led3);

    U_LED2 : decoder7seg port map (
        input  => outputD1,
        output => led2);

    U_LED1 : decoder7seg port map (
        input  =>outputD2,
        output => led1);

    U_LED0 : decoder7seg port map (
        input  => C0,
        output => led0);

    --led3_dp <= '1'; -- change to done signal
    --led2_dp <= '1';
    --led1_dp <= '1';
    led0_dp <= '1';

end STR;