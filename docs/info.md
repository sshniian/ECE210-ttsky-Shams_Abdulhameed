<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a Sequential Leaky Integrate-and-Fire (LIF) 
Winner-Take-All (WTA) relay selector in digital hardware.

The circuit receives an 8-bit input ALPHA[7:0] representing a power
allocation parameter derived from prior cooperative communication
simulations.

Internally, the design contains three competing LIF neurons:

- AF neuron (Amplify-and-Forward)
- DF neuron (Decode-and-Forward)
- CF neuron (Compress-and-Forward)

Each neuron updates its membrane voltage according to a discrete-time
LIF equation:

    V_k(t+1) = max(0, V_k(t) + I_k(ALPHA) - LEAK)

where:
- V_k is the internal state register
- I_k(ALPHA) is an ALPHA-dependent current
- LEAK is a small decay constant

The three current functions are:

- AF:  I_AF = 255 - ALPHA
- DF:  I_DF = 2 × ALPHA
- CF:  I_CF = C - |ALPHA - 128|

This creates natural competition between the three relay strategies.

When any neuron satisfies:

    V_k ≥ THRESHOLD

a Winner-Take-All comparison selects the neuron with the highest
membrane voltage and resets all states.

The selected relay is encoded on the output:

- 00 → AF
- 01 → DF
- 10 → CF

The architecture uses only:
- Registers
- Adders
- Subtractors
- Comparators

No multipliers or floating-point operations are used, making the design
area- and power-efficient.

This module represents the decision layer of a larger relay-selection
framework originally evaluated through Monte Carlo BER simulations.

## How to test

From the repository root directory:

    cd test
    make

The cocotb testbench performs the following:

- Applies a reset pulse
- Drives multiple ALPHA values
- Waits for the sequential LIF integration to settle
- Reads the relay selection from uo_out[1:0]

Example expected behavior:

- ALPHA = 20  → AF (00)
- ALPHA = 120 → CF (10)
- ALPHA = 220 → DF (01)

Simulation results are printed in the terminal.
A results.xml file is generated for CI validation.
Waveforms are written to waves.vcd for inspection.

## External hardware

No external hardware is required.
The design uses only Tiny Tapeout digital IO:

- ui_in[7:0]  → ALPHA input
- uo_out[1:0] → Relay selection output
The design is fully self-contained and uses only Tiny Tapeout
digital input and output pins.
All computation is performed internally using synchronous logic.