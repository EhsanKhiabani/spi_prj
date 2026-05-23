# ====================================
#  Compile dependency RTL (VHDL-2008)
# ====================================

vcom -2008 ./rtl/reg_nbit.vhd
vcom -2008 ./rtl/sync_comparator.vhd
vcom -2008 ./rtl/trigger_toggle.vhd
vcom -2008 ./rtl/universal_counter.vhd

vcom -2008 ./rtl/spi_brg.vhd

# =====================
#  Compile testbench
# =====================

vcom -2008 ./tb/tb_spi_brg.vhd

# =====================
#   Initial Simulation
# =====================

vsim work.tb_spi_brg

# =====================
#       ADD Waves   
# =====================

add wave -position end sim:/tb_spi_brg/dut/*

# =====================
#       RUN SIM
# =====================

run 250 us 


wave zoom full 