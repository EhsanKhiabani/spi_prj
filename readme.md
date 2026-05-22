# SPI Core RTL Design Project

## Overview

![SPI Block Diagram](architecture_v1.1.png)

This project presents a highly robust, synthesizable RTL implementation of a complete **SPI (Serial Peripheral Interface) Core** protocol controller written in VHDL. 

While initially engineered as an educational model to demonstrate computer architecture and advanced digital design methodologies, the core is built entirely to industrial hardware specifications. It includes comprehensive Clock Domain Crossing (CDC) synchronization, glitch-free strobe generation, and true tri-state high-impedance I/O buffers, making it fully ready for FPGA deployment or ASIC synthesis.

The implementation focuses on:
- **Full hardware synthesizability** avoiding any non-synthesizable VHDL constructs in the RTL paths.
- **Robust Multi-Mode Support** full execution of standard SPI Modes 0, 1, 2, and 3.
- **Glitch-Free Strobe Management** precise single-cycle internal read/write pulses derived via synchronous edge-detection and optimized combinational decoding.
- **Metastability Mitigation** dedicated CDC synchronization stages on asynchronous external lines.

---

## Features

- **Full-Duplex Communication:** Simultaneous data transmission and reception.
- **Dynamic Master/Slave Reconfiguration:** Dynamically configured via the output enable (`i_oe`) and chip select (`i_cs_n`) inputs.
- **Generic-Based Bit Width Configuration:** Configurable data frame size (default is 8-bit, customizable via VHDL generics).
- **Comprehensive Protocol Matrix:** Fully supports all 4 standard combinations of Clock Polarity (`CPOL`) and Clock Phase (`CPHA`).
- **Programmable Baud Rate Generator (BRG):** Easily derives master clock timing from a standard system clock using an 8-bit division factor.
- **Industrial-Grade I/O Management:** Integrated tri-state buffers for shared lines (`io_sclk`, `io_miso`, `io_mosi`).

---

## Hardware Architecture

The core uses a modular, structural architecture engineered to satisfy rigorous timing closure criteria. The main blocks include:

1. **`spi_core` (Top-Level structural wrapper):** Orchestrates the data paths, interconnects, multi-bit multiplexers, and bi-directional tri-state pin drivers.
2. **`spi_fsm` (Central Protocol Controller):** Designed strictly as a 2-Process Moore Machine. All output controls are fully registered or decoded directly from the state registers, guaranteeing glitch-free combinational paths.
3. **`master_strobe_gen` & `slave_strobe_gen`:** Advanced timing units that translate physical clock transitions into single-cycle validation flags (`o_r_strobe`, `o_w_strobe`) mapping exactly to the chosen SPI phase mode.
4. **`spi_brg` (Baud Rate Generator):** Generates steady internal baud rate ticks based on the division formula: 
   $$\text{BRR} = \frac{F_{\text{clk}}}{2 \times F_{\text{sclk}}} - 1$$
5. **`sipo` & `piso`:** Left-shifting high-speed Serial-In Parallel-Out and Parallel-In Serial-Out registers handling data streams.
6. **`synchronizer`:** Double-register stages that isolate internal clock networks from metastability issues introduced by asynchronous inputs.

---

## Project Structure

```text
spi_rtl/
│
├── rtl/                        # Synthesizable RTL Source Files
│   ├── spi_core.vhd            # Structural Top-Level Wrapper
│   ├── spi_fsm.vhd             # Moore Finite State Machine Core
│   ├── master_strobe_gen.vhd   # Master-mode Timing Engine
│   ├── slave_strobe_gen.vhd    # Slave-mode CDC Timing Engine
│   ├── spi_brg.vhd             # Baud Rate Generator
│   ├── piso.vhd                # Parallel-In Serial-Out Shifter
│   ├── sipo.vhd                # Serial-In Parallel-Out Shifter
│   ├── universal_counter.vhd   # En_Counter for active bit tracking
│   ├── synchronizer.vhd        # Metastability isolation stage
│   ├── rising_edge_detector.vhd# Edge detection unit
│   ├── falling_edge_detector.vhd# Edge detection unit
│   ├── slave_mode_detector.vhd # Master/Slave dynamic logic selector
│   ├── mux2x1.vhd              # Structural data multiplexer
│   ├── tri_state.vhd           # Bi-directional high-impedance buffer
│   ├── reg_nbit.vhd            # Standard storage register
│   └── trigger_toggle.vhd      # Pulse-to-toggle divider logic
│
├── pkgs/                       # Custom Data Type Packages
│   └── spi_utils_pkg.vhd       # Custom array types & utility definitions
│
├── tb/                         # Simulation Testbenches
│   ├── tb_spi.vhd              # Full Core Top-Level System Testbench
│   ├── tb_spi_brg.vhd          # Baud Rate Generator Testbench
│   └── tb_spi_fsm.vhd          # Finite State Machine Testbench
│
├── sim/                        # ModelSim / QuestaSim Simulation Scripts
│   ├── run_spi_core.do         # Compiles & executes complete system sim
│   ├── run_brg_tb.do           # Compiles & executes BRG validation 
│   └── run_strobe_gen.do       # Compiles & executes timing verification
│
└── docs/                       # Verification Waveforms & Diagrams
    ├── architecture.png        # Complete block-level data path routing
    ├── FSM.png                 # Moore State Transitions Diagram
    ├── strobe_test.png         # Glitch-free read/write verification wave
    ├── spi_core_test.png       # End-to-end transceiver system loop wave
    └── recieve_data_report.png # VHDL-2008 hex monitor logging capture
```
## Verification & Simulation

[cite_start]System functionality is validated using a self-checking verification framework that emulates true SPI interface conditions[cite: 29]. Transmissions are logged into the console in clean Hexadecimal notation compliant with VHDL-2008 standards.

### Running Simulations via ModelSim / QuestaSim
To run an automated test setup, navigate your terminal to the `sim/` directory, launch your simulation environment, and call the desired script macro:

```tcl
# Open your simulator system shell and invoke:
do run_spi_core.do‍‍‍‍‍‍‍```
```

### Waveform Analysis

The design incorporates exhaustive testing routines checking extreme timing constraints. Signal loops can be cross-examined using saved waveforms located in the `docs/` folder:

* **`docs/strobe_test.png`**: Analyzes the precision tracking of `s_mr_strobe` (Master Read) and `s_mw_strobe` (Master Write) against shifting registers to guarantee no data race conditions occur during phase edge evaluation.
* **`docs/spi_core_test.png`**: Documents the complete full-duplex byte transaction loop from Master PISO to Slave SIPO, demonstrating state progressions of the FSM controller under multi-byte payloads.
* **`docs/recieve_data_report.png`**: Displays real-time array status updates printed onto the simulation transcript console during frame completion hooks using the `to_hstring` formatters.

---

## Production Deployment & FPGA Synthesis

This core uses strict synchronous design rules, relying exclusively on an external global clock source (`i_clk`). There are no gated or ripple clocks used internally.

### Implementation Guidelines

* **Target Pin Assignments**: Assign the `io_sclk`, `io_miso`, and `io_mosi` nets to FPGA pins configured with pull-up/pull-down options matching your system board design requirements.
* **Tri-State Controls**: The design internally encapsulates structural VHDL primitives handling high-Z state transitions via the `tri_state.vhd` block. If your target hardware vendor tool suite (e.g., AMD/Xilinx Vivado, Intel Quartus Prime) restricts inside-core tri-state implementations, you can cleanly expose the `i_en` control lines out to the top layer for instantiation within physical I/O pad primitives.
* **Timing Constraints**: Bind a standard `.sdc` (Synopsys Design Constraints) file specifying your main clock target frequency. External lines passing through `synchronizer.vhd` must be flagged with `set_false_path` or `set_max_delay` rules to isolate CDC jitter tracking from standard static timing calculations.

---

## Educational Value

Beyond its direct target physical utility, this codebase serves as an ideal pedagogical blueprint for:

* **RTL Modularization**: Learning how to split complex digital protocols into structural wrappers, controllers, timing units, and custom package declarations (`spi_utils_pkg.vhd`).
* **Bus Contention Prevention**: Handling bidirectional hardware busses safely using tri-state logic gates.
* **Metastability Isolation**: Managing reliable Clock Domain Crossing (CDC) networks using synchronized edge detection when bridging data over external multi-clock domains.
* **Modern Test Environment Development**: Writing self-checking VHDL testbenches utilizing automated log transcripts.


