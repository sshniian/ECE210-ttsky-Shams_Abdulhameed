# Sequential Leaky Integrate-and-Fire Relay Selector

## Project Overview

This project implements a brain-inspired hardware decision module that selects the optimal relay strategy (AF, DF, or CF) based on power allocation (alpha).

The design is inspired by Leaky Integrate-and-Fire (LIF) neurons combined with a Winner-Take-All (WTA) selection mechanism. Instead of using complex arithmetic or continuous optimization, the circuit performs lightweight fixed-point accumulation and threshold comparison to make a low-power decision.

## Problem Statement

In cooperative wireless communication systems, multiple relay strategies exist:
- Amplify-and-Forward (AF)
- Decode-and-Forward (DF)
- Compress-and-Forward (CF)

Based on simulation results from prior software analysis, different power allocation values favor different relay strategies. This project translates that decision logic into a hardware-efficient neuromorphic circuit.

## System Architecture

Input:
- 8-bit alpha value representing power allocation

Processing:
- Three LIF neuron blocks (AF, DF, CF)
- Each neuron integrates weighted alpha
- Leak mechanism prevents unlimited growth
- Threshold detection determines activation

Decision:
- Winner-Take-All logic selects the first neuron crossing threshold

Output:
- 2-bit relay_sel signal
    - 00 = AF
    - 01 = DF
    - 10 = CF

## Design Motivation

The objective is to demonstrate how brain-inspired circuits can perform decision-making using:
- Fixed-point arithmetic
- Minimal logic resources
- Threshold-based early decision
- No multipliers or floating-point operations

This reduces hardware complexity and power consumption compared to conventional digital computation.

## Simulation and Verification

The design was verified using RTL simulation.

Test cases include:
- Low alpha → AF selected
- Mid alpha → DF selected
- High alpha → CF selected

Waveforms confirm correct relay selection behavior.

## Future Improvements

- Incorporate SNR as additional input
- Replace fixed weights with LUT derived from BER dataset
- Add adaptive threshold scaling