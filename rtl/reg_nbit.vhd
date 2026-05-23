-- ==============================================================
-- Module Name : reg_nbit
-- Description :
--   Generic N-bit synchronous register with load enable.
--
--   The register captures the input data (i_data) on the rising
--   edge of the clock when i_load is asserted.
--
--   If i_load = '0', the register holds its previous value.
--
--   The width of the register is configurable through the
--   generic parameter BIT_NUMBER.
--
--   Ports:
--     i_clk   : System clock
--     i_load  : Load enable signal
--     i_data  : Input data bus
--     o_data  : Registered output data bus
--
-- ==============================================================


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity reg_nbit is
	generic(
		BIT_NUMBER : natural := 8
	);
	port(
		i_clk		:in	std_logic;
		i_load	:in	std_logic;
		i_data	:in	std_logic_vector(BIT_NUMBER-1 downto 0);
		o_data	:out	std_logic_vector(BIT_NUMBER-1 downto 0)
		
	);
end entity reg_nbit;

-- =========================
-- Architecture Definition
-- =========================
architecture rtl of reg_nbit is
	signal s_reg : std_logic_vector(BIT_NUMBER-1 downto 0) := (others=>'0');
begin

	main_proc: process(i_clk)
	begin

		if rising_edge(i_clk) then
			
			if i_load='1' then
				
				s_reg <= i_data;

			end if;

		end if;

	end process main_proc;
 
	o_data <= s_reg;

end architecture rtl;