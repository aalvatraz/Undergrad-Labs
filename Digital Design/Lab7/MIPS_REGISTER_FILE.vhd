-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS Register File

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_register_file is 
	generic (
		ADDR_WIDTH : positive;
		WORD_WIDTH : positive
		);

	port(
		clk      		: in std_logic;
		rst     			: in std_logic;
		wr_en   			: in std_logic;
		jump_and_link 	: in std_logic;
		rd_addr0 		: in std_logic_vector (ADDR_WIDTH - 1 downto 0);
		rd_addr1 		: in std_logic_vector (ADDR_WIDTH - 1 downto 0); 
		wr_addr  		: in std_logic_vector (ADDR_WIDTH - 1 downto 0);
		wr_data  		: in std_logic_vector (WORD_WIDTH - 1 downto 0);  
		rd_data0 		: out std_logic_vector (WORD_WIDTH - 1 downto 0);
		rd_data1 		: out std_logic_vector (WORD_WIDTH - 1 downto 0)
	);
end mips_register_file;


architecture MIPS_REGISTER_FILE_ARCH of mips_register_file is 

	type reg_array is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(WORD_WIDTH - 1 downto 0);
	signal regs : reg_array; 
	
begin 

	process (clk, rst)
	begin 
		if (rst = '1') then 
			for i in 0 to 2**ADDR_WIDTH-1 loop
				regs(i) <= (others =>'0');
			end loop;
		elsif (rising_edge(clk)) then 
			if (wr_en = '1') then 
				regs(to_integer(unsigned(wr_addr))) <= wr_data; 
			elsif(jump_and_link = '1') then
			regs(2**ADDR_WIDTH - 1) <= wr_data;
			end if;
		end if;
	end process; 
	

	rd_data0 <= regs(to_integer(unsigned(rd_addr0))); 
	rd_data1 <= regs(to_integer(unsigned(rd_addr1)));

end MIPS_REGISTER_FILE_ARCH;