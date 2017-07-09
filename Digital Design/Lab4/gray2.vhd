-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 4: Gray 2

library ieee;
use ieee.std_logic_1164.all;

entity gray2 is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        output : out std_logic_vector(3 downto 0));
end gray2;

architecture GRAY2_ARCH of gray2 is

type gray2_state is (S_0, S_1, S_2, S_3, S_4, S_5, S_6, S_7, S_8, S_9, S_10, S_11, S_12, S_13, S_14, S_15);
signal state, next_state : gray2_state;

begin

	process(clk, rst)
	begin
		if(rst = '1') then
			state <= S_0;
		elsif(rising_edge(clk)) then
			state <=next_state;
		end if;
	end process;

	process(clk, rst)
	begin
		case state is
		when S_0 =>
			output <= "0000";
			next_state <= S_1;
		when S_1 =>
			output <= "0001";
			next_state <= S_2;
		when S_2 =>
			output <= "0011";
			next_state <= S_3;
		when S_3 =>
			output <= "0010";
			next_state <= S_4;
		when S_4 =>
			output <= "0110";
			next_state <= S_5;
		when S_5 =>
			output <= "0111";
			next_state <= S_6;
		when S_6 =>
			output <= "0101";
			next_state <= S_7;
		when S_7 =>
			output <= "0100";
			next_state <= S_8;
		when S_8 =>
			output <= "1100";
			next_state <= S_9;
		when S_9 =>
			output <= "1101";
			next_state <= S_10;
		when S_10 =>
			output <= "1111";
			next_state <= S_11;
		when S_11 =>
			output <= "1110";
			next_state <= S_12;
		when S_12 =>
			output <= "1010";
			next_state <= S_13;
		when S_13 =>
			output <= "1011";
			next_state <= S_14;
		when S_14 =>
			output <= "1001";
			next_state <= S_15;
		when S_15 =>
			output <= "1000";
			next_state <= S_0;
		end case;
	end process;

end GRAY2_ARCH;