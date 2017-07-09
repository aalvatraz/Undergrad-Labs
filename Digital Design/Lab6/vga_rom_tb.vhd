-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 6: VGA ROM TB

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.VGA_LIB.all;

entity vga_rom_tb is
end vga_rom_tb;

architecture TB of vga_rom_tb is

  signal address : std_logic_vector(11 downto 0) := (others => '0');
  signal  q : std_logic_vector(11 downto 0);
  signal clk, done : std_logic := '0';

begin  -- TB

  -- MODIFY TO MATCH YOUR TOP LEVEL
  UUT : entity work.vga_rom 
      PORT MAP
        (
          address => address,
          clock   => clk,
          q   => q
        );


  clk <= not clk and (not done) after 10 ns;

  process
  begin

      for i in 0 to (4096) loop
   		 address <= std_logic_vector(unsigned(address) + to_unsigned(1, 1));
          wait until rising_edge(clk);
      end loop; 

        wait for 5 ns;

        done <= '1';
 
  end process;

end TB;