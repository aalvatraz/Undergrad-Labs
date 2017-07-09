-- Adrian Alvarez
-- University of Florida
--EEL4712 Digital Design
--Lab 2: Generic Width ALU_ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------
--          ENTITY         --
-- Generic width ALU using --
-- numeric_std package     --
-----------------------------

entity alu_ns is
generic (
WIDTH : positive := 16
);
port (
		input1   : in std_logic_vector(WIDTH-1 downto 0);
		input2   : in std_logic_vector(WIDTH-1 downto 0);
		sel      : in std_logic_vector(3 downto 0);
		output   : out std_logic_vector(WIDTH-1 downto 0);
		overflow : out std_logic
);
end alu_ns;

-----------------------------
--       Architecture      --
-- Generic width ALU using --
-- numeric_std package     --
-----------------------------
architecture ALU_NS_ARCH of alu_ns is
begin

	process(input1, input2, sel)
	
	--variable for width+1 output bus
	variable temp : std_logic_vector(WIDTH downto 0) ;
	variable mult_temp : std_logic_vector(2*WIDTH - 1 downto 0);
	
	begin
		case sel is
			when x"0" =>
			temp := std_logic_vector( unsigned('0' & input1) + unsigned('0' & input2) );
			overflow <= temp(WIDTH);
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"1" =>
			temp := std_logic_vector( unsigned('0' & input1) - unsigned('0' & input2) );
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"2" =>
			mult_temp := std_logic_vector( ( unsigned(input1) * unsigned(input2) ) ); 
			if(unsigned(mult_temp(2*WIDTH-1 downto WIDTH)) > 0) then
				overflow <= '1';
			else
				overflow <= '0';
			end if;
			output <= std_logic_vector( resize( unsigned(mult_temp), WIDTH ) );
			
			when x"3" =>
			temp := ('0' & input1) and ('0' & input2) ; 
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"4" =>
			temp := ('0' & input1) or ('0' & input2) ;
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"5" =>
			temp := ('0' & input1) xor ('0' & input2) ;
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"6" =>
			temp := ('0' & input1) nor ('0' & input2) ; 
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"7" =>
			temp := std_logic_vector( ('0' & (not input1) ) ); 
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"8" =>
			overflow <= input1(WIDTH - 1);
			temp := std_logic_vector( resize( shift_left( unsigned('0' & input1) , 1 ), WIDTH + 1 ) );
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"9" =>
			temp := std_logic_vector( resize( shift_right( unsigned('0' & input1) , 1 ), WIDTH + 1 ) );
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"A" =>
			temp := std_logic_vector( resize( rotate_left( unsigned(input1) , ( WIDTH/2 + (WIDTH mod 2) ) ), WIDTH + 1 ) ) ;
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"B" =>
			for i in (WIDTH-1) downto 0 loop	
					temp((WIDTH - 1) - i) := input1(i);
			end loop;
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
			
			when x"E"=>
			overflow <= '0';
			output <= std_logic_vector( resize( unsigned((not input2(WIDTH-1 downto WIDTH/2)) & std_logic_vector( rotate_left( unsigned(input1(3 downto 0)) , 2 ) )), output'length)) ;
			
			when others =>
			overflow <= '0';
			temp := (others => '0');
			output <= std_logic_vector( resize( unsigned(temp), WIDTH ) );
	
	end case;
	
	temp := (others => '0');
	
	end process;


end ALU_NS_ARCH;