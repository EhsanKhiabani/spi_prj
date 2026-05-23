-- ==============================================================================
-- PISO (Parallel-In Serial-Out) Shift Register
-- 
-- Usage:
-- 1. Set 'i_load' to '1' to capture parallel input data ('i_data') into the register.
-- 2. Set 'i_shift' and 'i_en' to '1' to begin shifting bits out on 'o_bit'.
-- 3. Data appears on 'o_bit' immediately upon loading or shifting, ensuring
--    compatibility with SPI and other synchronous serial protocols.
-- ==============================================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity piso is
    generic(
        -- Total number of bits to shift
        CWIDTH     : natural := 8;
        -- True: MSB first (Left Shift), False: LSB first (Right Shift)
        LEFT_SHIFT : boolean := false
    );
    port(
        -- Parallel input data
        i_data  : in std_logic_vector(CWIDTH-1 downto 0);
        -- Global clock
        i_clk   : in std_logic;
        -- Global enable signal
        i_en    : in std_logic;
        -- Loads parallel data on next clock edge
        i_load  : in std_logic;
        -- Shifts data on next clock edge
        i_shift : in std_logic;
        -- Active-high asynchronous reset
        i_rst   : in std_logic;
        -- Serial output bit
        o_bit   : out std_logic
    );
end entity piso;

architecture behavioral of piso is

    -- Internal storage register
    signal s_register : std_logic_vector(CWIDTH-1 downto 0) := (others => '1');

begin

    -- Register control logic
    main_body: process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            s_register <= (others => '1');
        elsif rising_edge(i_clk) then
            if i_load = '1' then 
                -- Load parallel data into the register
                s_register <= i_data;
            elsif i_shift = '1' and i_en = '1' then
                -- Perform shift operation based on direction
                if LEFT_SHIFT then
                    s_register <= s_register(CWIDTH-2 downto 0) & '1';
                else
                    s_register <= '1' & s_register(CWIDTH-1 downto 1);
                end if;
            end if;
        end if;
    end process main_body;

    -- Combinational output assignment for zero-latency serial transmission
    -- Shows immediate output when loading or shifting to meet timing requirements
    o_bit <= i_data(CWIDTH-1)    when (i_load = '1' and LEFT_SHIFT) else
             i_data(0)           when (i_load = '1' and not LEFT_SHIFT) else
             s_register(CWIDTH-1) when LEFT_SHIFT else
             s_register(0);

end architecture behavioral;

