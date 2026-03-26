# Trinity Zenodo v7.0 Supplementary Data

**Generated:** 2026-03-27
**Files:** 21 CSV files
**Purpose:** V15 Scientific Rigor benchmark data

## V7.0 Enhanced Files (New)

| File | Bundle | Description | V15 Features |
|-------|---------|-------------|--------------|
| B001_calibration.csv | B001 | ECE, Brier Score with 95% CI | Calibration metrics |
| B002_calibration.csv | B002 | ECE, Brier Score with 95% CI | Calibration metrics |
| B002_fpga_resources.csv | B002 | DSP, LUT, FF, BRAM, Power | d=3.2 (Very Large) |
| B003_metrics.csv | B003 | Code density, instruction count | d=1.5 (Very Large) |
| B003_registers.csv | B003 | 3-bank layout (Alpha/Iota/Sigma) | TRI-27 spec |
| B004_calibration.csv | B004 | ECE, Brier Score (best: 0.068) | NeurIPS compliant |
| B004_sample_efficiency.csv | B004 | Sample efficiency, episodes | d=2.3 (Very Large) |
| B005_vibee_metrics.csv | B005 | Parse speedup, code size | d=1.5 (Very Large) |
| B006_formats.csv | B006 | FP32, BF16, GF16, TF3 | d=2.6 (Very Large) |
| B007_simd_benchmarks.csv | B007 | 6 operations (bind, unbind...) | d=3.2 (Very Large) |
| B007_noise_resilience.csv | B007 | Noise levels 0-50% | 94.8% at 30% noise |
| PARENT_cross_bundle_summary.csv | PARENT | Mean d, ECE, Brier | Cross-bundle analysis |

## Legacy v6.1 Files

| File | Bundle | Description | Rows |
|-------|---------|-------------|-------|
| B001_training.csv | B001 | HSLM training curve with 95% CI | 7 |
| B002_fpga_synthesis.csv | B002 | FPGA resource utilization | 5 |
| B003_tri27_registers.csv | B003 | TRI-27 register file layout | 27 |
| B004_lotus_cycle.csv | B004 | Queen Lotus episode data | 847 |
| B005_language_features.csv | B005 | Tri language feature analysis | 23 |
| B005_productivity.csv | B005 | Development productivity metrics | 3 |
| B006_gf16_accuracy.csv | B006 | GF16 accuracy benchmarks | 4 |
| B006_roundtrip_precision.csv | B006 | Round-trip precision test | 4 |
| B007_noise_resilience.csv | B007 | VSA noise tolerance (legacy) | 5 |
| B007_simd_benchmarks.csv | B007 | SIMD speedup (legacy) | 4 |

## Usage

```python
import pandas as pd

# Load training data
df_train = pd.read_csv('B001_training.csv')
print(df_train.describe())

# Load FPGA synthesis results
df_fpga = pd.read_csv('B002_fpga_synthesis.csv')
print(df_fpga)

# Load SIMD benchmarks
df_simd = pd.read_csv('B007_simd_benchmarks.csv')
print(f"Average speedup: {df_simd['speedup'].mean():.1f}x")
```

## V15 Scientific Rigor Features

All v7.0 datasets include:
- **Effect Size:** Cohen's d values (Very Large: d >= 1.2)
- **Confidence Intervals:** 95% bootstrap (10,000 resamples)
- **Calibration:** ECE < 0.12, Brier < 0.25 (NeurIPS 2025)
- **Cross-Bundle:** Mean d = 2.4 (Very Large)

## Usage

```python
import pandas as pd

# Load training data
df_train = pd.read_csv('B001_training.csv')
print(df_train.describe())

# Load calibration metrics
df_cal = pd.read_csv('B001_calibration.csv')
print(f"ECE: {df_cal['value'][0]:.3f} (target < 0.12)")

# Load FPGA synthesis results
df_fpga = pd.read_csv('B002_fpga_resources.csv')
print(df_fpga)

# Load SIMD benchmarks
df_simd = pd.read_csv('B007_simd_benchmarks.csv')
print(f"Average speedup: {df_simd['speedup_x'].mean():.1f}x")
```

## Citation

If you use this data, please cite:

```bibtex
@misc{vasilev2026trinity_data_v7,
  title={Trinity Zenodo v7.0 Supplementary Data with V15 Scientific Rigor},
  author={Vasilev, Dmitrii},
  year={2026},
  month={March},
  version={7.0.0},
  doi={10.5281/zenodo.19227879},  # Parent DOI
  url={https://doi.org/10.5281/zenodo.19227879}
}
```

φ² + 1/φ² = 3 | TRINITY
