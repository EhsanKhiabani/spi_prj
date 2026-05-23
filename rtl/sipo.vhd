-- ============================================================
--  SIPO (Serial In Parallel Out) Shift Register
--  Generic and configurable shift direction
-- ============================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- =========================
-- Entity Declaration
-- =========================
entity sipo is
 generic(
  -- Width of the shift register (number of bits)
  CWIDTH : natural := 8;

  -- Shift direction selector
  -- true  -> Left shift
  -- false -> Right shift
  LEFT_SHIFT : boolean := false
 );
 port(
  -- Serial input bit
  i_bit   : in std_logic;

  -- Clock input (synchronous design)
  i_clk   : in std_logic;

  -- Shift enable signal
  -- When '1', one shift operation occurs
  i_shift : in std_logic;

  i_en	 : in std_logic;
  -- Synchronous reset
  -- When '1', register is cleared to zero
  i_rst   : in std_logic;

  -- Parallel output data
  o_data  : out std_logic_vector(CWIDTH-1 downto 0)
 );
end entity sipo;

-- =========================
-- Architecture Definition
-- =========================
architecture behavioral of sipo is

 -- Internal register to store shifted data
 -- Initialized to zero to avoid undefined simulation values
 signal s_register : std_logic_vector(CWIDTH-1 downto 0) := (others=>'0');

begin

 -- Main clocked process
 main_body: process(i_clk)
 begin

  -- Rising edge triggered register
  if i_clk'event and i_clk='1' then

   -- Highest priority: synchronous reset
   -- Clears register content
   if i_rst='1' then
    s_register <= (others=>'0');

   -- Shift left mode
   -- New serial bit enters at LSB
   -- MSB is discarded
   elsif i_shift='1' and i_en='1' and LEFT_SHIFT = true then
    s_register <= s_register(CWIDTH-2 downto 0) & i_bit;

   -- Shift right mode
   -- New serial bit enters at MSB
   -- LSB is discarded
   elsif i_shift='1' and i_en='1' and LEFT_SHIFT = false then
    s_register <= i_bit & s_register(CWIDTH-1 downto 1);

   -- If shift is not enabled,
   -- register holds previous value automatically
   end if;

  end if;
 end process main_body;

 -- Continuous assignment of internal register
 -- to parallel output
 o_data <= s_register;

end architecture behavioral;
