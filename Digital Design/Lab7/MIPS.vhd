-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips is
	port(
		inportA				: in std_logic_vector(31 downto 0);
		inportB				: in std_logic_vector(31 downto 0);
		outport0				: out std_logic_vector(31 downto 0);
		inportA_en			: in std_logic;
		clk, rst 		  	: in std_logic;
		inportB_en			: in std_logic
		);
end mips;

architecture MIPS_ARCH of mips is

	signal pc_write_cond			: std_logic;
	signal pc_write				: std_logic; 
	signal i_or_d					: std_logic;
	signal mem_read				: std_logic;
	signal mem_write				: std_logic;
	signal mem_to_reg				: std_logic;
	signal ir_write				: std_logic;
	signal jump_and_link 		: std_logic;
	signal is_signed				: std_logic;
	signal pc_source				: std_logic_vector (1 downto 0);
	signal alu_op   				: std_logic_vector (5 downto 0);  --not sure how many bits
	signal alusrc_A				: std_logic;
	signal alusrc_B 				: std_logic_vector (1 downto 0);
	signal reg_write				: std_logic;
	signal reg_dst					: std_logic;
	signal inport_rst				: std_logic;
	signal alu_lo_hi 				: std_logic_vector(1 downto 0);--
	signal load_hi 				: std_logic;--
	signal load_lo 				: std_logic;--
	signal ir 						: std_logic_vector(31 downto 0);

begin

	U_DP: entity work.mips_dp
		port map(
			clk				=> clk,
			rst 				=> rst,
			pc_write_cond 	=> pc_write_cond,
			pc_write 		=>	pc_write,
			i_or_d 			=>	i_or_d,
			mem_read			=>	mem_read,
			mem_write 		=>	mem_write,
			mem_to_reg 		=>	mem_to_reg,
			ir_write	 		=>	ir_write,
			ir_out 			=> ir,
			jump_and_link  =>	jump_and_link,
			is_signed 		=> is_signed,
			pc_source 		=>	pc_source,
			alu_op    		=>	alu_op,
			alusrc_A	 		=>	alusrc_A,
			alusrc_B  		=>	alusrc_B,					
			reg_write	 	=>	reg_write,
			reg_dst		 	=>	reg_dst,
			inportA		 	=>	inportA,
			inportB		 	=>	inportB,
			inportA_en		=>	inportA_en,
			inportB_en	 	=>	inportB_en,
			inport_rst		=>	inport_rst,
			alu_lo_hi 	 	=>	alu_lo_hi,
			load_hi 		 	=>	load_hi,
			load_lo 			=>	load_lo,
			outport0 		=>	outport0
			);

	U_CTRL: entity work.mips_ctrl
		port map(
			clk				=> clk,
			rst 				=> rst,
			ir 		 		=> ir,
			pc_write_cond  => pc_write_cond,
			pc_write 		=>	pc_write,
			i_or_d 			=>	i_or_d,
			mem_read			=>	mem_read,
			mem_write 		=>	mem_write,
			mem_to_reg 		=>	mem_to_reg,
			ir_write	 		=>	ir_write,
			jump_and_link  =>	jump_and_link,
			is_signed 		=> is_signed,
			pc_source 		=>	pc_source,
			alu_op    		=>	alu_op,
			alusrc_A	 		=>	alusrc_A,
			alusrc_B  		=>	alusrc_B,
			load_hi 		 	=>	load_hi,
			load_lo 			=>	load_lo,		
			alu_lo_hi		=> alu_lo_hi,				
			reg_write	 	=>	reg_write,
			reg_dst		 	=>	reg_dst
			);

end MIPS_ARCH;