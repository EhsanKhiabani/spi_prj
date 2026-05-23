LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity slave_mode_detector is
	port(
		i_cs_n	: in std_logic;
		i_oe		: in std_logic;

		o_slave_en : out std_logic
	);
end entity slave_mode_detector;

-- =========================
-- Architecture Definition
-- =========================
architecture rtl of  slave_mode_detector is
 
begin

	o_slave_en <= '1' when (i_oe='0' and i_cs_n='0') else '0';

end architecture rtl;