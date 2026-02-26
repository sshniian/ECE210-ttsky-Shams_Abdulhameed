<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a Sequential Leaky Winner-Take-All (WTA) relay selector
in digital hardware.

The circuit receives an 8-bit input ALPHA[7:0] representing a power allocation
or operating point derived from prior software simulations (AF / DF / CF
comparison in cooperative wireless networks).

Internally, the design contains three competing accumulators (neurons):
- AF neuron
- DF neuron
- CF neuron

Each neuron:
1. Integrates (adds) a weighted contribution derived from ALPHA
2. Applies a small leak (state decay)
3. Compares its internal state to a threshold

When one neuron crosses threshold first, it becomes the winner.
A Winner-Take-All logic block encodes the selected strategy as:

- 00 → AF
- 01 → DF
- 10 → CF

The implementation uses only simple digital arithmetic
(adders, subtractors, registers, comparators), making it suitable
for low-power hardware realization.

This hardware module represents the decision layer of a larger
relay-selection framework originally simulated in software.

## How to test

1. From the repository root directory, enter the test folder:

   cd test

2. Run the simulation:

   make

The testbench applies multiple ALPHA values and observes the
RELAY_SEL[1:0] output.

Expected behavior:
- Low ALPHA → AF (00)
- Medium ALPHA → DF (01)
- High ALPHA → CF (10)

Simulation output is printed in the terminal and a results.xml file
is generated for CI validation.

## External hardware

No external hardware is required.
The design is fully self-contained and uses only Tiny Tapeout
digital input and output pins.
