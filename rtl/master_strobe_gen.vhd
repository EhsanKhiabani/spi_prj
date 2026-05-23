LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- ========================================================================
-- Module Name : master_strobe_gen
-- Description :
--   Generates single-cycle read (o_r_strobe) and write (o_w_strobe) pulses
--   for SPI Master mode, independent of CPOL.
-- ========================================================================
entity master_strobe_gen is
	port(
		i_clk		: in std_logic;
		i_rst_n	    : in std_logic;
		i_en		: in std_logic;

		i_cpol		: in std_logic;
		i_cpha		: in std_logic;
		i_sclk		: in std_logic;
		i_baud_tick	: in std_logic;

		o_r_strobe	: out std_logic;
		o_w_strobe	: out std_logic
	);
end entity master_strobe_gen;

-- =========================
-- Architecture Definition
-- =========================
architecture behavioral of master_strobe_gen is
begin
	
	strobe_gen_proc: process(i_clk)
	begin
		if rising_edge(i_clk) then
			
			if i_rst_n='0' or i_en='0' then
				o_r_strobe <= '0';
				o_w_strobe <= '0';
			else
				-- default value of strobe signals
				o_r_strobe <= '0';
				o_w_strobe <= '0';
				
				-- synchronization with baud tick 
				if i_baud_tick='1' then

					if i_cpha='1' then
						-- shift data happens on first edge
						-- and capturing happens on second edge
						if i_sclk='0' then
							-- rising edge
							if i_cpol='0' then     -- first edge
								o_r_strobe <= '0';
								o_w_strobe <= '1';
							else						  -- second edge
								o_r_strobe <= '1';
								o_w_strobe <= '0';
							end if;
						else
							-- falling edge
							if i_cpol='0' then     -- second edge
								o_r_strobe <= '1';
								o_w_strobe <= '0';
							else						  -- first edge
								o_r_strobe <= '0';
								o_w_strobe <= '1';
							end if;

						end if;
					
					else -- This else corresponds to i_cpha='0'
						-- shift data happens on second edge
						-- and capturing happens on first edge
						if i_sclk='0' then
							-- rising edge
							if i_cpol='0' then     -- first edge
								o_r_strobe <= '1';
								o_w_strobe <= '0';
							else						  -- second edge
								o_r_strobe <= '0';
								o_w_strobe <= '1';
							end if;
						else
							-- falling edge
							if i_cpol='0' then     -- second edge
								o_r_strobe <= '0';
								o_w_strobe <= '1';
							else						  -- first edge
								o_r_strobe <= '1';
								o_w_strobe <= '0';
							end if;
						end if;
					
					end if; 
				
				end if;
				
			end if;
		end if;
	end process strobe_gen_proc;

end architecture behavioral;