-- ============================================================
--  Description
--  Module : Multiplexer 2 to 1
-- ============================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity mux2x1 is
 port(
	in0	: in	std_logic;
	in1	: in	std_logic;
	i_sel	: in	std_logic;
	oup	: out std_logic
 );
end entity mux2x1;

-- =========================
-- Architecture Definition
-- =========================
architecture rtl of mux2x1 is
 
begin

	oup <= in0 when i_sel='0' else in1;

end architecture rtl;