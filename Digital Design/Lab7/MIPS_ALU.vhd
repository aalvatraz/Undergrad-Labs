-- Adrian Alvarez 
-- University of Florida
-- EEL4712 Digital Design
-- Lab 7: MIPS ALU

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_alu is
	port(
			op_sel: in std_logic_vector (5 downto 0); --maybe more...
			reg_a, reg_b : in std_logic_vector(31 downto 0);
			shift : in std_logic_vector(4 downto 0);
			result_hi, result_lo : out std_logic_vector(31 downto 0);
			branch_target: out std_logic
		);
end mips_alu;

architecture MIPS_ALU_ARCH of mips_alu is

begin

	process(op_sel, reg_a, reg_b, shift)

	variable result : std_logic_vector(31 downto 0);
	variable result_mult :std_logic_vector(63 downto 0);

	begin

		result_hi <= (others => '0');
		result_lo <= (others => '0');
		result_mult := (others => '0');
		result := (others => '0');
		branch_target <= '0';

		case op_sel is 

		when ("100001"  ) =>

			result := std_logic_vector(resize(unsigned(reg_a) + unsigned(reg_b), 32));  				--add unsigned/add immediate unsigned
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("001001" ) =>

			result := std_logic_vector(resize(unsigned(reg_a) + unsigned(reg_b), 32));  				--add immediate unsigned
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("100011") =>

			result := std_logic_vector(unsigned(reg_a) - unsigned(reg_b));  				--sub unsigned
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("010000") =>

			result := std_logic_vector(unsigned(reg_a) - unsigned(reg_b));  				--sub imediate unsigned
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when "011000" =>

			result_mult := std_logic_vector(signed(reg_a) * signed(reg_b));      				--mult signed
			result_hi <= result_mult(63 downto 32);
			result_lo <= result_mult(31 downto 0);

		when "011001" =>

			result_mult := std_logic_vector(unsigned(reg_a) * unsigned(reg_b));  				--mult unsigned
			result_hi <= result_mult(63 downto 32);
			result_lo <= result_mult(31 downto 0);

		when ("100100") =>

			result := std_logic_vector(unsigned(reg_a) and unsigned(reg_b)); 				--and
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("001100") =>

			result := std_logic_vector(unsigned(reg_a) and unsigned(reg_b)); 				--andi
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("100101" ) =>

			result := std_logic_vector(unsigned(reg_a) or unsigned(reg_b));					--or
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("001101") =>

			result := std_logic_vector(unsigned(reg_a) or unsigned(reg_b));					--ori
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("100110") =>

			result := std_logic_vector(unsigned(reg_a) xor unsigned(reg_b));				--xor
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when ("001110") =>

			result := std_logic_vector(unsigned(reg_a) xor unsigned(reg_b));				--xori
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when "000010" =>

			result := std_logic_vector(shift_right(unsigned(reg_b) , to_integer(unsigned(shift))));				--srl
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when "000000" =>

			result := std_logic_vector(shift_left(unsigned(reg_b) , to_integer(unsigned(shift))));				--sll
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when "000011" =>

			result := std_logic_vector(shift_right(signed(reg_b) , to_integer(unsigned(shift))));						--sra
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when "101010" =>

			if( signed(reg_a) < signed(reg_b) ) then												--set on less than signed (reg & immediate)
				result := std_logic_vector(to_signed(1, 32));
				result_hi <= (others => '0');
				result_lo <= result(31 downto 0);
			end if;
			

		when "101011" =>

			if( unsigned(reg_a) < unsigned(reg_b) ) then											--set on less than unsigned (reg & immediate)
				result := std_logic_vector(to_signed(1, 32));
				result_hi <= (others => '0');
				result_lo <= result(31 downto 0);
			end if;
			

		when "000100" =>

			if( reg_a = reg_b ) then																	--branch if equal
				branch_target <= '1';
			end if;

		when "000101" =>

			if( reg_a /= reg_b ) then																	--branch if not equal
				branch_target <= '1';
			end if;

		when "000110" =>

			if( signed(reg_a) <= 0 ) then																--branch if lower or equal to zero
				branch_target <= '1';
			end if;

		when "000111" =>

			if( signed(reg_a) > 0 ) then															--branch if greater than zero
				branch_target <= '1';
			end if;

		when "000001" =>

			if( signed(reg_a) < 0 ) then																--branch if less than zero
				branch_target <= '1';
			end if;

		when "111111" =>----

			if( unsigned(reg_a) >= 0 ) then															--branch if greater or equal to zero
				branch_target <= '1';
			end if;

		when "001000" =>
			result := reg_a;  				--jump (pass rega thru)
			result_hi <= (others => '0');
			result_lo <= result(31 downto 0);

		when others =>

			null;

		end case;

	end process;

end MIPS_ALU_ARCH;
