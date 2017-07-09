-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 2: ALU_NS testbench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_ns_tb is
end alu_ns_tb;

architecture TB of alu_ns_tb is

	component alu_ns
	
		generic(
				WIDTH : positive := 16
			);
			
		port(
			input1   : in  std_logic_vector(WIDTH-1 downto 0);
            input2   : in  std_logic_vector(WIDTH-1 downto 0);
            sel      : in  std_logic_vector(3 downto 0);
            output   : out std_logic_vector(WIDTH-1 downto 0);
            overflow : out std_logic
			);
			
	end component;

	constant WIDTH  : positive                           := 8;
    signal input1   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal input2   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal sel      : std_logic_vector(3 downto 0)       := (others => '0');
    signal output   : std_logic_vector(WIDTH-1 downto 0);
    signal overflow : std_logic;
	
begin  -- TB

    UUT : alu_ns
        generic map (WIDTH => WIDTH)
        port map (
            input1   => input1,
            input2   => input2,
            sel      => sel,
            output   => output,
            overflow => overflow);

    process
    begin

        -- test 2+6 (no overflow)
        sel    <= "0000";
        input1 <= conv_std_logic_vector(2, input1'length);
        input2 <= conv_std_logic_vector(6, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(8, output'length)) report "Error : 2+6 = " & integer'image(conv_integer(output)) & " instead of 8" severity warning;
        assert(overflow = '0') report "Error                                   : overflow incorrect for 2+8" severity warning;

        -- test 250+50 (with overflow)
        sel    <= x"0";
        input1 <= conv_std_logic_vector(250, input1'length);
        input2 <= conv_std_logic_vector(50, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(300, output'length)) report "Error : 250+50 = " & integer'image(conv_integer(output)) & " instead of 44" severity warning;
        assert(overflow = '1') report "Error                                     : overflow incorrect for 250+50" severity warning;
		
		-- test 250 - 50
		sel    <= x"1";
		input1 <= conv_std_logic_vector(250, input1'length);
		input2 <= conv_std_logic_vector(50, input2'length);
		wait for 40 ns;
		assert( output = conv_std_logic_vector(200, output'length) ) report "Error : 250 - 50 = 50" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for subtraction";
		
        -- test 5*6
        sel    <= x"2";
        input1 <= conv_std_logic_vector(5, input1'length);
        input2 <= conv_std_logic_vector(6, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(30, output'length)) report "Error : 5*6 = " & integer'image(conv_integer(output)) & " instead of 30" severity warning;
        assert(overflow = '0') report "Error                                    : overflow incorrect for 5*6" severity warning;

        -- test 50*60
        sel    <= x"2";
        input1 <= conv_std_logic_vector(64, input1'length);
        input2 <= conv_std_logic_vector(64, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(4096, output'length)) report "Error : 64*64 = " & integer'image(conv_integer(output)) & " instead of 0" severity warning;
        assert(overflow = '1') report "Error                                      : overflow incorrect for 64*64" severity warning;

		-- test 5 and A
		sel    <= x"3";
		input1 <= conv_std_logic_vector(5, input1'length);
		input2 <= conv_std_logic_vector(10, input2'length);
		wait for 40 ns;
		assert( output = conv_std_logic_vector(0, output'length) ) report "Error : 5 & 10 = 0" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for and";
		
		-- test 5 or A
		sel    <= x"4";
		input1 <= conv_std_logic_vector(5, input1'length);
		input2 <= conv_std_logic_vector(10, input2'length);
		wait for 40 ns;
		assert( output = conv_std_logic_vector(15, output'length) ) report "Error : 5 or 10 = 0xF" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for or";
		
		-- test 5 xor 3
		sel    <= x"5";
		input1 <= conv_std_logic_vector(3, input1'length);
		input2 <= conv_std_logic_vector(5, input2'length);
		wait for 40 ns;
		assert( output = conv_std_logic_vector(6, output'length) ) report "Error : 5 xor 3 = 6" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for xor";
		
		-- test 5 nor 3
		sel    <= x"6";
		input1 <= conv_std_logic_vector(3, input1'length);
		input2 <= conv_std_logic_vector(5, input2'length);
		wait for 40 ns;
		--assert( output = conv_std_logic_vector(8, output'length) ) report "Error : 5 nor 3 = 8" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for nor";
		
		-- test not A
		sel    <= x"7";
		input1 <= conv_std_logic_vector(10, input1'length);
		input2 <= conv_std_logic_vector(5, input2'length);
		wait for 40 ns;
		--assert( output = conv_std_logic_vector(5, output'length) ) report "Error : not 5 = 10" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for not";
		
		-- test left shift no ovf
		sel    <= x"8";
		input1 <= conv_std_logic_vector(5, input1'length);
		wait for 40 ns;
		assert( output = conv_std_logic_vector(10, output'length) ) report "Error : 5 << 1 = 10" severity warning;
		assert(overflow = '0') report "Error : Overflow = top bit for left shift";
		
		-- test left shift with ovf
		sel <= x"8";
		input1(input1'length - 1) <= '1';
		input1 ((input1'length - 2) downto 0) <= conv_std_logic_vector(0, output'length - 1) ;
		wait for 40 ns;
		assert( output = conv_std_logic_vector(0, output'length) ) report "Error : left shift = 0" severity warning;
		assert(overflow = '1') report "Error : Overflow = top bit for this left shift";
		
		-- test right shift
		sel    <= x"9";
		input1 <= conv_std_logic_vector(5, input1'length);
		wait for 40 ns;
		assert( output = conv_std_logic_vector(2, output'length) ) report "Error : 5 >> 1 = 2" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for right shift";

		-- test byte swap
		sel    <= x"A";
		input1 <= conv_std_logic_vector(7, input1'length);
		wait for 40 ns;
		assert( output = "01110000" ) report "Error : Byte Swap" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for byte swap";
		
		-- test bit reversal
		sel    <= x"B";
		input1 <= "01101011";
		wait for 40 ns;
		assert( output = "11010110" ) report "Error : Bit Reversal" severity warning;
		assert(overflow = '0') report "Error : Overflow = 0 for bit reversal";
		
		-- test zero functions (sel = 0xC-0xF)
		sel    <= x"C";
        input1 <= conv_std_logic_vector(250, input1'length);
        input2 <= conv_std_logic_vector(50, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(0, output'length)) report "Error : UNDEF C out" severity warning;
        assert(overflow = '0') report "Error : UNDEF C ovf" severity warning;

		sel    <= x"D";
        input1 <= conv_std_logic_vector(250, input1'length);
        input2 <= conv_std_logic_vector(50, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(0, output'length)) report "Error : UNDEF D out" severity warning;
        assert(overflow = '0') report "Error : UNDEF D ovf" severity warning;
		
		sel    <= x"E";
        input1 <= conv_std_logic_vector(6, input1'length);
        input2 <= "11110000";
        wait for 40 ns;
        assert(output = "00001001") report "Error : UNDEF E out" severity warning;
        assert(overflow = '0') report "Error : UNDEF E ovf" severity warning;
		
		sel    <= x"F";
        input1 <= conv_std_logic_vector(250, input1'length);
        input2 <= conv_std_logic_vector(50, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(0, output'length)) report "Error : UNDEF F out" severity warning;
        assert(overflow = '0') report "Error : UNDEF F ovf" severity warning;
		
        wait;

    end process;



end TB;