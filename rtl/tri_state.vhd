LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity tri_state is
port(
	inp	: in	std_logic;
	i_en	: in	std_logic;
	oup	: out	std_logic);
end entity tri_state;

-- =========================
-- Architecture Definition
-- =========================
architecture rtl of tri_state is
 
begin
	
	oup <= inp when i_en='1' else 'Z';

end architecture rtl;