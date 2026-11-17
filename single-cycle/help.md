# Help

## Simulating with a waveform

Two options:

**Option 1 — Makefile:**

```bash
make
```

**Option 2 — Manually:**

```bash
iverilog -g2005-sv -Wall datapath.sv control.sv instrfile.sv datafile.sv regfile.sv alu.sv cpu_tb.sv
./a.out
```

> Note: `make` runs the iverilog command and `./a.out` for you. The simulation writes `<waveform file>` — open it with Surfer.

## Assembling test programs

```bash
riscv-none-elf-gcc -c test_asm.s
riscv-none-elf-objdump -S test_asm.o
```

## Useful tools

- **Surfer** — waveform viewer for the VCD output.
- **radare2** — disassembler/debugger for inspecting compiled binaries.