LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


entity tb_spi_brg is 
end entity tb_spi_brg;

architecture sim of tb_spi_brg is

	signal s_clk: std_logic := '0';
	signal s_en : std_logic := '0';
	signal s_rst_n : std_logic := '0';
	signal s_cpol	: std_logic := '0';
	signal s_brr	: std_logic_vector(7 downto 0) := x"18";
	signal s_baud_tick : std_logic;
	signal s_sclk	: std_logic;
	constant TIME_PERIOD: time := 20 ns;

begin

-- ====================================
-- =====  DUT Instantation        =====
-- ====================================
	dut: entity work.spi_brg
			generic map ( BIT_NUMBER => 8 )
			port map (
				i_clk		=> s_clk,
				i_rst_n	=> s_rst_n,
				i_en		=> s_en,
				i_cpol	=> s_cpol,
				i_brr		=> s_brr,
				o_baud_tick	=> s_baud_tick,
				o_sclk		=> s_sclk
			);
-- ====================================
-- ===== Clock Generation Process =====
-- ====================================

	clk_gen: process
	begin
		s_clk <= '1';
		wait for TIME_PERIOD/2;
		s_clk <= '0';
		wait for TIME_PERIOD/2;	end process clk_gen;

-- ====================================
-- ====== Stimulus Process  ===========
-- ====================================
	stim_process: process
	begin
		-- wait for warm-up		wait for 10*TIME_PERIOD;
		-- wait for synchronization with clock rising edge
		wait until rising_edge(s_clk);
		s_rst_n <= '1';
		wait until rising_edge(s_clk);
		s_en	<= '1';

		wait;
	end process stim_process;

 

-- ====================================
-- ======  Monitor Process ============
-- ====================================
	mon_proc: process
	
		variable v_cursor_1 : time := 0 ns;
		variable v_cursor_2 : time := 0 ns;
		variable v_dt		  : time := 0 ns;

		variable v_freq	  : real := 0.0 ;
	begin

		wait until rising_edge(s_sclk); -- wait until sclk rising edge
		v_cursor_1 := now;				  -- log first time stamp

		wait until rising_edge(s_sclk);
		v_cursor_2 := now;				  -- log second time stamp
		
		v_dt := v_cursor_2 - v_cursor_1;

		v_freq := 1.0E9 / real(v_dt/1 ns);  

		report "SCLK Frequency =" & real'image(v_freq) & " Hz" severity note;

	end process mon_proc;

end architecture sim;
