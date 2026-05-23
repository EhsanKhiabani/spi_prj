-- ============================================================================
-- Entity: spi_core
-- Description:
--   A configurable, full-duplex SPI master/slave controller.
--   - Features: CPOL/CPHA support, programmable baud rate, and tri-state I/O.
--   - Integration: Expects a system clock (i_clk) and generic-based bit width.
--   - Usage: Connect signals to standard SPI pins (io_sclk, io_miso, io_mosi).
--   - Note: Baud rate is derived from i_brr (BRR = [Fclk / (2 * Fsclk)] - 1).
--   - Synchronization: All internal logic is synchronous to i_clk.
-- ============================================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

use work.spi_utils_pkg.all;
-- =========================
-- Entity Declaration
-- =========================
entity spi_core is
	generic (
		BIT_NUMBER : natural := 8
	);
	port(
		i_clk		: in std_logic;
		i_en		: in std_logic;
		i_rst_n	: in std_logic;
		
		i_oe		: in std_logic;
		i_cs_n	: in std_logic;
		i_cpol	: in std_logic;
		i_cpha	: in std_logic;
		i_brr		: in std_logic_vector(7 downto 0);

		i_tx_data: in	std_logic_vector(BIT_NUMBER-1 downto 0);
		o_rx_data: out std_logic_vector(BIT_NUMBER-1 downto 0);
		o_valid	: out std_logic;
		o_busy	: out std_logic;

		io_sclk	: inout std_logic;
		io_miso	: inout std_logic;
		io_mosi	: inout std_logic
	);
end entity spi_core;

-- =========================
-- Architecture Definition
-- =========================
architecture structural of spi_core is

	-- Internal signal definition
	signal s_baud_tick_en	: std_logic := '0';
	signal s_baud_tick		: std_logic := '0';
	signal s_int_sclk			: std_logic := '0';
	signal s_rst_n				: std_logic := '0';

	signal s_mr_strobe		: std_logic := '0';
	signal s_mw_strobe		: std_logic := '0';
	signal s_sr_strobe		: std_logic := '0';
	signal s_sw_strobe		: std_logic := '0';
	signal s_r_strobe			: std_logic := '0';
	signal s_w_strobe			: std_logic := '0';
	signal s_slave_en			: std_logic := '0';
	signal s_rst_tx_cntr		: std_logic := '0';
	signal s_rst_rx_cntr		: std_logic := '0';
	signal s_serial_input	: std_logic := '0';
	signal s_tx_data_load	: std_logic := '0';
	signal s_serial_output	: std_logic := '0';
	signal s_ien_tx			: std_logic := '0'; 
	signal s_ien_rx			: std_logic := '0'; 
	signal s_rx_bit_cnt		: 
				std_logic_vector(integer(ceil(log2(real(BIT_NUMBER)))) downto 0) := (others=>'0');
	signal s_tx_bit_cnt		: 
				std_logic_vector(integer(ceil(log2(real(BIT_NUMBER)))) downto 0) := (others=>'0');

begin
 
	master_baud_gen: entity work.spi_brg
		generic map (BIT_NUMBER=>8)
		port map (
			i_clk		=> i_clk,
			i_rst_n	=> i_rst_n,
			i_en		=> s_baud_tick_en,
			i_cpol	=> i_cpol,
			i_brr		=> i_brr,
			o_baud_tick=> s_baud_tick,
			o_sclk	=>	s_int_sclk
		);

	master_strobe_gen: entity work.master_strobe_gen
		port map (
			i_clk		=> i_clk,
			i_rst_n	=> i_rst_n,
			i_en		=> i_en,

			i_cpol	=> i_cpol,
			i_cpha	=>	i_cpha,
			i_sclk	=>	s_int_sclk,
			i_baud_tick	=> s_baud_tick,

			o_r_strobe	=> s_mr_strobe,
			o_w_strobe	=> s_mw_strobe
		);

	slave_strobe_gen: entity work.slave_strobe_gen
		port map(
			i_clk		=> i_clk,
			i_en		=>	i_en,
		
			i_cpol	=>	i_cpol,
			i_cpha	=>	i_cpha,
			i_sclk	=>	io_sclk,

			o_r_strobe	=> s_sr_strobe,
			o_w_strobe	=>	s_sw_strobe
		);
	tx_bit_counter: entity work.universal_counter
    	generic map (
        	BIT_NUMBER	=> integer(ceil(log2(real(BIT_NUMBER))))+1
    	)
    port map(
        i_clk		=> i_clk,
        i_rst_n	=>	s_rst_tx_cntr,
        i_en		=>	s_w_strobe,
        i_preload	=> (others=>'0'),
        i_load		=> '0',

        o_tc		=> open,
        o_cnt		=>	s_tx_bit_cnt
    );
	rx_bit_counter: entity work.universal_counter
		generic map(
        	BIT_NUMBER	=> integer(ceil(log2(real(BIT_NUMBER))))+1
    	)
		port map(
        i_clk		=> i_clk,
        i_rst_n	=>	s_rst_rx_cntr,
        i_en		=>	s_r_strobe,
        i_preload	=> (others=>'0'),
        i_load		=> '0',

        o_tc		=> open,
        o_cnt		=>	s_rx_bit_cnt
		);
	slave_mode_detector: entity work.slave_mode_detector
		port map (
			i_cs_n	=> i_cs_n,
			i_oe		=> i_oe,
			o_slave_en	=> s_slave_en
		);
	spi_fsm: entity work.spi_fsm
		generic map (
			BIT_NUMBER => BIT_NUMBER
		)
		port map (
			i_clk				=> i_clk,
			i_en				=> i_en,
			i_rst_n			=> i_rst_n,
			i_slave_mode	=> s_slave_en,
			i_oe				=> i_oe,
			i_tx_bit_cnt	=>	s_tx_bit_cnt,
			i_rx_bit_cnt	=> s_rx_bit_cnt,

			o_tx_reg_load	=> s_tx_data_load,
			o_en_baud_gen	=> s_baud_tick_en,
		
			o_rx_rst_cntr	=> s_rst_rx_cntr,
			o_tx_rst_cntr	=> s_rst_tx_cntr,
			o_busy			=> o_busy,
			o_valid			=> o_valid
		);

	s_ien_rx <= s_rst_rx_cntr;
	s_ien_tx <= s_rst_tx_cntr;

	sipo_reg: entity work.sipo
		generic map(
			CWIDTH => BIT_NUMBER,
			LEFT_SHIFT => true
		)
		port map (
			i_bit		=> s_serial_input,
			i_clk		=> i_clk,
			i_shift	=> s_r_strobe,
			i_en		=> s_ien_rx,
			i_rst		=> '0',
			o_data	=> o_rx_data
		);
	piso_reg: entity work.piso
		generic map(
			CWIDTH => BIT_NUMBER,
			LEFT_SHIFT => true
		)
		port map (
			i_data	=> i_tx_data,
			i_clk		=> i_clk,
			i_load	=> s_tx_data_load,
			i_shift	=> s_w_strobe,
			i_en		=> s_ien_tx,
			i_rst		=> '0',
			o_bit 	=> s_serial_output
		);
	tri_state_sclk: entity work.tri_state
		port map(
			inp	=> s_int_sclk,
			i_en	=>	i_oe,
			oup	=>	io_sclk
		);

	tri_state_miso: entity work.tri_state
		port map(
			inp	=>	s_serial_output,
			i_en	=> s_slave_en,
			oup	=> io_miso
		);
	tri_state_mosi: entity work.tri_state
		port map(
			inp	=> s_serial_output,
			i_en	=> i_oe,
			oup	=> io_mosi
		);
	mux_input: entity work.mux2x1
		port map(
			in0	=> io_miso,
			in1	=>	io_mosi,
			i_sel	=> s_slave_en,
			oup	=>	s_serial_input
		);
	mux_r_strobe: entity work.mux2x1
		port map(
			in0	=>	s_mr_strobe,
			in1	=>	s_sr_strobe,
			i_sel	=>	s_slave_en,
			oup	=>	s_r_strobe
		);
	mux_w_strobe: entity work.mux2x1
		port map(
			in0	=> s_mw_strobe,
			in1	=>	s_sw_strobe,
			i_sel	=>	s_slave_en,
			oup	=>	s_w_strobe
		);		
end architecture structural;