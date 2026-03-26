# Zenodo v7.0 Manual Upload Guide

**Date:** 2026-03-27
**Version:** 7.0.0
**Bundles:** B001-B007 + PARENT (8 total)

---

## Overview

This guide provides step-by-step instructions for uploading Trinity v7.0 bundles to Zenodo with V15 Scientific Rigor compliance.

---

## Prerequisites

1. **Zenodo Account:** https://zenodo.org/signup
2. **GitHub Account:** For linking repository
3. **ORCID:** https://orcid.org (recommended for author attribution)
4. **Files Ready:** All enhanced descriptions and metadata JSON files

---

## Upload Order

**Upload PARENT collection LAST** — it requires DOIs from all bundles.

### Order: B001 → B002 → B003 → B004 → B005 → B006 → B007 → PARENT

---

## Step-by-Step Upload (Per Bundle)

### 1. Access Zenodo Upload

1. Visit: https://zenodo.org/deposit
2. Click "New upload"
3. Select "Upload new files"

### 2. Upload Description File

1. Browse to: `docs/research/`
2. Select: `zenodo_B001_enhanced_v7.0.md`
3. Click "Start upload"

**File Mapping:**

| Bundle | File to Upload |
|--------|----------------|
| B001 | `zenodo_B001_enhanced_v7.0.md` |
| B002 | `zenodo_B002_enhanced_v7.0.md` |
| B003 | `zenodo_B003_enhanced_v7.0.md` |
| B004 | `zenodo_B004_enhanced_v7.0.md` |
| B005 | `zenodo_B005_enhanced_v7.0.md` |
| B006 | `zenodo_B006_enhanced_v7.0.md` |
| B007 | `zenodo_B007_enhanced_v7.0.md` |
| PARENT | `zenodo_PARENT_enhanced_v7.0.md` |

### 3. Fill Metadata (from .zenodo.json)

Open the corresponding JSON file: `docs/research/.zenodo.BXXX_v7.0.json`

#### 3.1 Basic Information

**Upload Type:** Publication
**Publication Type:** Article

**Title:** (from JSON, e.g., "Trinity B001: HSLM - Hyper-Sparse Language Model with Calibrated Uncertainty Quantification v7.0")

**Authors:** (from creators array)
- Name: Vasilev, Dmitrii
- Affiliation: Trinity Research Collective
- ORCID: (add if available)

#### 3.2 Description

Copy the content from the enhanced markdown file into the description field.

#### 3.3 Keywords

**Keywords:** (from JSON keywords array)
```
Artificial Intelligence, Neural Networks, Ternary Computing,
FPGA, Uncertainty Quantification, Calibration, ECE, Brier Score,
Bootstrap Validation, Effect Size, Cohen's d
```

#### 3.4 License

**License:** CC-BY-4.0

#### 3.5 Communities

Select communities:
- `neurips` — Neural Information Processing Systems
- `iclr` — International Conference on Learning Representations
- `mlsys` — Machine Learning Systems

### 4. Related Identifiers

**Add Related Identifier:**

| Relation | Identifier | Type |
|----------|------------|------|
| `isSupplementedBy` | https://github.com/gHashTag/trinity | URL |
| `isNewVersionOf` | (previous v6.x DOI) | DOI |

### 5. Version Information

**Version:** 7.0.0
**Publication Date:** 2026-03-27

### 6. Review and Publish

1. Review all fields
2. Click "Publish"
3. **Copy the new DOI** — needed for PARENT collection

---

## DOIs to Collect

After publishing each bundle, record the DOI:

```
B001 DOI: 10.5281/zenodo.XXXXXXXX
B002 DOI: 10.5281/zenodo.XXXXXXXX
B003 DOI: 10.5281/zenodo.XXXXXXXX
B004 DOI: 10.5281/zenodo.XXXXXXXX
B005 DOI: 10.5281/zenodo.XXXXXXXX
B006 DOI: 10.5281/zenodo.XXXXXXXX
B007 DOI: 10.5281/zenodo.XXXXXXXX
```

---

## PARENT Collection Upload (Last)

### 1. Update Related Identifiers

In `.zenodo.PARENT_v7.0.json`, update `related_identifiers` with the new DOIs:

```json
{
  "related_identifiers": [
    {
      "relation": "hasPart",
      "identifier": "10.5281/zenodo.[B001_DOI]",
      "scheme": "doi",
      "resource_type": "software"
    },
    ... (repeat for B002-B007)
  ]
}
```

### 2. Upload and Publish

Follow the same steps as individual bundles, but use `zenodo_PARENT_enhanced_v7.0.md`.

---

## V15 Scientific Rigor Verification

Before publishing, verify:

- [ ] Dual confidence intervals (95%, 99%) present
- [ ] Effect sizes (Cohen's d) reported
- [ ] Significance indicators (🌟, ✅, 🔶) used
- [ ] Calibration metrics (ECE, Brier) below thresholds
- [ ] Bootstrap method specified (10,000 resamples)
- [ ] NeurIPS 2025 compliance confirmed

---

## Post-Upload Actions

### 1. Verify DOIs

Test each DOI: https://doi.org/10.5281/zenodo.XXXXXXXX

### 2. Export Citation

Click "Export" → "BibTeX" and save to repository.

### 3. Create GitHub Release

```bash
gh release create v7.0.0 \
  --title "Trinity v7.0 — V15 Scientific Rigor" \
  --notes "See Zenodo for full documentation"
```

### 4. Update README

Add new DOIs to `docs/research/README.md`.

---

## Troubleshooting

### Error: "Title too long"

- Max 250 characters
- Shorten description, keep key terms

### Error: "Invalid identifier"

- Check DOI format: 10.5281/zenodo.XXXXXXXX
- Ensure correct scheme selected

### Error: "Missing required field"

- All fields marked with * are required
- Check: Title, Authors, Description, License

---

## Time Estimate

- **Per bundle:** 5-10 minutes
- **All 7 bundles:** 35-70 minutes
- **PARENT collection:** 10 minutes
- **Total:** ~1 hour

---

**φ² + 1/φ² = 3 | TRINITY v7.0**
