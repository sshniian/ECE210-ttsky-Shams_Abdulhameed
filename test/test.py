# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    tests = [0, 1, 20, 127, 128, 255]

    for x in tests:
        dut.ui_in.value = x
        await ClockCycles(dut.clk, 1)

        expected = ((x << 1) + 10) & 0xFF
        got = int(dut.uo_out.value)

        assert got == expected, f"ui_in={x} got={got} expected={expected}"

    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
