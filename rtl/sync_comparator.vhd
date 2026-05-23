-- ==============================================================
-- Module Name : sync_comparator
-- Description :
--   Synchronous unsigned comparator with registered outputs.
--
--   This module compares two input vectors (in_a and in_b)
--   on the rising edge of the clock. The comparison is performed
--   as unsigned arithmetic values.
--
--   When enabled (i_en = '1'):
--     - o_lt is asserted when in_a < in_b
--     - o_eq is asserted when in_a = in_b
--     - o_gt is asserted when in_a > in_b
--
--   Only one output is high at a time (one-hot behavior).
--
--   When disabled (i_en = '0') Hold last output.
--   (i_rst_n = '0'), all outputs are cleared.
--
-- Generics :
--   BIT_WIDTH : Defines the width of the input vectors.
--
-- Ports :
--   i_clk   : System clock
--   i_rst_n : Active-low synchronous reset
--   i_en    : Enable signal for comparison
--   in_a    : First input operand
--   in_b    : Second input operand
--   o_lt    : High when in_a < in_b
--   o_eq    : High when in_a = in_b
--   o_gt    : High when in_a > in_b
--
-- ==============================================================


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity sync_comparator is
	generic (
		BIT_WIDTH	: natural := 8
	);
	port(
		i_clk		:in	std_logic;
		i_rst_n	:in	std_logic;
		i_en		:in	std_logic;

		in_a		:in	std_logic_vector(BIT_WIDTH-1 downto 0);
		in_b		:in	std_logic_vector(BIT_WIDTH-1 downto 0);

		o_lt		:out	std_logic;
		o_gt		:out  std_logic;
		o_eq		:out	std_logic
	);
end entity sync_comparator;

-- =========================
-- Architecture Definition
-- =========================
architecture behavioral of sync_comparator is

begin
	
	main_proc: process(i_clk)
	begin

		if rising_edge(i_clk) then

			if i_rst_n='0' then

				o_gt <= '0';
				o_lt <= '0';
				o_eq <= '0';	

			elsif i_en='1' then

				if unsigned(in_a)<unsigned(in_b) then
					o_gt <= '0';
					o_lt <= '1';
					o_eq <= '0';
				elsif unsigned(in_a)=unsigned(in_b) then
					o_gt <= '0';
					o_lt <= '0';
					o_eq <= '1';
				else
					o_gt <= '1';
					o_lt <= '0';
					o_eq <= '0';					
				end if;

			end if;

		end if;

	end process main_proc; 


end architecture behavioral;