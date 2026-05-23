-- ========================================================================
-- Module Name : spi_brg (SPI Baud Rate Generator)
-- Description :
--   Synchronous Baud Rate Generator for SPI Master implementation.
--   
--   This module divides the high-speed system clock (i_clk) to generate 
--   the SPI serial clock (o_sclk) and single-cycle timing ticks (o_baud_tick).
--
--   Baud Rate Formula:
--     F_sclk = F_clk / (2 * BRR)   -->   BRR = F_clk / (2 * F_sclk)
--
-- Generics:
--   BIT_NUMBER : Width of the baud rate register and counter (Default: 8).
--
-- Ports:
--   i_clk       : System high-speed clock (Rising-edge triggered).
--   i_rst_n     : Active-low synchronous reset (Initializes counter to BRR).
--   i_en        : Block enable from SPI FSM (Enables counting and clock toggle).
--   i_cpol      : Clock Polarity (0 = Idle Low, 1 = Idle High).
--   i_brr       : Configuration vector for the division factor.
--   o_baud_tick : Single-cycle pulse asserted at every SPI clock edge transition.
--   o_sclk      : Stabilized SPI Serial Clock output.
-- ========================================================================


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity spi_brg is
	generic (
		BIT_NUMBER	: natural := 8
	);
	port(
		i_clk		:in	std_logic;
		i_rst_n	:in	std_logic;
		i_en		:in	std_logic;
		i_cpol	:in	std_logic;
		i_brr		:in	std_logic_vector(7 downto 0);

		o_baud_tick	:out	std_logic;
		o_sclk	:out	std_logic
	);
end entity spi_brg;

-- =========================
-- Architecture Definition
-- =========================
architecture structural of spi_brg is
	signal s_tc	: std_logic;
	signal s_brr: std_logic_vector( BIT_NUMBER-1 downto 0);

begin

	brg_counter: entity work.universal_counter
		generic map (
			BIT_NUMBER => BIT_NUMBER,
			COUNTER_DOWN => true
		)
		port map (
			i_clk		=>	i_clk,
			i_rst_n	=>	i_rst_n,
			i_en		=>	i_en,
			i_preload=> i_brr,
			i_load	=>	s_tc,
			o_tc		=> s_tc,
			o_cnt		=>	open
		);
	


	brg_trigger_toggle: entity work.trigger_toggle
		port map (
			i_clk		=>	i_clk,
			i_en		=>	i_en,
			i_idle_level	=> i_cpol,
			i_trigger=> s_tc,
			o_toggle	=> o_sclk
		);

	brg_brr : entity work.reg_nbit
		generic map (
			BIT_NUMBER => BIT_NUMBER
		)
		port map (
			i_clk => i_clk,
			i_load=> '1',
			i_data=> i_brr,
			o_data=> s_brr
		);

	o_baud_tick <= s_tc;
	
end architecture structural;