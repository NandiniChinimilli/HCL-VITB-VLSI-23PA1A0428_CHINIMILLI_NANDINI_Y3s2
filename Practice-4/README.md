


# Experiment 4 — Racing the Ripple: ALU with Ripple vs. Carry-Select Adder

## 📌 Project Overview
This repository contains the complete design, verification, synthesis, and Static Timing Analysis (STA) for a 16-bit Arithmetic Logic Unit (ALU). The project explores the fundamental tradeoffs between micro-architectural design choices and physical implementation constraints by implementing two distinct adder architectures in the execution path:
1. **Ripple Carry Adder (RCA):** Highly area-efficient but bounded by linear carry-propagation delays ($O(N)$ delay).
2. **Carry-Select Adder (CSA):** High-speed architecture that pre-computes alternative sums and relies on multiplexers to choose the correct path, trading area for optimized timing performance.

Both designs are systematically analyzed under moderate (**8ns / 125 MHz**) and aggressive (**5ns / 200 MHz**) clock constraints to observe slack behavior, cell counts, and critical path trajectories.

---

## 📂 Directory Structure
The workspace is organized following standard industry practices, cleanly decoupling RTL source files, testbenches, synthesis output scripts, and STA reports:

```text
Practice-4/
├── rtl/                        # Synthesizable Verilog Source Code
│   ├── alu_rca.v               # ALU Top Module utilizing Ripple Carry Adder
│   ├── alu_csa.v               # ALU Top Module utilizing Carry-Select Adder
│   ├── alu.v                   # Unified/Parameterized Master ALU Module
│   ├── adder_rca16.v           # 16-bit Ripple Carry Adder
│   ├── adder_csa16.v           # 16-bit Carry-Select Adder
│   ├── adder_rca4.v            # 4-bit Ripple Carry Adder Block
│   └── full_adder.v            # 1-bit Structural Full Adder Cell
├── TB/                         # Simulation Verification Environment
│   ├── tb_adder_rca16.v        # Testbench environment for RCA execution
│   └── tb_adder_csa16.v        # Testbench environment for CSA execution
├── Sim/                        # Verification Evidence & Simulation Captures
│   ├── log_window/             # Console simulation outputs
│   │   ├── alu_rca.png
│   │   └── alu_csa.png
│   └── waveform/               # Timing Diagram waveform traces
│       ├── rca.png
│       └── csa.png
├── Schematic/                  # RTL Gate Layouts / Technology Schematics
│   ├── adder_csa16/
│   │   └── adder_csa16.png
│   ├── adder_rca16/
│   │   └── adder_rca16.png
│   ├── adder_rca4/
│   │   └── adder_rca4.png
│   ├── alu_csa/
│   │   └── alu_csa.png
│   ├── alu_rca/
│   │   └── alu_rca4.png
│   └── fulladder/
│   │   └── fulladder.png
├── dc_synth/                   # Synopsys Design Compiler Flow Workspace
│   ├── output/                 # Generated Post-Synthesis Gate Netlists
│   │   ├── alu_rca/            # rca_5ns.v, rca_8ns.v
│   │   └── alu_csa/            # csa_5ns.v, csa_8ns.v
│   └── reports/                # DC Synthesis Area, Power, and QoR Reports
│       ├── alu_rca/            # rca_area, rca_power, rca_timing, rca_qor rpts
│       └── alu_csa/            # csa_area, csa_power, csa_timing, csa_qor rpts
└── pt_sta/                     # Synopsys PrimeTime Sign-off Timing Workspace
    └── reports/                # Accurate Setup/Hold and QoR STA Reports
        ├── alu_rca/            # rca_5ns/8ns setup, hold, and timing rpts
        └── alu_csa/            # csa_5ns/8ns setup, hold, and timing rpts

```

---

## ⚙️ Functional Specifications & Interface

Both versions share an identical IO footprint, processing data combinationally during the active cycle and synchronizing outcomes into register `Y` at the rising edge of the system clock.

### Interface Table

| Port Name | Direction | Width | Description |
| --- | --- | --- | --- |
| `clk` | Input | 1 bit | System clock (Registers combinational output) |
| `rst_n` | Input | 1 bit | Active-low asynchronous/synchronous register reset |
| `A` | Input | 16 bits | Operand input bus A |
| `B` | Input | 16 bits | Operand input bus B |
| `opcode` | Input | 3 bits | Operation Selection Opcode |
| `Y` | Output | 16 bits | Registered execution output result |
| `carry_out` | Output | 1 bit | Carry out (for ADD) / Borrow flag (for SUB) |
| `zero_flag` | Output | 1 bit | High if output result `Y` matches 16'h0000 |
| `overflow_flag` | Output | 1 bit | Arithmetic signed overflow flag indicator |

### Supported Opcode Mapping

* `3'b000` : **ADD** ($A + B$)
* `3'b001` : **SUB** ($A - B$ using 2's complement logic)
* `3'b010` : **AND** (Bitwise logical mask)
* `3'b011` : **OR** (Bitwise logical combination)
* `3'b100` : **XOR** (Bitwise logical difference)

---

## 🧪 Functional Verification & Waveform Logs

The verification suite instantiates both DUT models under complex directed and pseudo-randomized configurations to guarantee math integrity across boundary limits (e.g., zero evaluations, signed overflows, and extreme carry generation like `16'hFFFF + 16'h0001`).

### Simulation Output Logs

Below are the console printouts confirming matching assertions against the behavioral golden model environment:

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/1b43fa01-ee71-42f4-aad3-9a5289e70b2a" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3cac2d33-b210-4b52-803e-4e0c5a184125" />



### Functional Simulation Waveforms

Variables are safely initialized inline (`= 0`) inside the testbench to guarantee immediate clean transitions at startup, entirely bypassing simulator delta-cycle initialization anomalies.

#### Ripple Carry Adder Waveform Track:

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d09c7418-713a-415a-bd4e-5753180cb5ee" />


#### Carry-Select Adder Waveform Track:

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/eb23337b-70de-47e3-85e8-d7e9896cfea1" />

---

### Master Comparison Matrix
*Data directly extracted from Synopsys Design Compiler Area and Timing (QoR) reports.*

| ALU Version | Clock Period (ns) | WNS (ns) | Meets Timing? | Total Area (µm²) | FF Count | Comb Cells | Dominant Critical Path |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **RCA** | 8 | 0.00 | Yes | 739.497 | 19 | 167 | A[0] ➡️ Carry Chains ➡️ Mux ➡️ Y_reg |
| **RCA** | 5 | 0.00 | Yes | 744.247 | 19 | 168 | A[0] ➡️ Carry Chains ➡️ Mux ➡️ Y_reg |
| **CSA** | 8 | 0.00 | Yes | 943.726 | 19 | 221 | A[0] ➡️ Block Muxes ➡️ Mux ➡️ Y_reg |
| **CSA** | 5 | 0.00 | Yes | 943.726 | 19 | 221 | A[0] ➡️ Block Muxes ➡️ Mux ➡️ Y_reg |



## 📝 Analysis & Engineering Discussion

### 1. Timing Performance & Slack Interpretations
* **At 8ns (125 MHz):** Both architectures perfectly satisfy timing targets, reporting a Worst Negative Slack (WNS) of exactly `0.00 ns`. This indicates that Design Compiler successfully optimized both execution paths to match the target clock edge with zero margin violations.
* **At 5ns (200 MHz):** Under the aggressive 5ns clock constraint, the Ripple Carry Adder (RCA) **does not drop into negative slack**. It successfully meets timing at exactly `0.00 ns` WNS. However, because the 16-bit ripple carry chain is structurally slow, Design Compiler was forced to perform aggressive gate-sizing and logic optimization to squeeze it into the 5ns window. This is mathematically proven by the RCA's structural changes: its combinational cell count increased from 167 to 168, and its total area swelled from **739.497 µm²** to **744.247 µm²**. 
* Conversely, the Carry-Select Adder (CSA) handles the 5ns constraint effortlessly. It achieves `0.00 ns` WNS without requiring any increase in cell count (remaining at 221) or area (remaining at **943.726 µm²**), demonstrating that the CSA architecture possesses a naturally superior timing margin.

### 2. Physical Area Trade-Off Evaluation
When evaluating total cell area metrics extracted from the reports, the physical overhead of the CSA is highly evident. The CSA requires a fixed footprint of **943.726 µm²** regardless of the clock target. Compared to the baseline RCA at 8ns (**739.497 µm²**), this represents an approximate **27.6% area penalty**. 
The CSA requires this extra silicon real estate because it physically duplicates the 4-bit adder lanes to pre-compute alternative sums for both `Cin=0` and `Cin=1` configurations simultaneously, using intermediate multiplexers to select the correct output. Flip-flop counts remain completely constant at 19 cells for both designs, proving that the area inflation is entirely isolated to combinational steering logic.

### 3. Critical Path Analysis
* **RCA Critical Path:** The longest path goes linearly through the data inputs, propagating sequentially through all 16 carry-generation gates (`co = g + (p . cin)`) before passing through the final ALU operation selector multiplexer and arriving at the `Y_reg` input. Because this path is long, the synthesis tool had to up-size the logic gates at 5ns to make them faster, causing the observed area increase.
* **CSA Critical Path:** The CSA breaks this 16-bit carry-propagation bottleneck. By isolating the ripple effect to independent 4-bit sub-blocks and pre-computing the higher bits in parallel, the critical path no longer waits for a 16-bit serial chain. The worst path is reduced to passing through a single 4-bit block delay plus the propagation delay of the fast selection multiplexers. 

### 4. Micro-Architectural Takeaways
This experiment perfectly demonstrates a core ASIC principle: **Trading silicon area for timing margin**. 
Using the RCA at 5ns is possible, but it forces the synthesis tool to push the gates to their physical limits, increasing cell sizes and dynamic power. The CSA solves this problem at the architectural level. While it costs ~27% more area, it clears the 5ns timing constraint easily without putting stress on the library cells. 

While an RCA might be preferred for small, low-power low-frequency microcontroller blocks, scaling up to **32-bit** or **64-bit** designs makes a Ripple Carry architecture completely prohibitive. At higher word lengths, the parallel pre-computation found in Carry-Select or Carry-Lookahead networks becomes an absolute physical necessity to achieve high performance.
