-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS ALU TB

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_alu_tb is
end mips_alu_tb;

architecture TB of mips_alu_tb is

	
	signal op_sel, shift : std_logic_vector(4 downto 0);
	signal in1, in2, out_hi, out_lo : std_logic_vector(31 downto 0);
	signal branch_target, done, clk : std_logic := '0';

begin

	U_ALU: entity work.mips_alu
			port map(
				op_sel =>op_sel,
				reg_a => in1,
				reg_b  => in2,
				shift => shift,
				result_hi => out_hi,
				result_lo => out_lo,
				branch_target => branch_target
				);

   clk <= not clk and (not done) after 20 ns;

	process
	begin
		
		done <= '0';
		op_sel <= (others => '0');
		in1 <= (others => '0');
		in2 <= (others => '0');
		shift <= (others => '0');


		--test arithmetic functions
		for j in 0 to 7 loop

				in1 <= (others => '0');
				in2 <= (others => '0');

		   	for i in 0 to 10 loop

		   		in2 <= (others => '0');

		   		for k in 0 to 10 loop
	            	wait until rising_edge(clk);
	            	in2 <= std_logic_vector((unsigned(in2) + 1));
            	end loop;

            	in1 <= std_logic_vector((unsigned(in1) + 1));
	         end loop;  -- i

		      	op_sel <= std_logic_vector((unsigned(op_sel) + 1));

	   end loop;

	   --test shifting functions
	   in1 <= (others => '0');

     for j in 8 to 10 loop

     			in1 <= (others => '0');
				shift <= (others => '0');

		   	for i in 0 to 10 loop

		   		shift <= (others => '0');

		   		for k in 0 to 10 loop
	            	wait until rising_edge(clk);
	            	shift <= std_logic_vector((unsigned(shift) + 1));
            	end loop;

            	in1 <= std_logic_vector((unsigned(in1) + 1));
	         end loop;  -- i

		        op_sel <= std_logic_vector((unsigned(op_sel) + 1));

	     end loop;

     
     op_sel <= "01011";

     	for i in 0 to 7 loop

		   wait until rising_edge(clk);

		   in1 <= std_logic_vector(to_unsigned(0, 32));
		   in2 <= std_logic_vector(to_unsigned(1, 32));

		   wait until rising_edge(clk);

		   in1 <= std_logic_vector(to_unsigned(1, 32));
		   in2 <= std_logic_vector(to_unsigned(1, 32));

		   wait until rising_edge(clk);

		   in1 <= std_logic_vector(to_unsigned(1, 32));
		   in2 <= std_logic_vector(to_unsigned(0, 32));

		   op_sel <= std_logic_vector((unsigned(op_sel) + 1));

	   end loop;

		--wait until rising_edge(clk);

	   done <= '1';

   end process;




end TB;