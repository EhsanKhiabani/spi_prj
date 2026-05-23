LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- ========================================================================
-- Module Name : slave_strobe_gen
-- Description :
--   Robust, glitch-free strobe generator for SPI Slave mode.
--   Uses XOR/XNOR logic to accurately resolve read/write edges across 
--   all 4 standard SPI modes.
-- ========================================================================
entity slave_strobe_gen is
	port(
		i_clk		: in std_logic;
		i_en		: in std_logic;
		
		i_cpol		: in std_logic;
		i_cpha		: in std_logic;
		i_sclk		: in std_logic;

		o_r_strobe	: out std_logic;
		o_w_strobe	: out std_logic
	);
end entity slave_strobe_gen;

-- =========================
-- Architecture Definition
-- =========================
architecture behavioral of slave_strobe_gen is

	signal s_sclk_sync   : std_logic := '0';
	signal s_fall_edge   : std_logic := '0';
	signal s_rise_edge   : std_logic := '0';
	signal s_select_mode : std_logic := '0';


begin
	
	-- Clock Domain Crossing (CDC) synchronization stage to prevent metastability
	sync: entity work.synchronizer
		port map(
			i_clk          => i_clk,
			i_async_signal => i_sclk,
			o_sync_signal  => s_sclk_sync
		);

	-- Combinational falling edge detector
	fall_edge_dec: entity work.falling_edge_detector
		port map(
			i_clk          => i_clk,
			i_signal       => s_sclk_sync,
			o_falling_edge => s_fall_edge
		);
	
	-- Combinational rising edge detector
	rise_edge_dec: entity work.rising_edge_detector
		port map(
			i_clk          => i_clk,
			i_signal       => s_sclk_sync,
			o_rising_edge  => s_rise_edge
		);
	
	-- Mode decoding logic using XOR/XNOR gates to map physical edges to logical actions
	s_select_mode <= i_cpha xor i_cpol;
	

	-- Output multiplexer gated with the master enable signal (i_en)
	o_r_strobe <= '0' when (i_en='0') else
					 s_fall_edge when s_select_mode = '1' else s_rise_edge;
	o_w_strobe <= '0' when (i_en='0') else
					 s_rise_edge when s_select_mode = '1' else s_fall_edge;

end architecture behavioral;