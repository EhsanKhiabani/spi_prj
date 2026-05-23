-- ==============================================================
-- Module Name : trigger_toggle
-- Description :
--   Synchronous edge-triggered toggle generator.
--
--   This module toggles its output on the rising edge of the clock
--   whenever both i_en is asserted and a RISING EDGE is detected
--   on i_trigger.
--
--   The design is EDGE-SENSITIVE:
--     - A multi-cycle trigger pulse causes only a SINGLE toggle
--       at the moment of the transition from '0' to '1'.
--     - This prevents unwanted oscillations or clock bursts.
--
--   Behavior:
--     - If i_en = '1' and i_trigger rises from 0 to 1 -> output toggles.
--     - If i_en = '1' and i_trigger stays constant   -> output holds value.
--     - If i_en = '0'                                -> output is forced
--                                                       to i_idle_level.
--
--   Ports:
--     i_clk        : System clock (rising-edge triggered)
--     i_en         : Enable control
--     i_idle_level : Output level when disabled (Supports CPOL)
--     i_trigger    : Edge-sensitive trigger input
--     o_toggle     : Toggle output (SCLK)
-- ==============================================================


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity trigger_toggle is
	port(
		i_clk			:in	std_logic;
		i_en			:in	std_logic;
		i_idle_level:in	std_logic;
		i_trigger	:in	std_logic;

		o_toggle		:out	std_logic
	);
end entity  trigger_toggle;

-- =========================
-- Architecture Definition
-- =========================
architecture behavioral of trigger_toggle is
	signal s_toggle : std_logic:='0';
	signal s_trigger: std_logic:='0';
begin

	main_proc: process(i_clk)
	begin

		if rising_edge(i_clk) then
			
			if i_en='1' then
				
				s_trigger <= i_trigger;

				if s_trigger='0' and i_trigger='1' then

					s_toggle <= not s_toggle;

				end if;

			else
				 s_trigger <= '0';
				 s_toggle<=i_idle_level;

			end if;			

		end if;
		
	end process main_proc;

	
	o_toggle <= s_toggle;

end architecture behavioral;
