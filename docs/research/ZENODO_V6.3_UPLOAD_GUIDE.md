# Zenodo v6.3 Upload Guide

**Date:** 2026-03-27  
**Version:** 6.3.0  
**Status:** Ready for Upload

---

## Prerequisites

1. ✅ Zenodo account (https://zenodo.org/signup)
2. ⏳ ORCID linked to profile
3. ✅ GitHub release v6.3.0 published
4. ✅ All v6.3 files prepared

---

## Upload Procedure (8 Depositions)

### Step 1: Access Zenodo Deposit

Visit: https://zenodo.org/deposit

Login with your Zenodo account.

### Step 2: Upload Parent Collection (PARENT)

#### Basic Information
- **Title:** `Trinity S³AI Framework — Parent Collection v6.3`
- **Upload Type:** Publication
- **Publication Type:** Other

#### Files to Upload
```
docs/research/ZENODO_README.md
docs/research/CITATION.cff
docs/research/ZENODO_V6.3_RELEASE_NOTES.md
docs/research/figures/bundle_dependencies.png
docs/research/figures/bundle_dependencies.svg
```

#### Metadata (Copy from JSON)
```json
{
  "creators": [{"name": "Vasilev, Dmitrii", "affiliation": "Independent Researcher"}],
  "description": "Trinity S³AI parent collection with 7 comprehensive bundles...",
  "keywords": ["AI", "Ternary", "Symbolic", "FPGA", "Agent Swarm"],
  "license": "CC-BY-4.0",
  "publication_date": "2026-03-27"
}
```

#### Communities
- neurips
- iclr
- mlsys

---

### Step 3: Upload B001 (HSLM)

#### Files to Upload
```
docs/research/zenodo_B001_enhanced_v6.2.md
docs/research/notebooks/B001_Training_Analysis.ipynb
docs/research/data/B001_training.csv
docs/research/figures/B001_training_curve.png
docs/research/figures/B001_training_curve.svg
docs/research/figures/B001_fpga_resources.png
docs/research/figures/B001_fpga_resources.svg
docs/research/docker/Dockerfile.B001
```

#### Metadata
```json
{
  "title": "B001: HSLM-1.95M — Ternary Language Model v6.3",
  "keywords": ["Language Models", "Ternary", "Calibration", "ECE"],
  "description": "HSLM achieves 123.9 perplexity with ECE 0.084..."
}
```

---

### Step 4: Upload B002 (FPGA)

#### Files to Upload
```
docs/research/zenodo_B002_enhanced_v6.2.md
docs/research/notebooks/B002_FPGA_Analysis.ipynb
docs/research/data/B002_fpga_synthesis.csv
docs/research/figures/B002_fpga_resources.png
docs/research/figures/B002_resource_utilization.png
docs/research/docker/Dockerfile.B002
```

---

### Step 5: Upload B003-B007

Repeat for B003 (TRI-27), B004 (Lotus), B005 (VIBEE), B006 (Sacred), B007 (VSA).

Each bundle should include:
- Enhanced markdown description
- Analysis notebook (if available)
- CSV data files
- Figures (PNG + SVG)
- Dockerfile

---

## File Manifest (Complete)

### PARENT Collection (5 files)
```
ZENODO_README.md                          16 KB
CITATION.cff                               2 KB
ZENODO_V6.3_RELEASE_NOTES.md              5 KB
bundle_dependencies.png                  256 KB
bundle_dependencies.svg                   71 KB
```

### B001: HSLM (8 files)
```
zenodo_B001_enhanced_v6.2.md              20 KB
B001_Training_Analysis.ipynb              8 KB
B001_training.csv                        1 KB
B001_training_curve.png                 45 KB
B001_training_curve.svg                 12 KB
B001_fpga_resources.png                38 KB
B001_fpga_resources.svg                10 KB
Dockerfile.B001                          2 KB
```

### B002: FPGA (6 files)
```
zenodo_B002_enhanced_v6.2.md              15 KB
B002_FPGA_Analysis.ipynb                 7 KB
B002_fpga_synthesis.csv                 1 KB
B002_fpga_resources.png                42 KB
B002_resource_utilization.png          38 KB
Dockerfile.B002                          2 KB
```

### B003-B007: Remaining Bundles (30+ files)
Full list: see `docs/research/ZENODO_FILE_MANIFEST_v6.3.txt`

---

## Total Upload Size

| Bundle | Files | Size |
|--------|-------|------|
| PARENT | 5 | ~350 KB |
| B001 | 8 | ~125 KB |
| B002 | 6 | ~105 KB |
| B003 | 5 | ~95 KB |
| B004 | 5 | ~98 KB |
| B005 | 8 | ~145 KB |
| B006 | 6 | ~112 KB |
| B007 | 7 | ~118 KB |
| **Total** | **50** | **~1.1 MB** |

---

## Post-Upload Steps

### 1. Record DOIs
After publishing, Zenodo will mint DOIs. Record them:

```json
{
  "PARENT": "10.5281/zenodo.XXXXXXX",
  "B001": "10.5281/zenodo.XXXXXXY",
  "B002": "10.5281/zenodo.XXXXXXZ",
  ...
}
```

### 2. Update CITATION.cff
Add the new DOIs to the citation file.

### 3. Update README
Add Zenodo badge to project README:

```markdown
[![Zenodo](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)
```

### 4. Cross-Reference Bundles
Edit each bundle to add related identifier links to other bundles.

---

## Verification Checklist

- [ ] All 8 depositions created
- [ ] All files uploaded (50 total)
- [ ] Metadata filled completely
- [ ] License set to CC-BY-4.0
- [ ] Communities added (neurips, iclr, mlsys)
- [ ] DOIs recorded
- [ ] CITATION.cff updated
- [ ] README badges added

---

## Troubleshooting

### Issue: Large File Upload
**Solution:** Use Zenodo CLI or split into smaller chunks

### Issue: Metadata Validation Error
**Solution:** Check JSON format, ensure all required fields present

### Issue: DOI Not Minting
**Solution:** Ensure publication date is set and status is "Published"

---

## Contact

For issues or questions:
- GitHub: https://github.com/gHashTag/trinity/issues
- Zenodo Help: https://help.zenodo.org

---

**φ² + 1/φ² = 3 | TRINITY**
