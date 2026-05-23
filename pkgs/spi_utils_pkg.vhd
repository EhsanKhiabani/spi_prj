-- =============================================================================
-- Package: spi_utils_pkg
-- Description: 
--   Provides utility types and simulation procedures for SPI master and slave
--   emulation. This package is intended for testbench environments to verify
--   SPI core implementations.
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package spi_utils_pkg is

    -- Array types for handling sequences of SPI data frames
    type data_array_8bit  is array(integer range <>) of std_logic_vector(7 downto 0);
    type data_array_16bit is array(integer range <>) of std_logic_vector(15 downto 0);

    -- Procedure: spi_slave_emu
    -- Description: Emulates an SPI slave device.
    --   - Captures data from MOSI and drives MISO based on the provided CPOL/CPHA.
    --   - Performs MSB-first data transfer.
    --   - 'DATA' represents the payload to be shifted out on MISO.
    procedure spi_slave_emu(
        signal i_sclk : in std_logic;
        signal i_mosi : in std_logic;
        signal o_miso : out std_logic;
        signal o_data : out std_logic_vector(7 downto 0);
        constant CPOL : std_logic;
        constant CPHA : std_logic;
        constant DATA : std_logic_vector(7 downto 0)
    );

    -- Procedure: spi_master_emu
    -- Description: Emulates an SPI master device.
    --   - Generates SCLK based on CPOL and the specified CLOCK_PERIOD.
    --   - Drives MOSI and samples MISO based on CPHA configuration.
    --   - Default CLOCK_PERIOD is 1 microsecond.
    procedure spi_master_emu(
        signal o_sclk : out std_logic;
        signal o_mosi : out std_logic;
        signal i_miso : in std_logic;
        constant CLOCK_PERIOD: time := 1 us;
        constant CPOL : std_logic;
        constant CPHA : std_logic;
        constant DATA : in std_logic_vector(7 downto 0);
        signal o_data : out std_logic_vector(7 downto 0)
    );

end package spi_utils_pkg;

package body spi_utils_pkg is

    -- =========================================================================
    -- SPI Slave Emulation Procedure
    -- 
    -- Usage Notes:
    -- 1. This procedure emulates an SPI slave device.
    -- 2. It samples MOSI data based on the SPI mode (CPOL/CPHA).
    -- 3. MISO is driven using a combinational-style approach to ensure that
    --    the next data bit is ready *before* the Master's sampling edge.
    -- 4. Automatically sets MISO to 'Z' after transmission to avoid bus contention.
    -- =========================================================================
    procedure spi_slave_emu(
        signal i_sclk : in std_logic;
        signal i_mosi : in std_logic;
        signal o_miso : out std_logic;
        signal o_data : out std_logic_vector(7 downto 0);
        constant CPOL : std_logic;
        constant CPHA : std_logic;
        constant DATA : std_logic_vector(7 downto 0)
    ) is 
        variable v_data : std_logic_vector(7 downto 0) := (others => '0');
    begin
        for i in 7 downto 0 loop
            -- -----------------------------------------------------------------
            -- Mode 0 & 3: Sample on Rising Edge, Change on Falling Edge
            -- -----------------------------------------------------------------
            if (CPOL = '0' and CPHA = '0') or (CPOL = '1' and CPHA = '1') then
                -- Drive MISO with current bit before sampling edge
                o_miso <= DATA(i);
                
                -- Wait for sampling edge
                wait until rising_edge(i_sclk);
                v_data(i) := i_mosi; -- Capture MOSI
                
                -- Wait for edge where data changes
                wait until falling_edge(i_sclk);

            -- -----------------------------------------------------------------
            -- Mode 1 & 2: Sample on Falling Edge, Change on Rising Edge
            -- -----------------------------------------------------------------
            elsif (CPOL = '0' and CPHA = '1') or (CPOL = '1' and CPHA = '0') then
                -- Drive MISO with current bit before sampling edge
                o_miso <= DATA(i);
                
                -- Wait for sampling edge
                wait until falling_edge(i_sclk);
                v_data(i) := i_mosi; -- Capture MOSI
                
                -- Wait for edge where data changes
                wait until rising_edge(i_sclk);
            end if;
        end loop;

        -- Return MISO to high-impedance immediately after the last bit
        o_miso <= 'Z'; 
        
        -- Output the received data to the testbench environment
        o_data <= v_data;
    end procedure;


    procedure spi_master_emu(
        signal o_sclk : out std_logic;
        signal o_mosi : out std_logic;
        signal i_miso : in std_logic;
        constant CLOCK_PERIOD: time := 1 us;
        constant CPOL : std_logic;
        constant CPHA : std_logic;
        constant DATA : in std_logic_vector(7 downto 0);
        signal o_data : out std_logic_vector(7 downto 0)
    ) is
        variable v_miso_data : std_logic_vector(7 downto 0) := (others => '0');
    begin
        -- Set SCLK to idle state defined by CPOL
        o_sclk <= CPOL;
        wait for CLOCK_PERIOD/2;

        for i in 7 downto 0 loop
            -- Setup data on MOSI before clock edge if CPHA is 0
            if CPHA = '0' then
                o_mosi <= DATA(i);
            end if;

            -- Toggle SCLK to active edge
            o_sclk <= not CPOL;
            wait for CLOCK_PERIOD/2;
            
            -- Capture MISO data on active edge
            v_miso_data(i) := i_miso;
            
            -- Toggle SCLK back to idle
            o_sclk <= CPOL;
            wait for CLOCK_PERIOD/2;
        end loop;

        o_data <= v_miso_data;
    end procedure;

end package body spi_utils_pkg;

