# Sequential Leaky Integrate-and-Fire Relay Selector
Project Title: Sequential Leaky Integrate-and-Fire Relay Selector
A Neuromorphic Hardware Implementation of Cooperative Relay Selection 
This project is done by: Shams Abdulhameed
Maste program student
For the class ECE210 requirement
Under the supervision of
Prof. Jason Eshraghian and Prof. Zouhair Rezki
The design methodology, neuromorphic LIF model, and verification workflow follow the RTL design and simulation principles discussed in: ECE 210 – Neuromorphic Engineering and Hardware Systems,
Canvas Lecture Materials and Course Notes,
University of California, Santa Cruz.

## Project Overview
Abstract
This project implements a hardware-efficient neuromorphic decision module for relay selection in cooperative wireless communication systems. Based on prior Monte Carlo simulations evaluating Bit Error Rate (BER) performance under different power allocation values (α), this design translates the optimal relay selection rule into a synthesizable digital architecture. Instead of computing BER or Signal-to-Noise Ratio (SNR) in hardware, the system embeds the learned decision boundary into a sequential Leaky Integrate-and-Fire (LIF) neuron model combined with a Winner-Take-All (WTA) arbitration mechanism. The result is a low-complexity, fixed-point digital circuit that performs relay selection using accumulation, leakage, and threshold comparison.

## Problem Statement
	Communication-Theory Background
In cooperative wireless communication systems, multiple relay strategies exist:
       -Amplify-and-Forward (AF)
      - Decode-and-Forward (DF)
         - Compress-and-Forward (CF)
Based on simulation results from prior software analysis I am already working on for my research in ECE297 class, different power allocation values favor different relay strategies. This project translates that decision logic into a hardware-efficient neuromorphic circuit.
1.1 Signal Model
In cooperative wireless systems, the received signal is modeled as:
                                                   y=√P " " h" " s+n
Where:
	P= transmit power
	h= fading channel coefficient
	s= transmitted BPSK symbol
	n= additive white Gaussian noise (AWGN)
The effective channel gain is:
g=√P " " h

The Signal-to-Noise Ratio (SNR) per branch is proportional to:
SNR=(∣g∣^2)/N_0 

1.2 Relay Strategies
Three cooperative relay strategies were considered:
	AF — Amplify-and-Forward
	DF — Decode-and-Forward
	CF — Compress-and-Forward
Power allocation between links is defined as:
P_SR=αP
P_RD=(1-α)P

The optimal relay strategy is determined by:
Relay^* (α)=arg⁡min⁡{BER_AF (α),BER_DF (α),BER_CF (α)}

This selection rule was evaluated through Monte Carlo BER simulations under Rayleigh fading.

2. From Simulation to Hardware Policy
Monte Carlo analysis revealed α-dependent decision regions:
	Low α → AF preferred
	Mid α → DF preferred
	High α → CF preferred
Instead of computing BER in hardware, the decision behavior was extracted as a region-based policy.
Conceptually:
arg⁡min⁡BER(α)⟶"Relay preference regions in " α

This decision boundary is embedded directly into hardware dynamics.


3. Neuromorphic Translation
3.1 LIF Neuron Model
From neuromorphic system theory, the discrete-time LIF equation is:
V[k+1]=V[k]+I[k]-LEAK

Spike condition:
V[k]≥THRESHOLD

Where:
	V= membrane potential
	I= input current
	LEAK = decay constant
## System Architecture
Input: - 8-bit alpha value representing power allocation
Processing:
- Three LIF neuron blocks (AF, DF, CF)
- Each neuron integrates weighted alpha
- Leak mechanism prevents unlimited growth
- Threshold detection determines activation
Decision:
- Winner-Take-All logic selects the first neuron crossing threshold
alpha=20  -> AF (00)
alpha=120 -> CF (10)
alpha=220 -> DF (01)
then  it:
expected = {20: 0b00, 120: 0b01, 220: 0b10}
assert sel == expected[a], f"alpha={a} expected {expected[a]:02b} got {sel:02b}"

3.2 Conceptual Mapping
Communication Theory	Hardware Implementation
Power allocation α	8-bit input (ui_in)
Relay preference	Weighted neuron input
BER comparison	Threshold crossing
arg min(BER)	Winner-Take-All logic
Instead of minimizing BER numerically, neurons compete dynamically.
The first neuron to reach threshold determines the relay.
## Design Motivation
The objective is to demonstrate how brain-inspired circuits can perform decision-making using:
- Fixed-point arithmetic
- Minimal logic resources
- Threshold-based early decision
- No multipliers or floating-point operations
This reduces hardware complexity and power consumption compared to conventional digital computation.
Circuit Description
This design implements a Leaky Integrate-and-Fire (LIF) based Winner-Take-All relay selector in hardware. The circuit evaluates three candidate relays (AF, DF, CF) using alpha-dependent current functions and selects the relay whose membrane voltage reaches threshold first.
Each relay is modeled as a discrete-time LIF neuron. The membrane voltage update implemented in hardware corresponds to:
V_k (t+1)=max⁡(0,"  " V_k (t)+I_k (α)-"LEAK" )

where:
	V_kis the membrane register (V_AF, V_DF, V_CF)
	I_k (α)is the alpha-dependent current
	LEAK is a constant decay term (parameter LEAK = 4)
	The max(0, ·) is implemented by clamping negative values to zero
This update is implemented in the lif_update() function using an adder and subtractor block.
Alpha-Dependent Current Functions
The three relay candidates receive different current functions derived from the input metric α:
AF (Amplify-and-Forward) favors low alpha:
I_AF (α)=255-α

(Implemented as 16'd255 - alpha_ext)
DF (Decode-and-Forward) increases linearly with alpha:
I_DF (α)=2α

(Implemented as alpha_ext << 1)
CF (Compress-and-Forward) peaks near mid-range alpha:
I_CF (α)=C-∣α-128∣

(Implemented using absolute difference logic in the code)
Threshold Decision
A relay triggers a spike event when:
V_k (t+1)≥"THRESHOLD" 

where:
"THRESHOLD"=400

When any neuron crosses threshold, the circuit performs a Winner-Take-All comparison:
"relay_sel"=arg⁡(max⁡)┬k V_k (t+1)

This comparison is implemented using combinational magnitude comparators.
After selection, all membrane voltages are reset to zero to begin the next decision cycle.

Hardware Blocks Used
The implementation consists of:
	3 membrane voltage registers (16-bit)
	Adders and subtractors (integration and leak)
	Magnitude comparators (threshold + WTA)
	Multiplexer logic (relay selection)
	Synchronous reset logic
This architecture demonstrates event-driven decision-making using simple arithmetic and comparator blocks suitable for low-power digital hardware.
4. Hardware Architecture
4.1 Top-Level Structure
tt_um_example (project.v)
└── lif_relay (lif_relay.v)
    ├── Neuron_AF
    ├── Neuron_DF
    ├── Neuron_CF
    └── Winner-Take-All block

4.2 Input
	8-bit α value (ui_in[7:0])

4.3 Processing Core
Each neuron performs:
V_next=V+I-LEAK

If:
V_next≥THRESHOLD

the neuron activates.
Internal registers:
	V_AF
	V_DF
	V_CF
## Simulation and Verification
The design was verified using RTL simulation.



Test cases include:
	AF current: I_AF=255-α→ favors low alpha
	DF current: I_DF=2α→ favors high alpha
	CF current: I_CF=C-∣α-128∣→ favors mid alpha
 theoretically it should be:
        - Low alpha → AF selected
       - Mid alpha → DF selected
        - High alpha → CF selected
Waveforms confirm correct relay selection behavior.

4.4 Decision Logic                         
Winner-Take-All arbitration selects the first activated neuron.
Output encoding:
	00 → AF
	01 → DF
	10 → CF
Output signal: relay_sel[1:0]
5. Design Characteristics
The circuit uses:
	Fixed-point arithmetic
	Adders and subtractors
	Comparators
	D flip-flops
	No multipliers
	No floating-point operations
This significantly reduces hardware complexity and switching activity compared to conventional optimization-based computation.

6. Verification Methodology
6.1 Initial RTL Testing (Manual / LED-Style)
Early verification was performed using direct RTL simulation:
	α manually assigned inside testbench
	relay_sel observed via waveform
	Relay selection mapped to LED-style binary output
	Simulated using Icarus Verilog
This stage confirmed:
	Correct accumulation behavior
	Proper threshold detection
	Stable relay selection
6.2 Cocotb-Based Verification
The test methodology was upgraded to a structured Cocotb framework.
Cocotb test features:
	Programmatic clock and reset control
	Automated α stimulus generation
	Assertion checks for valid relay encoding
	Deterministic regression testing
Waveforms were generated using waves.vcd and inspected for correctness.
6.3 Structural Validation
Synthesis performed using Yosys:
	RTL schematic generation
	Gate-level schematic generation
This confirmed:
	Proper register inference
	Comparator logic implementation
	Sequential state storage
	No unintended latch inference
Simulation and Execution Procedure
The relay selector was verified using the provided Docker-based cocotb simulation environment. From the root directory of the repository (ECE210-ttsky-Shams_Abdulhameed), the Docker container was launched, and the simulation was executed by running:
make
The make command automatically compiles the Verilog RTL source files (project.v and lif_relay.v) together with the testbench (tb.v) using Icarus Verilog and then runs the cocotb verification framework.
During simulation, cocotb performs the following sequence:
	Initializes the design and applies a proper reset pulse.
	Drives multiple 8-bit power allocation values (α) through the input port ui_in[7:0].
	Allows the sequential LIF-based hardware to integrate and settle.
	Reads the 2-bit relay decision from uo_out[1:0].
Input and Output Format
	Input width: 8 bits
	ui_in[7:0] represents the power allocation parameter α.
	Output width: 2 bits
	relay_sel = uo_out[1:0]
The relay encoding is defined as:
	00 → Amplify-and-Forward (AF)
	01 → Decode-and-Forward (DF)
	10 → Compress-and-Forward (CF)

Terminal Output
When the simulation runs successfully, the Docker terminal displays the selected relay for each tested alpha value. Example output:
alpha= 20  -> relay_sel=00 (AF)
alpha=120  -> relay_sel=10 (CF)
alpha=220  -> relay_sel=01 (DF)
At the end of execution, cocotb reports:
TESTS=1 PASS=1 FAIL=0
indicating that the design behaved correctly for all test cases.

Waveform Generation
In addition to terminal logs, the simulation automatically generates a waveform file:
test/waves.vcd
This file can be opened using a waveform viewer (e.g., Surfer or GTKWave) to inspect:
	The 8-bit alpha input
	Internal neuron activity
	Winner-Take-All selection
	The final 2-bit relay output
The waveform confirms the sequential integration behavior and threshold-based decision mechanism implemented in the neuromorphic relay selector.

This structured verification procedure demonstrates that the hardware correctly translates the alpha-dependent relay selection policy into a deterministic 2-bit digital decision.
7. The project follows a traceable development path:
Communication Theory
→ Monte Carlo BER Simulation
→ Extraction of α-dependent relay preference behavior
→ Encoding preference as LIF current functions
→ RTL Implementation (sequential LIF + WTA)
→ Cocotb Verification
→ Synthesis & Structural Validation
The theoretical selection rule:
Relay^* (α)=arg⁡min⁡BER(α)

is approximated in hardware as:
Relay_HW (α)=arg⁡(max⁡)┬k V_k (t)"subject to" V_k (t)≥THRESHOLD



is implemented in hardware as:
Dynamic LIF competition + Winner-Take-All arbitration.
## RTL Hierarchical Schematic

The synthesized RTL structure of the design is shown below. 
The top-level module `tt_um_example` instantiates the neuromorphic relay selector core `lif_relay`, which generates the 2-bit `relay_sel` output.

[View RTL Schematic (PDF)](lif_rtl_schematic.pdf)

## Gate-Level Schematic
[View Gate Schematic (PDF)](lif_gate_schematic.pdf)
## Future Improvements
Future Work
In this prototype, the input α is a simplified synthetic metric used to demonstrate hardware feasibility. The current design does not incorporate real channel state information (CSI), BER measurements, or adaptive learning.
Future extensions may include:
	Replacing α with real-time SNR or BER measurements from a communication system.
	Learning current functions I_k (α)from simulation data.
	Implementing adaptive thresholds.
	Integrating reward-based or spike-timing-based learning.
	Mapping the design to FPGA or ASIC for power measurement.
This work establishes a hardware foundation for energy-aware relay selection and can be expanded toward practical wireless communication systems.


8. References
[1] A. Goldsmith, Wireless Communications, Cambridge University Press, 2005.
[2] D. Tse and P. Viswanath, Fundamentals of Wireless Communication, Cambridge University Press, 2005.
[3] T. M. Cover and A. El Gamal, “Capacity Theorems for the Relay Channel,” IEEE Trans. Information Theory, 1979.
[4] A. Nosratinia et al., “Cooperative Communication in Wireless Networks,” IEEE Communications Magazine, 2004.
[5] A. El Gamal and Y.-H. Kim, Network Information Theory, Cambridge University Press, 2011.
[6] W. Gerstner and W. Kistler, Spiking Neuron Models, Cambridge University Press, 2002.
[7] C. Mead, Analog VLSI and Neural Systems, Addison-Wesley, 1989.
[8] ECE 210 – Neuromorphic Engineering and Hardware Systems, Canvas Lecture Materials and Course Notes,
University of California, Santa Cruz.

