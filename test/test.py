import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def wait_cycles(clk, n):
    for _ in range(n):
        await RisingEdge(clk)


async def read_clean_sel(dut, max_cycles=4000):
    # Read full uo_out, then mask [1:0] (Icarus slice not supported)
    for _ in range(max_cycles):
        bs = dut.uo_out.value.binstr  # should be 8 bits
        if len(bs) == 8 and all(c in "01" for c in bs):
            full = int(bs, 2)
            return full & 0b11
        await RisingEdge(dut.clk)
    raise AssertionError(f"uo_out stayed X/Z: {dut.uo_out.value.binstr}")


@cocotb.test()
async def test_relay_selector(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Drive inputs
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0

    # Reset
    dut.rst_n.value = 0
    await wait_cycles(dut.clk, 5)
    dut.rst_n.value = 1
    await wait_cycles(dut.clk, 5)

    cocotb.log.info("Starting LIF relay selector sim...")

    tests = [
        (20,  0b00),
        (120, 0b10),
        (220, 0b01),
    ]

    for a, expected in tests:
        dut.ui_in.value = a
        await wait_cycles(dut.clk, 1200)  # plenty of time to integrate/spike

        got = await read_clean_sel(dut)
        dut._log.info(f"alpha(ui_in)={a} -> relay_sel={got:02b}")

        assert got == expected, f"alpha={a} got={got:02b} expected={expected:02b}"

    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0