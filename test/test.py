import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def wait_cycles(clk, n):
    for _ in range(n):
        await RisingEdge(clk)
def bits_known_01(bitstr: str) -> bool:
    return bitstr is not None and all(c in "01" for c in bitstr)

async def wait_uo_known(dut, max_cycles=200000):
    """Wait until uo_out becomes fully known (8 bits of only 0/1)."""
    for _ in range(max_cycles):
        bs = str(dut.uo_out.value)  # avoids deprecated .binstr
        if len(bs) == 8 and bits_known_01(bs):
            return int(bs, 2)
        await RisingEdge(dut.clk)
    raise AssertionError(f"uo_out stayed X/Z: {str(dut.uo_out.value)}")

def decode_sel(sel):
    mapping = {
        0b00: "AF",
        0b01: "DF",
        0b10: "CF",
    }
    return mapping.get(sel, "INVALID")
@cocotb.test()
async def test_relay_selector(dut):
    dut._log.info("Starting Relay Selector Test")
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    dut.clk.value = 0
    dut.rst_n.value = 1

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    await wait_cycles(dut.clk, 10)
    
    dut._log.info("Applying reset pulse...")
    dut.rst_n.value = 0
    await wait_cycles(dut.clk, 50)
    dut.rst_n.value = 1
    await wait_cycles(dut.clk, 50)

    full = await wait_uo_known(dut)
    sel = full & 0b11

    dut._log.info(f"After reset -> relay_sel={sel:02b} ({decode_sel(sel)})")
    assert sel in (0b00, 0b01, 0b10), (
        f"Invalid relay_sel after reset: {sel:02b}"
    )
   
    for a in (20, 120, 220):
        dut.ui_in.value = a
        dut._log.info(f"Testing alpha = {a}")

        # Give the design time to update (gate-level can be slow)
        await wait_cycles(dut.clk, 20000)

        full = await wait_uo_known(dut)
        sel = full & 0b11

        dut._log.info(f"alpha={a:3d} -> relay_sel={sel:02b} ({decode_sel(sel)})")
        assert sel in (0b00, 0b01, 0b10), (
            f"alpha={a} relay_sel invalid: {sel:02b}"
        )
    
    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0

    dut._log.info("Relay Selector Test Completed Successfully")