import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def wait_cycles(clk, n):
    for _ in range(n):
        await RisingEdge(clk)


async def read_clean_sel(dut, max_cycles=8000):
    # Read full uo_out, then mask [1:0]
    for _ in range(max_cycles):
        bs = dut.uo_out.value.binstr
        if len(bs) == 8 and all(c in "01" for c in bs):
            full = int(bs, 2)
            return full & 0b11
        await RisingEdge(dut.clk)
    raise AssertionError(f"uo_out stayed X/Z: {dut.uo_out.value.binstr}")


@cocotb.test()
async def test_relay_selector(dut):

    # --- IMPORTANT for gate-level: set inputs + reset BEFORE starting the clock ---
    dut.clk.value = 0
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    dut.rst_n.value = 0

    # Start clock AFTER signals are stable
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Hold reset long enough (gate-level needs more)
    await wait_cycles(dut.clk, 20)
    dut.rst_n.value = 1
    await wait_cycles(dut.clk, 20)

    cocotb.log.info("Starting LIF relay selector sim...")

    tests = [
        (20,  0b00),  # AF
        (120, 0b10),  # CF
        (220, 0b01),  # DF
    ]

    for a, expected in tests:
        dut.ui_in.value = a
        await wait_cycles(dut.clk, 3000)  # more time for gate-level integrate/spike

        got = await read_clean_sel(dut)
        dut._log.info(f"alpha(ui_in)={a} -> relay_sel={got:02b}")

        assert got == expected, f"alpha={a} got={got:02b} expected={expected:02b}"

    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0