LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.spi_utils_pkg.ALL; -- Import custom SPI utility package

entity tb_spi is 
end entity tb_spi;

architecture sim of tb_spi is

    -- ================================================================
    -- Constants for simulation timing and configuration
    -- ================================================================
    constant BIT_NUMBER  : natural := 8;
    constant TIME_PERIOD : time    := 20 ns;

    -- ================================================================
    -- Test vectors for master transmission and slave response
    -- ================================================================
    constant TEST_DATA       : data_array_8bit(0 to 3) := (x"A5", x"3C", x"FF", x"00");
    constant SLAVE_RESPONSES : data_array_8bit(0 to 3) := (x"11", x"22", x"33", x"44");

    -- Stores data received by the slave from the master
    signal s_slave_rx_data      : data_array_8bit(0 to 3) := (x"00", x"00", x"00", x"00");
    signal s_slave_rx_data_byte : std_logic_vector(7 downto 0) := (others => '0');

    -- ================================================================
    -- Internal testbench signals
    -- ================================================================
    signal s_data_in    : std_logic_vector(BIT_NUMBER-1 downto 0) := (others => '0');
    signal s_data_out   : std_logic_vector(BIT_NUMBER-1 downto 0) := (others => '0');
    signal s_en         : std_logic := '0';
    signal s_oe         : std_logic := '0';
    signal s_cpol       : std_logic := '0';
    signal s_cpha       : std_logic := '0';
    signal s_brr        : std_logic_vector(7 downto 0) := x"00";
    signal s_clk        : std_logic := '0';
    signal s_valid      : std_logic := '0';
    signal s_busy       : std_logic := '0';
    signal s_rst_n      : std_logic := '0';
    signal s_miso       : std_logic := '0';
    signal s_mosi       : std_logic := '0';
    signal s_sclk       : std_logic := '0';
    signal s_cs_n       : std_logic := '1'; -- Active-low chip select

begin

    -- ================================================================
    -- Device Under Test (DUT): SPI core instance
    -- ================================================================
    dut: entity work.spi_core
        generic map(
            BIT_NUMBER => 8
        )
        port map(
            i_clk     => s_clk,
            i_en      => s_en,
            i_rst_n   => s_rst_n,
            i_oe      => s_oe,
            i_cs_n    => s_cs_n,
            i_cpol    => s_cpol,
            i_cpha    => s_cpha,
            i_brr     => s_brr,
            i_tx_data => s_data_out,
            o_rx_data => s_data_in,
            o_valid   => s_valid,
            o_busy    => s_busy,
            io_sclk   => s_sclk,
            io_miso   => s_miso,
            io_mosi   => s_mosi
        );

    -- ================================================================
    -- System clock generation
    -- ================================================================
    clk_gen: process
    begin
        s_clk <= '1';
        wait for TIME_PERIOD/2;
        s_clk <= '0';
        wait for TIME_PERIOD/2;
    end process clk_gen;

    -- ================================================================
    -- SPI slave emulation process
    -- Receives data from the DUT and sends predefined responses
    -- ================================================================
    slave_proc: process
    begin
        for i in SLAVE_RESPONSES'range loop

				wait until s_cs_n = '0';
            spi_slave_emu(
                i_sclk => s_sclk,
                i_mosi => s_mosi,
                o_miso => s_miso,
                o_data => s_slave_rx_data_byte,
                CPOL   => s_cpol,
                CPHA   => s_cpha,
                DATA   => SLAVE_RESPONSES(i)					 
            );

            -- Wait one delta cycle so that the signal output of the procedure
            -- is updated before storing it into the array
            wait for 0 ns;
		
            -- Store the byte received by the slave during this transaction
            s_slave_rx_data(i) <= s_slave_rx_data_byte;
			
				wait until s_cs_n = '1';
        end loop;

        wait; -- Stop the slave process after all transactions are completed
    end process slave_proc;

    -- ================================================================
    -- Stimulus process
    -- Configures the DUT and starts SPI transfers
    -- ================================================================
    stim_process: process
    begin
        -- Initial warm-up delay
        wait for 10 * TIME_PERIOD;

        -- Apply SPI configuration
        s_cpol  <= '1';
        s_cpha  <= '0';
        s_oe    <= '1';
        s_brr   <= x"18";
        s_rst_n <= '1'; -- Release reset

        -- Wait for configuration stabilization
        wait for 10 * TIME_PERIOD;

        -- Send all test bytes sequentially
        for i in TEST_DATA'range loop
            wait until rising_edge(s_clk);

            s_cs_n     <= '0';          -- Assert chip select
            s_data_out <= TEST_DATA(i); -- Load transmit data
            s_en       <= '1';          -- Start transaction
  
            -- Wait until the SPI core becomes busy and finishes the transfer
            wait until s_busy = '1';
            wait until s_busy = '0';

            s_en   <= '0';
            s_cs_n <= '1';              -- Deassert chip select

            -- Delay between consecutive frames
            wait for 100 * TIME_PERIOD;
        end loop;

        report "All test vectors sent successfully by master.";
        wait;
    end process stim_process;


		-- ================================================================
    -- Monitor process 
    -- Reports received slave-side bytes for debugging in Hexadecimal
    -- ================================================================
    mon_proc: process
    begin
        wait for 0 ns; 
        wait on  s_slave_rx_data; 

        for i in s_slave_rx_data'range loop 
            report "Slave received byte[" & integer'image(i) & "] = 0x" & to_hstring(s_slave_rx_data(i));
        end loop; 
    end process mon_proc;

end architecture sim;

