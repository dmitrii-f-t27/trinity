# Zenodo v7.1 — Quick Start Guide

**Last Updated:** 2026-03-27
**Version:** 7.1.0

---

## 🚀 Quick Start — 3 Steps to Publish

### Step 1: Get Zenodo API Token

1. Visit: https://zenodo.org/account/settings/applications/tokens/new
2. Token Name: `Trinity v7.0 Auto-Publisher`
3. Scopes: Select both:
   - `deposit:actions` — Create and manage depositions
   - `deposit:write` — Upload files and publish
4. Click "Create"
5. **Copy the token** (you won't see it again!)

### Step 2: Set Token and Upload

```bash
# Set the token
export ZENODO_TOKEN=your_token_here

# Option A: Upload all bundles (draft mode)
python3 tools/zenodo_api_upload.py --all

# Option B: Upload and publish immediately
python3 tools/zenodo_api_upload.py --bundle B001 --publish --github-release --verify-doi
```

**What happens:**
1. Creates depositions for all bundles
2. Uploads metadata from `.zenodo.BXXX_v7.0.json`
3. Uploads descriptions from `zenodo_BXXX_enhanced_v7.0.md`
4. Uploads supplementary CSV files
5. Uploads V15 figures
6. (Optional) Publishes depositions
7. (Optional) Creates GitHub releases
8. (Optional) Verifies DOIs resolve

### Step 3: Verify

```bash
# Check all depositions status
python3 tools/zenodo_api_upload.py --list

# Check specific deposition
python3 tools/zenodo_api_upload.py --status 123456
```

---

## 📊 V15 Scientific Rigor Summary

All bundles include:

| Feature | Status |
|----------|--------|
| Dual 95%/99% Confidence Intervals | ✅ |
| Effect Size (Cohen's d) | ✅ |
| Significance Level Indicators | ✅ |
| Calibration Metrics (ECE, Brier) | ✅ |
| Bootstrap Method (10,000 resamples) | ✅ |
| NeurIPS 2025 Compliance | ✅ |

---

## 📁 File Inventory

### Core Files (8 bundles)
- `zenodo_B001_enhanced_v7.0.md` — HSLM description
- `zenodo_B002_enhanced_v7.0.md` — Zero-DSP FPGA
- `zenodo_B003_enhanced_v7.0.md` — TRI-27 ISA
- `zenodo_B004_enhanced_v7.0.md` — Queen Lotus RL
- `zenodo_B005_enhanced_v7.0.md` — VIBEE Compiler
- `zenodo_B006_enhanced_v7.0.md` — Sacred Formats
- `zenodo_B007_enhanced_v7.0.md` — VSA SIMD
- `zenodo_PARENT_enhanced_v7.0.md` — Parent Collection

### Metadata Files (8)
- `.zenodo.B001_v7.0.json` — B001 metadata
- `.zenodo.B002_v7.0.json` — B002 metadata
- `.zenodo.B003_v7.0.json` — B003 metadata
- `.zenodo.B004_v7.0.json` — B004 metadata
- `.zenodo.B005_v7.0.json` — B005 metadata
- `.zenodo.B006_v7.0.json` — B006 metadata
- `.zenodo.B007_v7.0.json` — B007 metadata
- `.zenodo.PARENT_v7.0.json` — Parent metadata

### Supplementary Materials (CSV)
- `B001_training.csv`, `B001_calibration.csv`
- `B002_fpga_resources.csv`, `B002_calibration.csv`
- `B003_registers.csv`, `B003_metrics.csv`
- `B004_calibration.csv`, `B004_sample_efficiency.csv`
- `B005_vibee_metrics.csv`
- `B006_formats.csv`
- `B007_simd_benchmarks.csv`, `B007_noise_resilience.csv`
- `PARENT_cross_bundle_summary.csv`

### V15 Figures (9)
- `cross_bundle_effect_sizes.png` — Mean Cohen's d comparison
- `calibration_summary.png` — ECE/Brier across bundles
- `B001_training_curve_v15.png` — HSLM training with 95% CI
- `B001_calibration_v15.png` — ECE/Brier reliability
- `B001_effect_size_bar.png` — Cohen's d visualization
- `B002_fpga_resources_v15.png` — DSP=0 comparison
- `B002_calibration_v15.png` — Calibration metrics
- `B007_simd_comparison_v15.png` — SIMD speedup
- `B007_noise_resilience_v15.png` — Noise resilience

---

## 🛠️ Tools

| Tool | Purpose | Command |
|------|---------|----------|
| V15 Checker | Verify V15 compliance | `python3 tools/zenodo_v15_checker.py` |
| Figure Generator | Generate V15 figures | `python3 tools/zenodo_figure_generator.py --all` |
| Benchmark Exporter | Export CSV data | `python3 tools/zenodo_export_benchmarks.py` |
| API Uploader | Upload to Zenodo | `python3 tools/zenodo_api_upload.py --all` |

---

## 🔗 Links

- **Zenodo Profile:** https://zenodo.org/account
- **Zenodo Upload:** https://zenodo.org/deposit
- **Zenodo Sandbox:** https://sandbox.zenodo.org/deposit (for testing)
- **Token Management:** https://zenodo.org/account/settings/applications/tokens/new
- **Parent DOI:** 10.5281/zenodo.19227879

---

## ⚡ Expected Timings

| Action | Time |
|---------|-------|
| Get API Token | 2 min |
| Upload single bundle | 1-2 min |
| Upload all 8 bundles | 8-16 min |
| Create GitHub releases | 2-3 min |
| Verify DOIs | 1-2 min |
| **Total (all + publish)** | ~25 minutes |

---

## 📋 Checklist Before Upload

- [ ] Zenodo account created
- [ ] API token obtained and set as ZENODO_TOKEN
- [ ] V15 checker passes: `python3 tools/zenodo_v15_checker.py`
- [ ] Figures generated: `python3 tools/zenodo_figure_generator.py --all`
- [ ] CSV data exported: `python3 tools/zenodo_export_benchmarks.py`
- [ ] Git push done: `git push`

---

**φ² + 1/φ² = 3 | TRINITY v7.0 Ready to Publish**
