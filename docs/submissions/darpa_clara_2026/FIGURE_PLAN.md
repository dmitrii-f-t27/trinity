# DARPA CLARA Proposal — Figure Plan v6.2

**Purpose:** Scientific figure specifications for DARPA CLARA proposal submission
**Figure Style:** NeurIPS/ICLR conference standard (high contrast, clear labels)

---

## Figure Overview

| Figure | Type | Purpose | Location |
|--------|------|---------|----------|
| F1 | System Architecture | High-level Trinity S³AI overview | Executive Summary |
| F2 | Ternary vs Binary | Model size and accuracy comparison | Technical Narrative |
| F3 | Calibration Metrics | ECE reliability diagrams | Technical Narrative |
| F4 | FPGA Resources | DSP/LUT utilization comparison | Technical Narrative |
| F5 | VSA Operations | Bind/unbind/bundle visualization | Technical Narrative |
| F6 | Project Timeline | 24-month Gantt chart | Work Plan |
| F7 | Bundle Overview | 7 Trinity S³AI bundles | Technical Narrative |
| F8 | Risk Reduction | Before/after calibration | Risks Document |

---

## Figure 1: System Architecture

**Type:** Block diagram
**Size:** Full-width (3.5" × 2.5")
**Style:** Clean rectangles with arrows

```
┌─────────────────────────────────────────────────────────────────┐
│                    Trinity S³AI Framework                      │
├─────────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ Ternary NN   │  │ VSA Runtime  │  │ TRI-27 ISA   │    │
│  │  (B001)      │  │  (B007)      │  │  (B003)      │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                 │               │
│         └─────────────────┴─────────────────┘               │
│                          │                                  │
│                   ┌──────▼────────┐                         │
│                   │ Zero-DSP FPGA │                         │
│                   │   (B002)      │                         │
│                   └──────┬────────┘                         │
│                          │                                  │
│                   ┌──────▼────────┐                         │
│                   │ Queen Lotus   │                         │
│                   │   (B004)      │                         │
│                   └───────────────┘                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Supporting Layer                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │ VIBEE Comp   │  │ Sacred       │  │ Calibration  │    │
│  │  (B005)      │  │ Formats (B006)│  │  Metrics     │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

**Labels:**
- Title: "Figure 1: Trinity S³AI Framework Architecture"
- Legend: 7 bundles color-coded
- Annotations: Key data flow arrows

**File Naming:** `figures/fig1_system_architecture.pdf`

---

## Figure 2: Ternary vs Binary Comparison

**Type:** Bar chart
**Size:** Full-width (3.5" × 2")
**Data:**

| Model | FP32 Size | Binary | Ternary (Trinity) | Accuracy |
|-------|-----------|--------|-------------------|----------|
| HSLM-1.95M | 7.6 MB | 3.8 MB | **0.385 MB** | 122.3 PPL |

**Layout:**
- Left: Bar chart (log scale) — Model size comparison
- Right: Scatter — Size vs Accuracy trade-off
- Annotations: "19.7× compression", "<5% accuracy loss"

**File Naming:** `figures/fig2_ternary_comparison.pdf`

---

## Figure 3: Calibration Metrics (Reliability Diagrams)

**Type:** Multi-panel figure (2×4 subplots)
**Size:** Full-width (3.5" × 3")
**Panels:**

| Panel | Bundle | ECE | Brier Score |
|-------|--------|-----|-------------|
| (a) | B001 (HSLM) | 0.084 | 0.234 |
| (b) | B002 (FPGA) | 0.092 | 0.241 |
| (c) | B003 (TRI-27) | 0.115 | 0.248 |
| (d) | B004 (Queen) | 0.108 | 0.239 |
| (e) | B005 (VIBEE) | 0.065 | 0.178 |
| (f) | B006 (Sacred) | 0.071 | 0.189 |
| (g) | B007 (VSA) | 0.065 | 0.175 |
| (h) | NeurIPS Threshold | 0.12 | 0.25 |

**Subplot Format:**
- X-axis: Predicted confidence (0-1, 10 bins)
- Y-axis: Observed accuracy (0-1)
- Diagonal line: Perfect calibration (y=x)
- Histogram bars: Prediction distribution

**Annotations:**
- ECE value in each panel
- Color-coded: Green (ECE < 0.07), Yellow (0.07-0.10), Orange (>0.10)

**File Naming:** `figures/fig3_calibration_reliability.pdf`

---

## Figure 4: FPGA Resource Utilization

**Type:** Grouped bar chart
**Size:** Half-width (1.75" × 2")
**Data:**

| System | LUT (%) | DSP (%) | Power (W) |
|---------|----------|---------|-----------|
| Standard GPU | N/A | 100% | 12.0 |
| Standard FPGA | 65% | 45% | 8.5 |
| Trinity Zero-DSP | 19.6% | **0%** | 1.2 |

**Layout:**
- Left panel: LUT utilization (bars)
- Middle panel: DSP usage (bars) — Trinity = 0 highlighted
- Right panel: Power consumption (bars)

**Annotations:**
- "100% DSP reduction"
- "5× power efficiency"
- "19.6% LUT utilization"

**File Naming:** `figures/fig4_fpga_resources.pdf`

---

## Figure 5: VSA Operations Visualization

**Type:** Flow diagram
**Size:** Full-width (3.5" × 2")
**Operations:**

```
┌──────────┐         ┌──────────┐
│  Value A  │         │  Value B  │
└────┬─────┘         └────┬─────┘
     │                   │
     └───────┬───────────┘
             │
        ┌────▼────┐
        │  BIND   │  →  Bound Vector
        └─────────┘

┌──────────────────────┐
│  Bound Vector       │
└──────┬─────────────┘
       │
  ┌────▼────────┐
  │  UNBIND     │  →  Retrieved A
  │  (with B)   │
  └─────────────┘

┌──────────┐  ┌──────────┐
│  Value A  │  │  Value B  │
└────┬─────┘  └────┬─────┘
     │            │
     └─────┬──────┘
           │
      ┌────▼────┐
      │ BUNDLE  │  →  Majority Vote
      └─────────┘
```

**Annotations:**
- O(1) complexity label
- Self-inverting property: bind(bind(a,b),b) = a
- Cosine similarity metric

**File Naming:** `figures/fig5_vsa_operations.pdf`

---

## Figure 6: Project Timeline (Gantt Chart)

**Type:** Gantt chart
**Size:** Full-width (3.5" × 2.5")
**Phases:**

| Phase | Duration | Milestones |
|-------|----------|------------|
| P1: Foundation | M1-M6 | M1, M2, M3, M3.5 |
| P2: High-Assurance | M7-M12 | M4, M5, M6 |
| P3: Compositional | M13-M18 | M7, M8, M9 |
| P4: Transition | M19-M24 | M10, M11, M12 |

**Annotations:**
- M3.5: Calibration Infrastructure (Month 7)
- Deliverables at each phase end
- Risk checkpoints

**File Naming:** `figures/fig6_timeline_gantt.pdf`

---

## Figure 7: Bundle Overview (7 Bundles)

**Type:** Grid layout (3×3)
**Size:** Full-width (3.5" × 3")
**Bundles:**

| Cell | Bundle | Key Metric |
|------|--------|------------|
| 1 | B001: HSLM | 1.95M params, 385 KB |
| 2 | B002: FPGA | 0% DSP, 1.2W |
| 3 | B003: TRI-27 | 36 opcodes, 27 regs |
| 4 | B004: Queen | RL Q-values, 5-cycle |
| 5 | B005: VIBEE | Compiler, tri→verilog |
| 6 | B006: Sacred | GF16, TF3, φ-math |
| 7 | B007: VSA | 10K-dim, FHRR |
| 8 | Calibration | ECE < 0.12, Brier < 0.25 |
| 9 | Integration | End-to-end pipeline |

**Style:**
- Each cell: Icon + Name + 1 key metric
- Color-coded by type: NN (blue), HW (green), SW (orange), ML (purple)

**File Naming:** `figures/fig7_bundle_grid.pdf`

---

## Figure 8: Risk Reduction Visualization

**Type:** Before/After comparison
**Size:** Half-width (1.75" × 2")
**Data:**

| Risk | Before | After | Reduction |
|------|--------|-------|-----------|
| Uncertainty without safety | HIGH | LOW | 67% |
| Overconfident predictions | HIGH | LOW | 67% |
| Unreliable thresholds | MEDIUM | LOW | 33% |

**Layout:**
- Left panel: Risk level before calibration (color-coded: Red=HIGH, Yellow=MEDIUM)
- Right panel: Risk level after calibration (color-coded: Green=LOW)
- Arrows showing reduction with percentages

**File Naming:** `figures/fig8_risk_reduction.pdf`

---

## Figure Specifications Summary

| Figure | Type | Width | Height | DPI | File Type |
|--------|------|-------|--------|-----|----------|
| F1 | Block diagram | 3.5" | 2.5" | 300 | PDF |
| F2 | Bar chart | 3.5" | 2.0" | 300 | PDF |
| F3 | 8-panel | 3.5" | 3.0" | 300 | PDF |
| F4 | Grouped bar | 1.75" | 2.0" | 300 | PDF |
| F5 | Flow diagram | 3.5" | 2.0" | 300 | PDF |
| F6 | Gantt | 3.5" | 2.5" | 300 | PDF |
| F7 | Grid (3×3) | 3.5" | 3.0" | 300 | PDF |
| F8 | Comparison | 1.75" | 2.0" | 300 | PDF |

---

## Styling Guidelines

### Color Palette

- **Primary (Trinity Blue):** #2563EB
- **Success (Green):** #10B981
- **Warning (Yellow):** #F59E0B
- **Error (Red):** #EF4444
- **Neutral (Gray):** #6B7280

### Typography

- **Title:** 14pt Bold, sans-serif
- **Labels:** 10pt Regular, sans-serif
- **Axis labels:** 9pt Regular, sans-serif
- **Legend:** 8pt Regular, sans-serif

### Accessibility

- Minimum 4.5:1 contrast ratio for all text
- Color-blind friendly palette (avoid red-green alone)
- High-contrast lines (≥2px width)

---

## Generation Tools

**Recommended:**
- Matplotlib (Python) — Standard scientific plotting
- Inkscape — Vector graphics editing
- TikZ (LaTeX) — For architectural diagrams

**Alternative:**
- Graphviz — For flow diagrams
- Draw.io — Quick drafting
- Canva — Layout planning

---

**Document Control:** CLARA-FIG-001
**Version:** 6.2
**Status:** Specification ready for figure generation
