-- Adrian Alvarez
-- University of Florida
-- EEL4712 Digital Design
-- Lab 6: VGA Row Decoder TB

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.VGA_LIB.all;

entity vga_rowdec_tb is
end vga_rowdec_tb;

architecture TB of vga_rowdec_tb is

  -- MODIFY TO MATCH YOUR TOP LEVEL
	signal clk              : std_logic := '0';
	signal rst              : std_logic := '0';
	signal video_on         : std_logic;
	signal buttons_n        : std_logic_vector(2 downto 0) := "000";
	--signal red, green, blue : std_logic_vector(3 downto 0);
	signal h_sync, v_sync   : std_logic;
	signal hcount, vcount   :unsigned(9 downto 0);
	signal addrH : std_logic_vector(5 downto 0);
	signal done : std_logic := '0';

begin

		U_SYNC: entity work.vga_sync_gen
		   port map(
		   		clk => clk,
		   		rst => rst,
		   		horiz_sync => h_sync,
		   		vert_sync => v_sync,
		   		video_on => video_on,
		   		hcount => hcount,
		   		vcount => vcount
		   	);

	   U_ROW: entity work.vga_rowdec
	   	port map(
	   			buttons => buttons_n,
	   			vcount => vcount,
	   			addrH => addrH,
	   			video_on => video_on
	   			);

   	clk <= not clk and (not done) after 20 ns;

	process
	begin
   	for j in 0 to 5 loop

	   	for i in 0 to (802*524) loop
	            wait until rising_edge(clk);
	        end loop;  -- i

	        buttons_n <= std_logic_vector((unsigned(buttons_n) + 1));

     end loop;

        wait for 5 ns;

        done <= '1';

   end process;

end TB;