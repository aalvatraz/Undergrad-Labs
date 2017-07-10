-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS Memory TB

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_dp_tb is
end mips_dp_tb;

architecture TB of mips_dp_tb is

	signal clk, rst, load   	: std_logic := '0';
	signal done						: std_logic := '0';
	signal pc_write_cond			: std_logic;
	signal pc_write				: std_logic; 
	signal i_or_d					: std_logic;
	signal mem_read				: std_logic;
	signal mem_write				: std_logic;
	signal mem_to_reg				: std_logic;
	signal ir_write				: std_logic;
	signal data_write				: std_logic;							--added
	signal jump_and_link 		: std_logic;
	signal is_signed				: std_logic;
	signal pc_source				: std_logic_vector (1 downto 0);
	signal alu_op   				: std_logic_vector (4 downto 0);  --not sure how many bits
	signal alusrc_A				: std_logic;
	signal alusrc_B 				: std_logic_vector (1 downto 0);
	signal rega_en					: std_logic;							--added
	signal regb_en					: std_logic;							--added
	signal aluout_en				: std_logic;							--added
	signal reg_write				: std_logic;
	signal reg_dst					: std_logic;
	signal inportA					: std_logic_vector(31 downto 0);
	signal inportB					: std_logic_vector(31 downto 0);
	signal inportA_en				: std_logic;
	signal inportB_en				: std_logic;	
	signal inport_rst				: std_logic;
	signal alu_lo_hi 				: std_logic_vector(1 downto 0);--
	signal load_hi 				: std_logic;--
	signal load_lo 				: std_logic;--
	signal outport0 				: std_logic_vector(31 downto 0);

begin

	U_DP: entity work.mips_dp
		port map(
			clk				=> clk,
			rst 				=> rst,
			load 				=> load,
			pc_write_cond 	=> pc_write_cond,
			pc_write 		=>	pc_write,
			i_or_d 			=>	i_or_d,
			mem_read			=>	mem_read,
			mem_write 		=>	mem_write,
			mem_to_reg 		=>	mem_to_reg,
			ir_write	 		=>	ir_write,
			data_write		=>	data_write,
			jump_and_link  =>	jump_and_link,
			is_signed 		=> is_signed,
			pc_source 		=>	pc_source,
			alu_op    		=>	alu_op,
			alusrc_A	 		=>	alusrc_A,
			alusrc_B  		=>	alusrc_B,
			rega_en		 	=>	rega_en,					
			regb_en		 	=>	regb_en,		
			aluout_en	 	=>	aluout_en,					
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

	clk <= not clk and (not done) after 20 ns;

	process
	begin

		pc_write_cond		<=	'0';
		pc_write				<=	'0';
		i_or_d				<=	'0';
		mem_read				<=	'0';
		mem_write			<=	'0';
		mem_to_reg			<=	'0';
		ir_write				<=	'0';
		data_write			<=	'0';
		jump_and_link 		<=	'0';
		is_signed			<=	'0';
		pc_source			<=	(others => '0');
		alu_op   			<=	(others => '0');
		alusrc_A				<=	'0';
		alusrc_B 			<=	(others => '0');
		rega_en				<=	'0';
		regb_en				<=	'0';
		aluout_en			<=	'0';
		reg_write			<=	'0';
		reg_dst				<=	'0';
		inportA				<=	(others => '0');
		inportB				<=	(others => '0');
		inportA_en			<=	'0';
		inportB_en			<=	'0';
		inport_rst			<=	'0';
		alu_lo_hi 			<=	(others => '0');
		load_hi 				<=	'0';
		load_lo 				<=	'0';

		rst <= '1';
		wait for 100 ns;
		rst <= '0';

	--read from sram
		mem_read <= '1';
		data_write <= '1';
		wait until rising_edge(clk);

	--increment pc
		mem_read <= '0';
		data_write <= '0';
		alu_op <= "00001";
		alusrc_a <= '0';
		alusrc_b <= "01";
		pc_write <= '1';
		wait until rising_edge(clk);
		pc_write <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);

	--write to IR 
		pc_write <= '0';
		alu_op <= "00000";
		alusrc_a <= '0';
		alusrc_b <= "00";
		mem_read <= '1';
		ir_write <= '1';
		wait until rising_edge(clk);

	--write to data to regfile
		mem_read <= '0';
		ir_write <= '0';
		reg_dst <= '1'; --ir_mux select = 1
		mem_to_reg <= '1'; --data_reg select = 0
		reg_write <= '1';
		wait until rising_edge(clk);

	--write to registers
		reg_write <= '0';
		reg_dst <= '0';
		rega_en <= '1';
		regb_en <= '1';
		wait until rising_edge(clk);

	--increment pc
		rega_en <= '0';
		regb_en <= '0';
		alu_op <= "00001";
		alusrc_a <= '0';
		alusrc_b <= "01";
		pc_write <= '1';
		wait until rising_edge(clk);
		pc_write <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);

	--write to IR 
		pc_write <= '0';
		alu_op <= "00000";
		alusrc_a <= '1';
		alusrc_b <= "10";
		mem_read <= '1';
		ir_write <= '1';
		wait until rising_edge(clk);	
		wait until rising_edge(clk);

	--alu
		alu_op <= "00101";
		load_lo <= '1';
		wait until rising_edge(clk);


	--pc inc
		load_lo <= '0';
		alu_op <= "00001";
		alusrc_a <= '0';
		alusrc_b <= "01";
		pc_write <= '1';
		wait until rising_edge(clk);
		pc_write <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);



		done <= '1';

		wait for 1000 ns;
	end process;

end TB;