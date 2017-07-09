-- Greg Stitt
-- University of Florida

-- The following entity is the top-level entity for lab 2. No changes are
-- required, but you need to map the I/O to the appropriate pins on the DE0
-- board. 

-- I/O Explanation (assumes the switches are on side of the
--                  DE0 board that is closest to you)
-- switch(9) is the leftmost switch
-- button(2) is the leftmost button
-- led3 is the leftmost 7-segment LED
-- ledx_dp is the decimal point on the 7-segment LED for LED x

-- Note: this code will cause a harmless synthesis warning because one of
-- the switches (switch 1) is left unused. The warning may be slightly
-- different in different versions of Quartus but should look something like:
-- "Warning: Design contains 1 input pin(s) that do not drive logic
--    Warning (15610): No output dependent on input pin switch[1]"

library ieee;
use ieee.std_logic_1164.all;

entity top_level is
    port (
        switch  : in  std_logic_vector(9 downto 0);
        button  : in  std_logic_vector(2 downto 0);
        led0    : out std_logic_vector(6 downto 0);
        led0_dp : out std_logic;
        led1    : out std_logic_vector(6 downto 0);
        led1_dp : out std_logic;
        led2    : out std_logic_vector(6 downto 0);
        led2_dp : out std_logic;
        led3    : out std_logic_vector(6 downto 0);
        led3_dp : out std_logic);
end top_level;

architecture STR of top_level is

    component decoder7seg
        port (
            input  : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0));
    end component;

    component alu_ns
        generic (
            WIDTH : positive := 16
            );
        port (
            input1   : in  std_logic_vector(WIDTH-1 downto 0);
            input2   : in  std_logic_vector(WIDTH-1 downto 0);
            sel      : in  std_logic_vector(3 downto 0);
            output   : out std_logic_vector(WIDTH-1 downto 0);
            overflow : out std_logic
            );
    end component;

    signal alu_out      : std_logic_vector(3 downto 0);
    signal alu_overflow : std_logic;
    signal alu_sel      : std_logic_vector(3 downto 0);

    constant C0 : std_logic_vector(3 downto 0) := "0000";
    
begin  -- STR

    -- map ALU output to rightmost 7-segment LED
    U_LED0 : decoder7seg port map (
        input  => alu_out,
        output => led0);

    -- all other LEDs should display 0
    U_LED1 : decoder7seg port map (
        input  => C0,
        output => led1);

    U_LED2 : decoder7seg port map (
        input  => C0,
        output => led2);

    U_LED3 : decoder7seg port map (
        input  => C0,
        output => led3);

    -- map the ALU select to the last switch and the three buttons
    alu_sel <= switch(0) & button;

    -- instantiate the ALU
    U_ALU : alu_ns
        generic map (
            WIDTH => 4)
        port map (
            input1   => switch(9 downto 6),  -- map input1 to the leftmost 4 switches
            input2   => switch(5 downto 2),  -- map input2 to the next 4 switches
            sel      => alu_sel,
            output   => alu_out,
            overflow => alu_overflow);

    -- map the alu overflow to the led0 decimal point, all others are off.
    led0_dp <= not alu_overflow;
    led1_dp <= '1';
    led2_dp <= '1';
    led3_dp <= '1';

end STR;