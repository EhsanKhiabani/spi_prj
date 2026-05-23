# 1. Compile the utility package first (Top-level dependency)
vcom -reportprogress 300 -2008 ./pkgs/spi_utils_pkg.vhd

# 2. Compile all RTL source files. 
# Recompilation is necessary here to ensure design units remain 
# consistent with the updated utility package.
vcom -reportprogress 300 -2008 ./rtl/falling_edge_detector.vhd
vcom -reportprogress 300 -2008 ./rtl/master_strobe_gen.vhd
vcom -reportprogress 300 -2008 ./rtl/mux2x1.vhd
vcom -reportprogress 300 -2008 ./rtl/piso.vhd
vcom -reportprogress 300 -2008 ./rtl/reg_nbit.vhd
vcom -reportprogress 300 -2008 ./rtl/rising_edge_detector.vhd
vcom -reportprogress 300 -2008 ./rtl/sipo.vhd
vcom -reportprogress 300 -2008 ./rtl/slave_mode_detector.vhd
vcom -reportprogress 300 -2008 ./rtl/slave_strobe_gen.vhd
vcom -reportprogress 300 -2008 ./rtl/spi_brg.vhd

vcom -reportprogress 300 -2008 ./rtl/spi_fsm.vhd
vcom -reportprogress 300 -2008 ./rtl/sync_comparator.vhd
vcom -reportprogress 300 -2008 ./rtl/synchronizer.vhd
vcom -reportprogress 300 -2008 ./rtl/tri_state.vhd
vcom -reportprogress 300 -2008 ./rtl/trigger_toggle.vhd
vcom -reportprogress 300 -2008 ./rtl/universal_counter.vhd

vcom -reportprogress 300 -2008 ./rtl/spi_core.vhd
# 3. Compile the testbench last, as it depends on both 
# the utility package and the RTL modules.
vcom -reportprogress 300 -2008 ./tb/tb_spi.vhd

# 4. Load the testbench and start the simulation
vsim work.tb_spi


# =====================
#       ADD Waves   
# =====================

add wave -position end sim:/tb_spi/dut/*

# =====================
#       RUN SIM
# =====================

run 60 us 


wave zoom full 