-- ========================================================================
-- MODULE DESCRIPTION:
--   Name: spi_fsm
--   Type: 2-Process Moore Finite State Machine (FSM)
--   Reset: Synchronous, Active-Low (i_rst_n = '0')
--
--   Functional Overview:
--     This module acts as the central controller for an SPI protocol core,
--     supporting both Master and Slave modes. It orchestrates the lifecycle
--     of a single SPI frame transaction through 5 dedicated states:
--       1. idle        : Waits for activation (i_en) based on mode/output enable.
--       2. load_frame  : Asserts buffer loading and initiates the pipeline.
--       3. en_clk_gen  : Activates clocking paths and prepares counters.
--       4. transceiver : Manages the active full-duplex shifting window until
--                        both TX and RX bit counters reach the 8-bit boundary.
--       5. done        : Issues a single-cycle valid strobe upon completion.
--
--   Architectural Note:
--     Designed strictly as a Moore Machine. All output control signals are 
--     decoded solely from the current state register (s_curr_state), ensuring 
--     glitch-free combinational outputs and optimized timing closure.
-- ========================================================================

-- ==========================================================
-- ===============   SPI Finite State Machine       =========
-- ===============         SPI Project              =========
-- ==========================================================


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity spi_fsm is 
	generic(
		BIT_NUMBER : natural := 8
	);
	port (   
		i_clk		: in std_logic;
		i_en		: in std_logic;
		i_rst_n	: in std_logic;
		i_slave_mode	: in std_logic;
		i_oe		: in std_logic;

		i_tx_bit_cnt	: in std_logic_vector(3 downto 0);
		i_rx_bit_cnt	: in std_logic_vector(3 downto 0);

		o_tx_reg_load	: out std_logic;
		o_en_baud_gen	: out std_logic;
		
		o_rx_rst_cntr	: out std_logic;	
		o_tx_rst_cntr	: out std_logic;
		o_busy	: out std_logic;
		o_valid	: out std_logic

	);
end entity  spi_fsm;

architecture behavioral of  spi_fsm is
	type spi_state_t is (idle, load_frame, en_clk_gen, transceiver, done);

	signal s_next_state :  spi_state_t := idle;
	signal s_curr_state :  spi_state_t := idle;
begin

 -- ============================
 -- ==== Sequential Section ====
 -- ============================
 seq_proc: process(i_clk)
 begin

   if rising_edge(i_clk) then
		if i_rst_n='0' then 
     		
			s_curr_state <= idle;
		else
			s_curr_state <= s_next_state;

		end if;
   end if;

 end process seq_proc;



 -- ==============================
 -- ==== Combinational Section ===
 -- ============================== 
 comb_proc: process(all)
 begin
 
 -- ===== default assignment
	s_next_state <=   s_curr_state;
	o_tx_reg_load	<= '0';
	o_en_baud_gen	<= '0';
	o_rx_rst_cntr	<=	'0';
	o_tx_rst_cntr	<=	'0';
	o_busy			<=	'0';
	o_valid			<=	'0';

 -- ===== state codes and transaction
	case s_curr_state is
		when idle	=>
			if (i_slave_mode='1' and i_en='1') or
				(i_oe='1' and i_en='1') then
				s_next_state <=   load_frame;
				o_busy			<=	'1';
			end if;
		when load_frame	=>
			if i_en='0' then
				s_next_state <=   idle;
			else
				s_next_state <=   en_clk_gen;
			end if;
			o_busy <= '1';
			o_tx_reg_load <= '1';
			
		when en_clk_gen	=>
			o_busy <= '1';
			o_rx_rst_cntr <= '1';
			o_tx_rst_cntr <= '1';
			o_en_baud_gen <= i_oe;
			if i_en='0' then
				s_next_state <=   idle;
			else
				s_next_state <=   transceiver;
			end if;
		when transceiver	=>
			o_busy <= '1';

			o_en_baud_gen <= i_oe;			
			if i_en='0' then
				s_next_state <=   idle;
			else
				o_rx_rst_cntr <= '1';
				o_tx_rst_cntr <= '1';	
				if unsigned(i_tx_bit_cnt) = BIT_NUMBER and unsigned(i_rx_bit_cnt) = BIT_NUMBER then
					s_next_state <=   done;
					o_en_baud_gen <= '0';
				else
					s_next_state <=   transceiver;
					
				end if;
			end if;					
		when done	=>
			o_valid <= '1';
			s_next_state <=   idle;
	end case; 
 end process comb_proc;

end architecture behavioral;
