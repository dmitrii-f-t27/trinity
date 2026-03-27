# Trinity Zenodo v7.3 — Docker Reproducibility

**Created:** 2026-03-27
**Version:** 7.3.0
**Status:** Complete

---

## Overview

This directory contains Dockerfiles for all 7 Trinity bundles (B001-B007) to ensure reproducible scientific computing environments as required by NeurIPS 2025+ and MLSys 2026 standards.

---

## Bundle Containers

| Bundle | Image | Description | DOI |
|--------|-------|-------------|-----|
| B001 | `trinity-b001:v7.3` | HSLM Training | 10.5281/zenodo.19227865 |
| B002 | `trinity-b002:v7.3` | FPGA Synthesis | 10.5281/zenodo.19227867 |
| B003 | `trinity-b003:v7.3` | TRI-27 ISA | 10.5281/zenodo.19227869 |
| B004 | `trinity-b004:v7.3` | Queen Lotus RL | 10.5281/zenodo.19227871 |
| B005 | `trinity-b005:v7.3` | VIBEE Compiler | 10.5281/zenodo.19227873 |
| B006 | `trinity-b006:v7.3` | Sacred Formats | 10.5281/zenodo.19227875 |
| B007 | `trinity-b007:v7.3` | VSA Library | 10.5281/zenodo.19227877 |

---

## Quick Start

### Build All Containers

```bash
cd docs/research/docker
docker-compose build
```

### Build Single Container

```bash
docker build -t trinity-b001:v7.3 -f Dockerfile.B001 ../../..
```

### Run Container

```bash
# Show help
docker run trinity-b001:v7.3 --help

# Run with volume mount
docker run -v $(pwd)/data:/src/data trinity-b001:v7.3 --train
```

---

## Individual Bundle Usage

### B001: HSLM Training

```bash
# Train HSLM-1.95M on TinyStories
docker run -v $(pwd)/data:/src/data trinity-b001:v7.3 \
  --train --dataset tinystories --steps 30000

# Export model weights
docker run trinity-b001:v7.3 --export --output model.safetensors
```

### B002: FPGA Synthesis

```bash
# Synthesize ternary circuit
docker run -v $(pwd)/fpga:/src/fpga trinity-b002:v7.3 \
  --synthesize --input circuit.v --output bitstream.bit

# Analyze resources
docker run trinity-b002:v7.3 --analyze --xc7a100t
```

### B003: TRI-27 Assembly

```bash
# Assemble .tri to bytecode
docker run -v $(pwd)/specs:/src/specs trinity-b003:v7.3 \
  --assemble program.t27 --output program.bin

# Disassemble bytecode
docker run trinity-b003:v7.3 --disassemble program.bin
```

### B004: Queen Lotus RL

```bash
# Train with calibration
docker run trinity-b004:v7.3 --train --episodes 1000 --calibrate

# Evaluate ECE/Brier Score
docker run trinity-b004:v7.3 --evaluate --metrics ece,brier
```

### B005: VIBEE Compiler

```bash
# Compile .tri to Zig
docker run -v $(pwd)/specs:/src/specs trinity-b005:v7.3 \
  compile spec.tri --target zig --output code.zig

# Compile .tri to Verilog
docker run trinity-b005:v7.3 compile spec.tri --target verilog --output circuit.v
```

### B006: Sacred Formats

```bash
# Benchmark GF16 vs TF3
docker run trinity-b006:v7.3 --benchmark --formats gf16,tf3

# Validate round-trip precision
docker run trinity-b006:v7.3 --validate --precision 1e-6
```

### B007: VSA Library

```bash
# Benchmark SIMD operations
docker run trinity-b007:v7.3 --benchmark --operations bind,bundle,cosine

# Test noise resilience
docker run trinity-b007:v7.3 --noise-test --levels 0,10,20,30
```

---

## Docker Compose

### Start All Containers

```bash
docker-compose up -d
```

### Check Status

```bash
docker-compose ps
```

### View Logs

```bash
docker-compose logs b001
docker-compose logs -f --tail=100  # Follow logs
```

### Stop All

```bash
docker-compose down
```

---

## Reproducibility Features

1. **Fixed Base Images** — Alpine 3.19, Zig 0.15.2
2. **Deterministic Builds** — Multi-stage with explicit dependencies
3. **Version Pinning** — All versions in image labels
4. **Volume Mounts** — Data/code separation
5. **Non-root User** — Security best practices

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HSLM_MODEL_SIZE` | 1.95M | HSLM parameter count |
| `HSLM_DATASET` | tinystories | Training dataset |
| `LOTUS_EPISODES` | 1000 | RL training episodes |
| `VIBEE_TARGET` | zig | Compilation target |

---

## Citation

If you use these containers in your research, please cite:

```bibtex
@software{trinity_zenodo_v7.3,
  author       = {Vasilev, Dmitrii},
  title        = {Trinity S³AI: Complete Scientific Framework v7.3},
  month        = mar,
  year         = 2026,
  publisher    = {Zenodo},
  version      = {7.3.0},
  doi          = {10.5281/zenodo.19227879},
  url          = {https://doi.org/10.5281/zenodo.19227879}
}
```

---

**φ² + 1/φ² = 3 | TRINITY**
