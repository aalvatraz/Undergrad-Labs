-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS ALU Control

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_alu_ctrl is
	port(
			alu_op		: in std_logic_vector (5 downto 0);
			ir				: in std_logic_vector(5 downto 0);
			load_hi  	: out std_logic;
			load_lo 		: out std_logic;
			op_select	: out std_logic_vector(4 downto 0);
			alu_lo_hi 	: out std_logic_vector(1 downto 0)
		);
end mips_alu_ctrl;

architecture MIPS_ALU_CTRL_ARCH of mips_alu_ctrl is

	begin

	process(alu_op, ir)
	begin

		if(alu_op = "000000" and (ir = "100001" or ir = "100011"  or ir = "100100" or ir = "100101" or ir = "100110" or ir = "101010" or ir = "101011")) then --rtype
				op_select <= ir;

			elsif(alu_op = "000000" and (ir = "011000" or ir ="011001")) then --rtype mult
				op_select <= ir;


			elsif(alu_op = "001001") then --addi
				op_select <= "100001";


			elsif(alu_op = "010000") then --subi
				op_select <= "100011";

			elsif(alu_op = "001100") then --andi
				op_select <= "100100";

			elsif(alu_op = "001101") then --ori
				op_select <= "100101";

			elsif(alu_op = "001110") then --xori
				op_select <= "100110";

			elsif(alu_op = "000000" and ir = "000010") then --srl imm
				op_select <= "000010";

			elsif(alu_op = "000000" and ir = "000000") then --sll imm
				op_select <= "000000";

			elsif(alu_op = "000000" and ir = "000011") then --sra imm
				op_select <= "000011";

			elsif(alu_op = "000000" and ir = "010000") then --mfhi imm

			elsif(alu_op = "000000" and ir = "010010") then --mflo imm

			elsif(alu_op = "001010") then --slti
				op_select <= "101010";

			elsif(alu_op = "001011" ) then --sltiu
				op_select <= "101011";

			elsif(alu_op = "100011") then --load word

			elsif(alu_op = "101011") then --store word

			elsif(alu_op = "000001" or alu_op = "000100" or alu_op = "000101" or alu_op = "000110" or alu_op = "000111" or alu_op = "001000") then --branches
				op_select <= alu_op;

			elsif(alu_op = "000010") then --jump to address

			elsif(alu_op = "000011") then --jump and link

			elsif(alu_op = "000000" and ir = "001000") then --jump register
				
			end if;

end MIPS_ALU_CTRL_ARCH;