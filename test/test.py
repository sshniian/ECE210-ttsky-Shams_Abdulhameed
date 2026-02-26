# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_relay_selector(dut):
    clk   = dut.clk
    rst_n = dut.rst_n
    ui_in = dut.ui_in
    uo_out = dut.uo_out

    # optional signals (safe even if unused in design)
    dut.ena.value = 1
    dut.uio_in.value = 0

    cocotb.start_soon(Clock(clk, 10, units="ns").start())

    # reset
    rst_n.value = 0
    ui_in.value = 0
    await ClockCycles(clk, 5)
    rst_n.value = 1
    await ClockCycles(clk, 2)

    tests = [
        (20,  None),
        (120, None),
        (220, None),
    ]

    for a, _ in tests:
        ui_in.value = a
        await ClockCycles(clk, 200)
        got = int(uo_out.value) & 0b11
        dut._log.info(f"alpha(ui_in)={a} -> relay_sel={got:02b}")