# ====================================
#  Compile dependency RTL (VHDL-2008)
# ====================================

vcom -2008 ./rtl/*.vhd

# =====================
#  Compile testbench
# =====================

vcom -2008 ./tb/tb_strobe_gen.vhd

# =====================
#   Initial Simulation
# =====================

vsim work.tb_strobe_gen

# ========================================================================
# ========================  SPI WAVEFORM CONFIGURATION ===================
# ========================================================================

onerror {resume}
quietly WaveActivateNextPane {} 0

# ------------------------------------------------------------------------
# 1. CONFIGURE GROUP
# ------------------------------------------------------------------------
add wave -noupdate -divider {Configure}
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/brg_ut/i_cpol}       sim:/tb_strobe_gen/brg_ut/i_cpol
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/mstrobe_ut/i_cpha}   sim:/tb_strobe_gen/mstrobe_ut/i_cpha

# ------------------------------------------------------------------------
# 2. CLOCK GROUP
# ------------------------------------------------------------------------
add wave -noupdate -divider {Clock}
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/brg_ut/i_clk}        sim:/tb_strobe_gen/brg_ut/i_clk
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/brg_ut/o_baud_tick}  sim:/tb_strobe_gen/brg_ut/o_baud_tick
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/brg_ut/o_sclk}       sim:/tb_strobe_gen/brg_ut/o_sclk
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/sstrobe_ut/s_sclk_sync} sim:/tb_strobe_gen/sstrobe_ut/s_sclk_sync

# ------------------------------------------------------------------------
# 3. MASTER GROUP
# ------------------------------------------------------------------------
add wave -noupdate -divider {Master}
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/mstrobe_ut/o_w_strobe} sim:/tb_strobe_gen/mstrobe_ut/o_w_strobe
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/mstrobe_ut/o_r_strobe} sim:/tb_strobe_gen/mstrobe_ut/o_r_strobe

# ------------------------------------------------------------------------
# 4. SLAVE GROUP
# ------------------------------------------------------------------------
add wave -noupdate -divider {Slave}
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/sstrobe_ut/o_r_strobe} sim:/tb_strobe_gen/sstrobe_ut/o_r_strobe
add wave -noupdate -format Logic -radix Binary -label {/tb_strobe_gen/sstrobe_ut/o_w_strobe} sim:/tb_strobe_gen/sstrobe_ut/o_w_strobe

# ------------------------------------------------------------------------
# WAVE WINDOW CONFIGURATION
# ------------------------------------------------------------------------
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24059165 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 310
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update

# =====================
#       RUN SIM
# =====================

run 250 us 


wave zoom full 