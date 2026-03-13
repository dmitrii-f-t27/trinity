# Trinity FPGA: UART Bridge + Power Measurement Workflow

> **Unblocks Issue #128 BLOCKER #2** — CH340 USB-UART cables arrived

## Hardware Setup

### Wiring (CH340 to QMTech XC7A100T)

| FPGA Pin | Signal | CH340 Wire | Notes |
|----------|--------|-----------|-------|
| K20 | uart_tx | RX (green) | FPGA → Host |
| L20 | uart_rx | TX (white) | Host → FPGA |
| GND | GND | GND (black) | **Must connect** |
| U22 | clk | — | 50 MHz onboard |

### Mode Selection (DIP Switches)

| Mode | sw[1] sw[0] | Description | Expected W |
|------|------------|-------------|------------|
| 0 | 0 0 | IDLE (all gated) | ~0.45W |
| 1 | 0 1 | BLINK (LED only) | ~0.50W |
| 2 | 1 0 | 1-BLOCK | ~0.60W |
| 3 | 1 1 | 4-BLOCK (full pipeline) | ~0.75W |
| 4 | btn | AUTO-CYCLE (1s each) | varies |

Pin assignments: sw[0]=K21, sw[1]=J21, btn=P23

## Workflow

### Step 1: Discover Device

```bash
tri fpga uart scan
# → /dev/tty.wchusbserial10  [CH340]
```

### Step 2: Flash Firmware

```bash
tri fpga power flash
# Synthesizes power_modes.v via Docker openXC7
# Programs FPGA via JTAG (openFPGALoader)
```

### Step 3: Verify UART Link

```bash
tri fpga uart ping /dev/tty.wchusbserial10
# → ✅ PONG OK (0x83)
```

### Step 4: Measure Power

```bash
tri fpga power measure /dev/tty.wchusbserial10
# Cycles modes 0-4, reads watt values from UART
# Saves to /tmp/trinity_power_results.json
```

### Step 5: Generate Report

```bash
tri fpga power report
# Writes papers/trinity-fpga/power_results.md
```

### Step 6: Synthesis Validation (BLOCKER #1)

```bash
# Requires Docker + hdlc/ghdl:yosys
tri fpga synth-validate
# Runs all 10 targets from Makefile.validate
# Writes fpga/openxc7-synth/benchmarks/synthesis_results.md

# Or single module:
tri fpga synth-validate matvec_243x729
```

## MCP Tools (Claude Code)

After `tri serve --mcp`, these tools are available in Claude Code:

| Tool | Description |
|------|-------------|
| `fpga_uart_scan` | Discover CH340/FTDI devices |
| `fpga_uart_ping` | Verify UART link to FPGA |
| `fpga_power_flash` | Flash power_modes.v bitstream |
| `fpga_power_measure` | Collect 5-mode power data |
| `fpga_power_report` | Generate markdown table |
| `fpga_synth_validate` | Run Yosys via Docker |

## Protocol Reference

### UART Commands (115200 8-N-1)

| Byte | Command | Response |
|------|---------|----------|
| 0x03 | PING | 0x83 PONG |
| 0x00-0x04 | Set mode N | — |
| 0x0E | Query power | `W:X.XX\n` |
| 0x0F | Query mode | mode byte |
| 0xAA 0x10 lo hi | Infer token | 4-byte u32 |

Baud divisor: CLK_DIV = 27 @ 50 MHz → 115200 baud

## Expected Results for Paper

After running `measure + report`, update **Table 3** in `papers/trinity-fpga/draft.md`:

```
IDLE:    ~0.45W
BLINK:   ~0.50W (+0.05W LED)
1-BLOCK: ~0.60W (+0.15W one TrinityBlock)
4-BLOCK: ~0.75W (+0.30W full pipeline)
```

Efficiency claim: **$0.86/tok/s/W** requires real power measurement.
