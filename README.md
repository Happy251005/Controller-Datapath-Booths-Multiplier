# Booth's Algorithm 16×16 Signed Multiplier (Verilog)

A 16-bit × 16-bit signed multiplier implemented in Verilog using the
radix-2 (one-bit-at-a-time) Booth's algorithm, built as a classic
controller–datapath design: a Moore FSM (`control.v`) drives a separate
datapath (`datapath.v`) made of shift registers, an ALU, a down-counter,
and a single-bit history flip-flop.

## Algorithm

Each iteration inspects the current LSB of the multiplier (`Q0`) together
with the bit that was in that position on the previous iteration
(`Qm1`, held in a dedicated flip-flop):

| Q0 Qm1 | Action on A       |
|--------|-------------------|
| 0 1    | A ← A + M         |
| 1 0    | A ← A − M         |
| 0 0    | A unchanged       |
| 1 1    | A unchanged       |

After the add/subtract decision, the combined register `{A, Q}` is
arithmetic-shifted right by one bit (sign bit of `A` re-inserted at the
top, so negative operands are handled correctly), and `Qm1` captures the
bit that just shifted out of `Q0`. This repeats for all 16 bits of the
multiplier; the final 32-bit signed product is `{A, Q}`.

## Files

| File            | Role                                                              |
|-----------------|-------------------------------------------------------------------|
| `top.v`         | Top-level: wires the controller to the datapath, exposes `Z`/`done` |
| `control.v`     | FSM (states `S0`–`S5`) generating all datapath control signals    |
| `datapath.v`    | Instantiates and connects the datapath building blocks below      |
| `alu.v`         | Combinational adder/subtractor (`A ± M`)                          |
| `shiftreg.v`    | 16-bit load/shift/clear register (used for both `A` and `Q`)      |
| `pipo.v`        | 16-bit parallel-in/parallel-out register (holds the multiplicand `M`) |
| `dff.v`         | Single-bit register (holds `Qm1`, the Booth recoding history bit) |
| `cntr.v`        | 5-bit down-counter, tracks remaining iterations                   |

## FSM states

| State | Action                                                        |
|-------|----------------------------------------------------------------|
| `S0`  | Idle — waits for `start`                                       |
| `S1`  | Clear `A`, load `M` from `data_in`, load counter to 16, clear `Qm1` |
| `S2`  | Load `Q` from `data_in`, clear `Qm1`                           |
| `S3`  | Inspect `{Q0, Qm1}`, conditionally add/subtract `M` into `A`   |
| `S4`  | Arithmetic-shift `{A, Q}` right, decrement counter, loop to `S3` |
| `S5`  | Assert `done`, hold product on `Z` until `rst`                 |

## Interface

```
top(
    input        start,
    input        clk,
    input        rst,
    input  [15:0] data_in,
    output [31:0] Z,
    output       done
);
```

Both operands are loaded serially over the single 16-bit `data_in` bus,
sequenced by the FSM:

1. Assert `start` for at least one clock while in the idle state (`S0`).
2. On the following clock (state `S1`), present the **multiplicand**
   on `data_in` — it is captured into `M` on that clock edge.
3. On the next clock (state `S2`), present the **multiplier** on
   `data_in` — it is captured into `Q` on that clock edge.
4. The FSM then runs 16 add/shift iterations autonomously; no further
   input is required.
5. When `done` goes high, `Z = {A, Q}` holds the 32-bit signed product
   and remains stable until `rst` is asserted.

## Latency

From the multiplicand load (`S1`) to `done` asserting (`S5`) takes
1 (`S1`) + 1 (`S2`) + 16 × 2 (`S3`/`S4` per bit) = **34 clock cycles**.

## Future work

- Radix-4 (modified Booth) recoding to roughly halve the iteration count
- Parameterizable operand width (currently fixed at 16×16)
- Pipelined or fully-combinational variants for throughput comparison
