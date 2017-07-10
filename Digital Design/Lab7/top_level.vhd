-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS Top Level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
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

		signal outport0				: std_logic_vector(31 downto 0);
    
begin  -- STR

	U_MIPS : entity work.MIPS port map (
		inportA	=> "0000000000000000000000" & switch,
		inportB	=> "0000000000000000000000" & switch,
		outport0	=> outport0,
		inportA_en	=> (not button(2)),
		clk => clk50MHz,
		rst => (not button(0)),
		inportB_en	=> (not button(1))
		);

	

    U_LED3 : entity work.decoder7seg port map (
        input  => outport0(15 downto 12),
        output => led3);

    U_LED2 : entity work.decoder7seg port map (
        input  => outport0(11 downto 8),
        output => led2);

    U_LED1 : entity work.decoder7seg port map (
        input  =>outport0(7 downto 4),
        output => led1);

    U_LED0 : entity work.decoder7seg port map (
        input  => outport0(3 downto 0),
        output => led0);

    led3_dp <= '1';
    led2_dp <= '1';
    led1_dp <= '1';
    led0_dp <= '1';

end STR;