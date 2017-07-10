-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS Controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_ctrl is
	port(
			clk, rst 			: in std_logic;
			ir 					: in std_logic_vector(31 downto 0);
			pc_write_cond		: out std_logic;
			pc_write				: out std_logic;
			i_or_d				: out std_logic;
			mem_read				: out std_logic;
			mem_write			: out std_logic;
			mem_to_reg			: out std_logic;
			ir_write				: out std_logic;
			jump_and_link 		: out std_logic;
			is_signed			: out std_logic;
			pc_source			: out std_logic_vector(1 downto 0);
			alu_op   			: out std_logic_vector (5 downto 0);  
			alusrc_A				: out std_logic;
			load_lo				: out std_logic;
			load_hi				: out std_logic;
			alu_lo_hi			: out std_logic_vector(1 downto 0);
			alusrc_B 			: out std_logic_vector (1 downto 0);
			reg_write			: out std_logic;
			reg_dst				: out std_logic
		);

end mips_ctrl;




architecture MIPS_CTRL_ARCH of mips_ctrl is

	type mips_state is (

					IR_FETCH_S,
					IR_FETCH_S2,
					IR_DECODE_S,
					LW_S,
					LW_S2,
					LW_S3,
					LW_S4,
					LW_S5,
					SW_S,
					SW_S2,
					SW_S3,
					SW_S4,
					MFHI_S,
					MFLO_S,
					MEM_ADDR_S,
					MEM_READ_S,
					MEM_WRITE_S,
					MEM_COMP_S,
					R_EXE_S,
					RS_EXE_S,
					R_COMP_S,
					RS_COMP_S,
					IMM_EXE_S,
					IMM_COMP_S,
					BRANCH_S,
					BRANCH_S2,
					BRANCH_S3,
					JUMP_S,
					JUMP_S2,
					JUMP_AND_LINK_S,
					JUMP_AND_LINK_S2,
					JUMP_AND_LINK_S3,
					JUMP_REG_S,
					JUMP_REG_S2
		);

	signal state, next_state : mips_state;
	signal ir_func, ir_opcode : std_logic_vector(5 downto 0);
	signal ir_branch : std_logic_vector(4 downto 0);

begin

	ir_func <= ir(5 downto 0);
	ir_opcode <= ir(31 downto 26);
	ir_branch <= ir(20 downto 16);

	process(clk, rst)
	begin
		if(rst = '1') then
			state <= IR_FETCH_S;

		elsif(rising_edge(clk)) then

			state <= next_state;

		end if;
	end process;

	process(ir_func,ir_opcode,state)
	begin

		pc_write_cond		<= '0';
		pc_write				<= '0';
		i_or_d				<= '0';
		mem_read				<= '0';
		mem_write			<= '0';
		mem_to_reg			<= '0';
		ir_write				<= '0';
		jump_and_link 		<= '0';
		is_signed			<= '0';
		pc_source			<= (others => '0');
		alu_op   			<= (others => '1');
		alusrc_A				<= '0';
		alusrc_B 			<= "01";
		alu_lo_hi			<= (others => '0');
		load_lo 				<= '0';
		load_hi 				<= '0';
		reg_write			<= '0';
		reg_dst				<= '0';
		next_state 			<= state;

		case state is 

		when IR_FETCH_S =>
			mem_read <= '1';
			next_state <= IR_FETCH_S2;

		when IR_FETCH_S2=>
			ir_write <= '1';
			alu_op <= "100001";
			pc_write <= '1';
			next_state <= IR_DECODE_S;
----------------------------------------------------
		when IR_DECODE_S =>
			--alusrc_b <= "11";

			if(ir_opcode = "000000" and (ir_func = "100001" or ir_func = "100011"  or ir_func = "100100" or ir_func = "100101" or ir_func = "100110" or ir_func = "101010" or ir_func = "101011")) then --rtype
				alu_op <= ir_func;
				next_state <= R_EXE_S;

			elsif(ir_opcode = "000000" and (ir_func = "011000" or ir_func ="011001")) then --rtype mult
				alu_op <= ir_func;
				next_state <= RS_EXE_S;

			elsif(ir_opcode = "001001") then --addi
				alu_op <= ir_opcode;
				next_state <= IMM_EXE_S;


			elsif(ir_opcode = "010000") then --subi
				alu_op <= ir_opcode;
				next_state <= IMM_EXE_S;

			elsif(ir_opcode = "001100") then --andi
				alu_op <= ir_opcode;
				next_state <= IMM_EXE_S;

			elsif(ir_opcode = "001101") then --ori
				alu_op <= ir_opcode;
				next_state <= IMM_EXE_S;

			elsif(ir_opcode = "001110") then --xori
				alu_op <= ir_opcode;
				next_state <= IMM_EXE_S;

			elsif(ir_opcode = "000000" and ir_func = "000010") then --srl 
				alu_op <= ir_func;
				next_state <= R_EXE_S;

			elsif(ir_opcode = "000000" and ir_func = "000000") then --sll 
				alu_op <= ir_func;
				next_state <= R_EXE_S;

			elsif(ir_opcode = "000000" and ir_func = "000011") then --sra 
				alu_op <= ir_func;
				next_state <= R_EXE_S;

			elsif(ir_opcode = "000000" and ir_func = "010000") then --mfhi imm
				next_state <= MFHI_S;

			elsif(ir_opcode = "000000" and ir_func = "010010") then --mflo imm
				next_state <= MFLO_S;

			elsif(ir_opcode = "001010") then --slti
				alu_op <= ir_opcode;
				next_state <= IMM_EXE_S;

			elsif(ir_opcode = "001011" ) then --sltiu
				alu_op <= ir_opcode;
				next_state <= IMM_EXE_S;

			elsif(ir_opcode = "100011") then --load word
				next_state<= LW_S;

			elsif(ir_opcode = "101011") then --store word
				next_state <= SW_S;
				alusrc_a <= '1';
				alusrc_b <= "10";

			elsif(ir_opcode = "000001" or ir_opcode = "000100" or ir_opcode = "000101" or ir_opcode = "000110" or ir_opcode = "000111") then --branches
				next_state <= BRANCH_S;

			elsif(ir_opcode = "000010") then --jump to address
				next_state <= JUMP_S;

			elsif(ir_opcode = "000011") then --jump and link
				next_state <= JUMP_AND_LINK_S;

			elsif(ir_opcode = "000000" and ir_func = "001000") then --jump register
				next_state <= JUMP_REG_S;
				
			end if;
------------------------------------------------------
		when LW_S =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= "100001";
			next_state <= LW_S2;

		when LW_S2 =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= "100001";
			i_or_d <= '1';
			next_state <= LW_S3;	

		when LW_S3 =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= "100001";
			i_or_d <= '1';
			next_state <= LW_S4;	

		when LW_S4 =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= "100001";
			i_or_d <= '1';
			mem_to_reg <= '1';
			mem_read <= '1';
			next_state <= LW_S5;	

		when LW_S5 =>
			reg_write <= '1';
			mem_to_reg <= '1';
			next_state <= IR_FETCH_S;
--------------------------------------------------
		when SW_S =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= "100001";
			i_or_d <= '1';
			next_state <= SW_S2;

		when SW_S2 =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= "100001";
			i_or_d <= '1';
			next_state <= SW_S3;

		when SW_S3 =>
			mem_write <= '1';
			i_or_d <= '1';
			next_state <= SW_S4;

		when SW_S4 =>
			next_state <= IR_FETCH_S;
--------------------------------------------------
		when R_EXE_S =>
			alusrc_a <= '1';
			alusrc_b <= "00";
			alu_op <= ir_func;
			--mem_to_reg <= '1';
			next_state <= R_COMP_S;

		when R_COMP_S =>
			alusrc_a <= '1';
			alusrc_b <= "00";
			alu_op <= ir_func;
			reg_dst <= '1';
			reg_write <= '1';
			next_state <= IR_FETCH_S;
----------------------------------------------
		when RS_EXE_S =>
			alusrc_a <= '1';
			alusrc_b <= "00";
			alu_op <= ir_func;
			mem_to_reg <= '1';
			next_state <= RS_COMP_S;

		when RS_COMP_S =>
			alusrc_a <= '1';
			alusrc_b <= "00";
			alu_op <= ir_func;
			load_lo <= '1';
			load_hi <= '1';
			next_state <= IR_FETCH_S;
----------------------------------------------
		when IMM_EXE_S =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= ir_opcode;
			next_state <= IMM_COMP_S;

		when IMM_COMP_S =>
			alusrc_a <= '1';
			alusrc_b <= "10";
			alu_op <= ir_opcode;
			reg_write <= '1';
			next_state <= IR_FETCH_S;
------------------------------------------------
		when MFLO_S =>
			alu_lo_hi <= "01";
			mem_to_reg <= '0';
			reg_write <= '1';
			reg_dst <= '1';
			next_state <= IR_FETCH_S;
--------------------------------------------------
		when MFHI_S =>
			alu_lo_hi <= "10";
			mem_to_reg <= '0';
			reg_write <= '1';
			reg_dst <= '1';
			next_state <= IR_FETCH_S;
------------------------------------------------
		when BRANCH_S =>
			alusrc_b <= "11";	--elect shifted offset + pc(of next instruction)
			alu_op <= "100001"; --add
			next_state <= BRANCH_S2;

		when BRANCH_S2 =>
		alusrc_a <= '1';
		alusrc_b <= "00";
		if(ir_opcode = "000001") then
				if(ir_branch = "00000") then 
					alu_op <= "000001";
				else
					alu_op <= "111111";
				end if;
			else
				alu_op <= ir_opcode;
			end if;
			pc_write_cond <= '1';
			pc_source <= "01";
			next_state <= BRANCH_S3;

		when BRANCH_S3 =>
			next_state <= IR_FETCH_S;
--------------------------------------------------
		when JUMP_S =>
			pc_source <= "10";
			pc_write <= '1';
			next_state <= JUMP_S2;

		when JUMP_S2 =>
			next_state <= IR_FETCH_S;

--------------------------------------------------
		when JUMP_AND_LINK_S =>
			alu_op <= "001000"; --send regamux output to alu_out
			next_state <= JUMP_AND_LINK_S2;

		when JUMP_AND_LINK_S2 =>
			alu_op <= "001000";
			pc_source <= "10";	
			pc_write <= '1';		--write new address to pc register
			jump_and_link <= '1';	--save return address in r31
			--mem_read <= '1';
			next_state <= JUMP_AND_LINK_S3;

		when JUMP_AND_LINK_S3 =>
			next_state <= IR_FETCH_S;

--------------------------------------------------
		when JUMP_REG_S =>
			alu_op <= ir_func;
			alusrc_a <= '1';
			pc_write <= '1';
			next_state <= JUMP_REG_S2;

		when JUMP_REG_S2 =>
			next_state <= IR_FETCH_S;




		when others => null;
		end case;
	end process;
	


end MIPS_CTRL_ARCH;