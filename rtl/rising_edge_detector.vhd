library ieee;
use ieee.std_logic_1164.all;

entity rising_edge_detector is
    port (
        i_clk          : in  std_logic;
        i_signal       : in  std_logic;
        o_rising_edge : out std_logic
    );
end entity rising_edge_detector;

architecture rtl of rising_edge_detector is

	signal s_prev : std_logic := '0';

begin

	-- sample current signal (flip-flop)
	sample_proc: process(i_clk)
	begin
		if rising_edge(i_clk) then
			s_prev <= i_signal;
		end if;
    end process sample_proc;
	-- edge detection combinitional stage
	o_rising_edge <= '1' when (s_prev='0' and i_signal='1') else '0';

end architecture rtl;
