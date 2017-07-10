-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS Memory

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_mem is
	port(
		clk, rst : in std_logic;
		mem_read : in std_logic;
		mem_write: in std_logic;
		pcmux	: in std_logic_vector(31 downto 0);
		inporta_en: in std_logic;
		inportb_en: in std_logic;
		inporta : in std_logic_vector(31 downto 0);
		inportb : in std_logic_vector(31 downto 0);
		regb	  : in std_logic_vector(31 downto 0);
		memory : out std_logic_vector(31 downto 0);
		outport : out std_logic_vector(31 downto 0)
		);
end mips_mem;

architecture MIPS_MEM_ARCH of mips_mem is

	signal q, inporta_reg, inportb_reg : std_logic_vector(31 downto 0);
	signal outport_en : std_logic;

begin

	U_RAM: entity work.testcase2
		port map(
				address =>pcmux(7 downto 0),
				clock => clk,
				data => regb,
				wren => mem_write,
				q => q
			);

	U_INA: entity work.reg
		port map(
				clk => clk,
				rst => '0',						--since global reset shouldnt reset these ports
				load => inporta_en,
				input => inporta,
				output => inporta_reg
			);

	U_INB: entity work.reg
		port map(
				clk => clk,
				rst => '0',						--since global reset shouldnt reset these ports
				load => inportb_en,
				input => inportb,
				output => inportb_reg
			);

	U_OUT: entity work.reg
		port map(
				clk => clk,
				rst => rst,						--since global reset shouldnt reset these ports
				load => outport_en,
				input => regb,
				output => outport
			);


	process(mem_read, mem_write, pcmux, inporta_reg, inportb_reg)
	begin

			memory <= q; --possible fault
			outport_en <= '0';

			if((mem_read = '1') and (pcmux = x"0000FFF8")) then 
				memory <= inporta_reg;
			elsif((mem_read = '1') and (pcmux = x"0000FFFC")) then 
				memory <= inportb_reg;
			elsif((mem_write = '1') and (pcmux = x"0000FFFC")) then 
				outport_en <= '1';
			end if;
	end process;

end MIPS_MEM_ARCH;