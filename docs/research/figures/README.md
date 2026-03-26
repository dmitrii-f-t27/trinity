# Trinity Zenodo v7.0 Figures

**Generated:** 2026-03-27
**Status:** V15 Scientific Rigor Compliant
**Format:** PNG (300 DPI), SVG

---

## Overview

This directory contains publication-quality figures for Trinity Zenodo bundles (B001-B007) with V15 Scientific Rigor features:

- **Effect Size Visualizations** — Cohen's d bar charts with significance emojis
- **Confidence Interval Plots** — Dual 95%/99% CI with bootstrap validation
- **Calibration Metrics** — ECE and Brier Score comparisons across bundles
- **Cross-Bundle Analysis** — Aggregate effect size and calibration summary

---

## Generating Figures

### Prerequisites

```bash
# Install Python dependencies
pip install matplotlib numpy
```

### Generate All Figures

```bash
# Generate figures for all bundles
python3 tools/zenodo_figure_generator.py --all

# Or using tri CLI (if available)
tri zenodo generate-figures
```

---

## V15 Scientific Rigor Features

### Significance Indicators

| Emoji | Level | p-value threshold |
|--------|-------|-------------------|
| 🌟 | very_strict | p < 0.001 |
| ✅ | strict | p < 0.01 |
| 🔶 | moderate | p < 0.05 |
| 🔸 | lenient | p < 0.10 |
| ❌ | not_significant | p ≥ 0.10 |

### Effect Size (Cohen's d)

| Size | Range | Emoji |
|------|-------|-------|
| Very Large | d ≥ 1.2 | 🌟 |
| Large | 0.8 ≤ d < 1.2 | 🟡 |
| Medium | 0.5 ≤ d < 0.8 | 🟢 |
| Small | 0.2 ≤ d < 0.5 | 🔵 |
| Negligible | d < 0.2 | ⚪ |

### Calibration Metrics (NeurIPS 2025)

- **ECE (Expected Calibration Error):** Target < 0.12
- **Brier Score:** Target < 0.25
- **Confidence Intervals:** 95% and 99% via bootstrap (10,000 resamples)

---

## Figure Inventory

### B001: HSLM Training & Formats (2 figures)
- **B001-Fig1_training_curve**: Training curve with 95% CI (30K steps, PPL 125.3)
- **B001-Fig2_format_comparison**: Memory vs quality trade-off (FP32/BF16/GF16/TF3)

### B002: FPGA Zero-DSP Implementation (2 figures)
- **B002-Fig1_fpga_resources**: Resource comparison (LUT/DSP/FF/BRAM) - 0 DSP
- **B002-Fig2_power_analysis**: Power efficiency (0.8W vs 2.8W FP32)

### B003: TRI-27 Register File (1 figure)
- **B003-Fig1_register_layout**: 3-bank layout (Alpha/Iota/Sigma, 27 registers)

### B004: Queen Lotus Cycle (1 figure)
- **B004-Fig1_lotus_cycle**: 6-phase state machine (DIAGNOSE → PLAN → ACT → VERIFY → MEASURE → PERSIST)

### B005: Tri Language Type System (1 figure)
- **B005-Fig1_type_hierarchy**: Linear types + Effects + Pattern Matching

### B006: GF16/TF3 φ-Optimal Formats (2 figures)
- **B006-Fig1_gf16_layout**: Bit layout comparison (Sign/Exponent/Mantissa)
- **B006-Fig2_phi_heatmap**: φ-distance heatmap (GF16/TF3 marked as optimal)

### B007: VSA SIMD Architecture (2 figures)
- **B007-Fig1_vsa_structure**: HybridBigInt SIMD layout (32 limbs × 16 trits)
- **B007-Fig2_simd_speedup**: Performance comparison (17.2× average speedup)

## Specifications

- **Format**: PNG (300 DPI) + SVG (vector)
- **Color Scheme**: Trinity Gold (#D4AF37), Cyan, Magenta, etc.
- **Style**: Seaborn darkgrid, accessible
- **Dimensions**: 10-14" × 5-7" (variable)

## Generation

```bash
cd docs/research/figures
python3 generate_all_figures.py
```

φ² + 1/φ² = 3 | TRINITY
