-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 4: Gray 1

library ieee;
use ieee.std_logic_1164.all;

entity gray1 is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        output : out std_logic_vector(3 downto 0)  := "0000" );
end gray1;


architecture GRAY1_ARCH of gray1 is

type gray1_state is (S_0, S_1, S_2, S_3, S_4, S_5, S_6, S_7, S_8, S_9, S_10, S_11, S_12, S_13, S_14, S_15);
signal state : gray1_state;

begin

	process(clk, rst)
	begin
		if(rst = '1') then
		output <= "0000";
			state <= S_0;
		elsif(rising_edge(clk)) then
			case state is
			when S_0 =>
				output <= "0000";
				state <= S_1;
			when S_1 =>
				output <= "0001";
				state <= S_2;
			when S_2 =>
				output <= "0011";
				state <= S_3;
			when S_3 =>
				output <= "0010";
				state <= S_4;
			when S_4 =>
				output <= "0110";
				state <= S_5;
			when S_5 =>
				output <= "0111";
				state <= S_6;
			when S_6 =>
				output <= "0101";
				state <= S_7;
			when S_7 =>
				output <= "0100";
				state <= S_8;
			when S_8 =>
				output <= "1100";
				state <= S_9;
			when S_9 =>
				output <= "1101";
				state <= S_10;
			when S_10 =>
				output <= "1111";
				state <= S_11;
			when S_11 =>
				output <= "1110";
				state <= S_12;
			when S_12 =>
				output <= "1010";
				state <= S_13;
			when S_13 =>
				output <= "1011";
				state <= S_14;
			when S_14 =>
				output <= "1001";
				state <= S_15;
			when S_15 =>
				output <= "1000";
				state <= S_0;
			end case;
		end if;
	end process;

end GRAY1_ARCH;