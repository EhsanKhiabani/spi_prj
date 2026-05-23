library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
    port (
        i_clk          : in  std_logic;
        i_async_signal : in  std_logic;
        o_sync_signal  : out std_logic
    );
end entity synchronizer;

architecture rtl of synchronizer is

    signal s_ff1 : std_logic;
    signal s_ff2 : std_logic;

begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then

            s_ff1 <= i_async_signal;
            s_ff2 <= s_ff1;

        end if;
    end process;

    o_sync_signal <= s_ff2;

end architecture rtl;