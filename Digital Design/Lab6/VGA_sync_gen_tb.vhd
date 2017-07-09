-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 6: VGA_sync_gen_tb

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync_gen_tb is
end vga_sync_gen_tb;

architecture VGA_SYNC_GEN_TB_ARCH of vga_sync_gen_tb is


	signal clk, rst, done : std_logic := '0';
	signal horiz_sync, vert_sync, video_on : std_logic;
	signal hcount, vcount : unsigned(9 downto 0);
begin
	U_VGA: entity work.vga_sync_gen
		   port map(
		   		clk => clk,
		   		rst => rst,
		   		horiz_sync => horiz_sync,
		   		vert_sync => vert_sync,
		   		video_on => video_on,
		   		hcount => hcount,
		   		vcount => vcount
		   	);

	clk <= not clk and (not done) after 20 ns;

    process
    begin

        rst <= '1';

        for i in 0 to 5 loop
            wait until rising_edge(clk);
        end loop;

		rst <= '0';

        -- wait for 1600 cycles
        for i in 0 to (3*802*524) loop
            wait until rising_edge(clk);
        end loop;  -- i

        wait for 5 ns;

        done <= '1';

        wait;

    end process;





end VGA_SYNC_GEN_TB_ARCH;
