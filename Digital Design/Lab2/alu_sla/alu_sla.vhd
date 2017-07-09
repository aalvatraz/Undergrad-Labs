-- Adrian Alvarez
-- University of Florida
--EEL4712 Digital Design
--Lab 2: Generic Width ALU_ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-----------------------------
--          ENTITY         --
-- Generic width ALU using --
-- numeric_std package     --
-----------------------------

entity alu_sla is

	generic (
		WIDTH : positive := 8
		);
		
	port (
		input1 : in std_logic_vector(WIDTH-1 downto 0);
		input2 : in std_logic_vector(WIDTH-1 downto 0);
		sel : in std_logic_vector(3 downto 0);
		output : out std_logic_vector(WIDTH-1 downto 0);
		overflow : out std_logic
		);
		
end alu_sla;

-----------------------------
--       Architecture      --
-- Generic width ALU using --
-- numeric_std package     --
-----------------------------
architecture ALU_SLA_ARCH of alu_sla is
begin

	process(input1, input2, sel)
	
	--variable for width+1 output bus
	variable temp : std_logic_vector(WIDTH downto 0) ;
	variable mult_temp : std_logic_vector(2*WIDTH - 1 downto 0);
	
	begin
		case sel is
			when x"0" =>
			temp := std_logic_vector( unsigned(('0' & input1) + ('0' & input2) ) );
			overflow <= temp(WIDTH);
			output <= conv_std_logic_vector( unsigned(temp), output'length );
			
			when x"1" =>
			temp := conv_std_logic_vector( unsigned(input1 - input2) , temp'length );
			overflow <= temp(WIDTH);
			output <= conv_std_logic_vector( unsigned(temp), output'length );
			
			when x"2" =>
			mult_temp := conv_std_logic_vector(  unsigned(input1 * input2), mult_temp'length  ); 
			if(unsigned(mult_temp(2*WIDTH-1 downto WIDTH)) > 0) then
				overflow <= '1';
			else
				overflow <= '0';
			end if;
			output <= conv_std_logic_vector( unsigned(mult_temp), output'length );
			
			when x"3" =>
			temp := ('0' & input1) and ('0' & input2); 
			overflow <= '0';
			output <= conv_std_logic_vector( unsigned(temp), output'length );
			
			when x"4" =>
			temp := ('0' & input1) or ('0' & input2) ;
			overflow <= '0';
			output <= conv_std_logic_vector( unsigned(temp), output'length );
			
			when x"5" =>
			temp := ('0' & input1) xor ('0' & input2) ;
			overflow <= '0';
			output <= conv_std_logic_vector( unsigned(temp), output'length );
			
			when x"6" =>
			temp := ('0' & input1) nor ('0' & input2) ; 
			overflow <= '0';
			output <= conv_std_logic_vector( unsigned(temp), output'length );
			
			when x"7" =>
			temp :=  ('0' & (not input1) ); 
			overflow <= '0';
			output <= conv_std_logic_vector( unsigned(temp), output'length );
			
			when x"8" =>
			overflow <= input1(WIDTH - 1);
			temp := input1 & '0' ;
			output <= temp( WIDTH-1 downto 0 );
			
			when x"9" =>
			temp := '0' & input1 ;
			overflow <= '0';
			output <= temp( WIDTH downto 1 );
			
			when x"A" =>
			if(WIDTH mod 2 = 1) then
				output <= input1(((WIDTH/2)) downto 0) & input1(WIDTH-1 downto (WIDTH/2 + 1));
			else
			 output <= input1( (WIDTH/2 - 1) downto 0) & input1(WIDTH-1 downto WIDTH/2);
			 end if;
			overflow <= '0';
			
			when x"B" =>
			for i in (WIDTH-1) downto 0 loop	
					output((WIDTH - 1) - i) <= input1(i);
			end loop;
			overflow <= '0';
			
			when others =>
			overflow <= '0';
			output <= (others => '0');
	
	end case;
	
	temp := (others => '0');
	
	end process;

end ALU_SLA_ARCH;