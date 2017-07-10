-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS Datapath

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_dp is

	port(
			clk, rst 			: in std_logic;
			pc_write_cond		: in std_logic;
			pc_write				: in std_logic; 
			i_or_d				: in std_logic;
			mem_read				: in std_logic;
			mem_write			: in std_logic;
			mem_to_reg			: in std_logic;
			ir_write				: in std_logic;
			jump_and_link 		: in std_logic;
			is_signed			: in std_logic;
			pc_source			: in std_logic_vector (1 downto 0);
			alu_op   			: in std_logic_vector (5 downto 0); 
			alusrc_A				: in std_logic;
			alusrc_B 			: in std_logic_vector (1 downto 0);
			reg_write			: in std_logic;
			reg_dst				: in std_logic;
			inportA				: in std_logic_vector(31 downto 0);
			inportB				: in std_logic_vector(31 downto 0);
			inportA_en			: in std_logic;
			inportB_en			: in std_logic;	
			inport_rst			: in std_logic;
			alu_lo_hi 			: in std_logic_vector(1 downto 0);--
			load_hi 				: in std_logic;--
			load_lo 				: in std_logic;--
			ir_out 				: out std_logic_vector(31 downto 0);
			outport0 			: out std_logic_vector(31 downto 0)
		);

end mips_dp;

architecture MIPS_DP_ARCH of mips_dp is

	signal pc_2_pcmux							: std_logic_vector(31 downto 0);--  
	signal pcmux_2_mem				 		: std_logic_vector(31 downto 0);--
	signal mem_2_regfiles					: std_logic_vector(31 downto 0);--
	signal irregfile_out						: std_logic_vector(31 downto 0);--
	signal dataregfile_2_datamux			: std_logic_vector(31 downto 0);--
	signal irmux_2_regfile					: std_logic_vector(4 downto 0);--
	signal datamux_2_regfile				: std_logic_vector(31 downto 0);--
	signal regfile_2_rega					: std_logic_vector(31 downto 0);--
	signal regfile_2_regb					: std_logic_vector(31 downto 0);--
	signal rega_2_regamux					: std_logic_vector(31 downto 0);--
	signal regb_2_regbmux					: std_logic_vector(31 downto 0);--
	signal signex 								: std_logic_vector(31 downto 0);--
	signal losl2_2_regbmux					: std_logic_vector(31 downto 0);--
	signal hisl2_2_aluoutpcmux				: std_logic_vector(31 downto 0);--
	signal regamux_2_alu						: std_logic_vector(31 downto 0);--
	signal regbmux_2_alu						: std_logic_vector(31 downto 0);--
	signal branch_target						: std_logic;--
	signal result_lo							: std_logic_vector(31 downto 0);--
	signal result_hi 							: std_logic_vector(31 downto 0);--
	signal alu_out 							: std_logic_vector(31 downto 0);--
	signal lo_2_alumux 						: std_logic_vector(31 downto 0);--
	signal hi_2_alumux 						: std_logic_vector(31 downto 0);--
	signal alumux_2_datamux 				: std_logic_vector(31 downto 0);--
	signal aluoutpcmux_2_pc 				: std_logic_vector(31 downto 0);--
	signal pc_load 							: std_logic;


begin


	pc_load <= (branch_target and pc_write_cond) or pc_write;

	U_PC: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => pc_load,
					input => aluoutpcmux_2_pc,
					output => pc_2_pcmux
					);

	U_PC_MUX: entity work.mux_2x1
				generic map(
				 	WIDTH => 32
				 )
				port map(
					in1 => pc_2_pcmux,
					in2 => alu_out,
					sel => i_or_d,
					output => pcmux_2_mem
					);

	U_MEM: entity work.mips_mem 
			port map(
					clk => clk,
					rst => rst,
					mem_read => mem_read,
					mem_write => mem_write,
					pcmux	=>pcmux_2_mem,
					inporta_en => inporta_en,
					inportb_en => inportb_en,
					inporta  => inporta,
					inportb => inportb,
					regb	 => regb_2_regbmux,
					memory => mem_2_regfiles,
					outport =>outport0
				);

	U_IR_REG_FILE: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => ir_write,
					input => mem_2_regfiles,
					output => irregfile_out
					);

	U_DATA_REG_FILE: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => '1',
					input => mem_2_regfiles,
					output => dataregfile_2_datamux
					); 

	U_IR_MUX: entity work.mux_2x1
				generic map(
				 	WIDTH => 5
				 )
				port map(
					in1 => irregfile_out(20 downto 16),
					in2 => irregfile_out(15 downto 11),
					sel => reg_dst,
					output => irmux_2_regfile
					); 

	U_DATA_MUX: entity work.mux_2x1
				generic map(
				 	WIDTH => 32
				 )
				port map(
					in1 => alumux_2_datamux,
					in2 => dataregfile_2_datamux,
					sel => mem_to_reg,
					output => datamux_2_regfile
					); 

	U_REG_FILE: entity work.mips_register_file 
				generic map(
					ADDR_WIDTH => 5,
					WORD_WIDTH => 32
					)
				port map(
					clk => clk,
					rst => rst,
					wr_en => reg_write,
					jump_and_link => jump_and_link,
					rd_addr0 => irregfile_out(25 downto 21),
					rd_addr1 => irregfile_out(20 downto 16),
					wr_addr => irmux_2_regfile,
					rd_data0 => regfile_2_rega,
					rd_data1 => regfile_2_regb,
					wr_data => datamux_2_regfile
				);

	U_IR_SIGNEX: entity work.mips_sign_extend 
						generic map(
							WIDTH => 16
							)
						port map(
							is_signed => is_signed,
							input => irregfile_out(15 downto 0),
							output => signex
							); 

	--U_IR_HI_SL2:  --do the shift in this file
	hisl2_2_aluoutpcmux <= pc_2_pcmux(31 downto 28) & irregfile_out(25 downto 0) & "00";

	--U_IR_LO_SL2:  --do the shift in this file
	losl2_2_regbmux <= signex(29 downto 0) & "00";

	U_REGA: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => '1',			
					input => regfile_2_regA,
					output => rega_2_regamux
					);  

	U_REGB: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => '1',   		
					input => regfile_2_regb,
					output => regb_2_regbmux
					); 

	U_REGA_MUX: entity work.mux_2x1
				generic map(
				 	WIDTH => 32
				 )
				port map(
					in1 => pc_2_pcmux,
					in2 => rega_2_regamux,
					sel => alusrc_a,
					output => regamux_2_alu
					); 

	U_REGB_MUX: entity work.mux_4x1
				generic map(
				 	WIDTH => 32
				 )
				port map(
					in1 => regb_2_regbmux,
					in2 => std_logic_vector(to_unsigned(4, 32)),
					in3 => signex,
					in4 => losl2_2_regbmux,
					sel => alusrc_b,
					output => regbmux_2_alu
					); 

	U_ALU:  entity work.mips_alu 
			port map(
					op_sel => alu_op,
					reg_a => regamux_2_alu,
					reg_b => regbmux_2_alu,
					shift => irregfile_out(10 downto 6),
					result_hi => result_hi,
					result_lo => result_lo,
					branch_target => branch_target
				);

	U_ALU_OUT_REG: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => '1',  			
					input => result_lo,
					output => alu_out
					); 

	U_HI_REG: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => load_hi,
					input => result_hi,
					output => hi_2_alumux
					); 

	U_LO_REG: entity work.reg
				port map(
					clk => clk,
					rst => rst,
					load => load_lo,
					input => result_lo,
					output => lo_2_alumux
					);

	U_ALU_OUT_MUX: entity work.mux_4x1
				generic map(
				 	WIDTH => 32
				 )
				port map(
					in1 => alu_out,
					in2 => lo_2_alumux,
					in3 => hi_2_alumux,
					in4 => (others => '0'),
					sel => alu_lo_hi,
					output => alumux_2_datamux
					);  

	U_ALU_OUT_PC_MUX: entity work.mux_4x1
				generic map(
				 	WIDTH => 32
				 )
				port map(
					in1 => result_lo,
					in2 => alu_out,
					in3 => hisl2_2_aluoutpcmux,
					in4 => (others => '0'),
					sel => pc_source,
					output => aluoutpcmux_2_pc
					);  

	ir_out <= irregfile_out;

end MIPS_DP_ARCH;