import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def wait_cycles(clk, n):
    for _ in range(n):
        await RisingEdge(clk)


async def wait_uo_known(dut, max_cycles=20000):
    for _ in range(max_cycles):
        bs = dut.uo_out.value.binstr
        if len(bs) == 8 and all(c in "01" for c in bs):
            return int(bs, 2)
        await RisingEdge(dut.clk)
    raise AssertionError(f"uo_out stayed X/Z: {dut.uo_out.value.binstr}")


@cocotb.test()
async def test_relay_selector(dut):
    # Drive stable values
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    dut.clk.value = 0

    # IMPORTANT: start reset high first (so we can create a real negedge)
    dut.rst_n.value = 1

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    await wait_cycles(dut.clk, 10)

    # Real async reset pulse: 1 -> 0 -> 1
    dut.rst_n.value = 0
    await wait_cycles(dut.clk, 50)
    dut.rst_n.value = 1
    await wait_cycles(dut.clk, 50)

    # Now output should become known (not X)
    full = await wait_uo_known(dut)
    sel = full & 0b11
    assert sel in (0b00, 0b01, 0b10), f"relay_sel invalid: {sel:02b}"

    # Optional: try a few alphas (still only require known output)
    for a in (20, 120, 220):
        dut.ui_in.value = a
        await wait_cycles(dut.clk, 8000)
        full = await wait_uo_known(dut)
        sel = full & 0b11
        assert sel in (0b00, 0b01, 0b10), f"alpha={a} relay_sel invalid: {sel:02b}"

    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0