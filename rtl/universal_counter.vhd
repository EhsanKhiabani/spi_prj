-- ============================================================
--  Module      : universal_counter
--  Description : Parameterized synchronous counter with
--                configurable width and count direction.
--
--  Generics:
--  BIT_NUMBER
--      Defines the width of the counter in bits.
--
--  COUNTER_DOWN
--      Selects counting direction.
--      false -> Up counter
--      true  -> Down counter
--
--  Inputs:
--  i_clk
--      System clock. Counter updates on the rising edge.
--
--  i_rst_n
--      Active-low synchronous reset. Preloads the counter to i_preload
--      to guarantee correct initial state and prevent cold-start delay.
--
--  i_en
--      Enable signal. When '1', the counter increments or
--      decrements on each clock cycle depending on the mode.
--
--  i_load
--      Load control. When '1', the value on i_preload is loaded
--      into the counter on the next clock edge.
--
--  i_preload
--      Preload value used during reset and when i_load is asserted.
--
--  Outputs:
--  o_cnt
--      Current counter value.
--
--  o_tc
--      Terminal count indicator. Asserted 1 cycle early to compensate
--      for synchronous comparator/pipeline delays:
--          - High when s_cnt = HIGH_LIMIT (Max - 1) in up-count mode
--          - High when s_cnt = LOW_LIMIT  (1) in down-count mode
-- ============================================================


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity universal_counter is
    generic (
        BIT_NUMBER	: natural := 8;
        COUNTER_DOWN : boolean := false
    );
    port (
        i_clk     : in  std_logic;
        i_rst_n   : in  std_logic;
        i_en      : in  std_logic;
        i_preload : in  std_logic_vector(BIT_NUMBER-1 downto 0);
        i_load    : in  std_logic;

        o_tc      : out std_logic;
        o_cnt     : out std_logic_vector(BIT_NUMBER-1 downto 0)
    );
end entity universal_counter;

architecture behavioral of universal_counter is

    signal s_cnt    : unsigned(BIT_NUMBER-1 downto 0) := (others=>'0');
    signal s_tc_buf : std_logic := '0';

    constant LOW_LIMIT  : unsigned(BIT_NUMBER-1 downto 0) := to_unsigned(1,BIT_NUMBER);
    constant HIGH_LIMIT : unsigned(BIT_NUMBER-1 downto 0) := to_unsigned(integer(BIT_NUMBER)**2-2,BIT_NUMBER);

begin

    cnt_proc : process (i_clk)
    begin
        if rising_edge(i_clk) then

            if i_rst_n = '0' then
                s_cnt    <= unsigned(i_preload);
                s_tc_buf <= '0';

            elsif i_load = '1' then
                s_cnt    <= unsigned(i_preload);
                s_tc_buf <= '0';

            elsif i_en = '1' then

                if not COUNTER_DOWN then      -- up counter
                    s_cnt    <= s_cnt + 1;
                    if s_cnt = HIGH_LIMIT then
                        s_tc_buf <= '1';
                    else
                        s_tc_buf <= '0';
                    end if;
                else                          -- down counter
                    s_cnt    <= s_cnt - 1;
                    if s_cnt = LOW_LIMIT then
                        s_tc_buf <= '1';
                    else
                        s_tc_buf <= '0';
                    end if;
                end if;

            else
                -- i_en = '0'
                s_tc_buf <= '0';
            end if;

        end if;
    end process cnt_proc;

    o_cnt <= std_logic_vector(s_cnt);
    o_tc  <= s_tc_buf;

end architecture behavioral;
