# DARPA CLARA Proposal — Open Source Plan

## 1. Executive Summary

Trinity S³AI will be released under the MIT License, providing maximum freedom for research, commercial, and government use. All source code, documentation, and datasets will be publicly available via GitHub with comprehensive reproducibility packages.

---

## 2. License Strategy

### 2.1 Primary License: MIT

**Rationale:**
- Permissive: Allows commercial and government use
- Simple: No copyleft restrictions
- Compatible: Works with all open-source licenses
- Standard: Widely adopted in ML/HW communities

**License Text:**
```
MIT License

Copyright (c) 2026 Trinity Research Collective

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
```

### 2.2 Third-Party Dependencies

**Policy:** Zero external dependencies for core Trinity S³AI.

**Verification:**
```bash
# Check for third-party dependencies
zig build --list-dependencies

# Expected output: (empty - all from std lib)
```

**If Third-Party Code Required:**
- Prefer MIT/Apache/BSD licenses
- Document all third-party code
- Attributions in `NOTICE` file
- License audit before integration

---

## 3. Repository Structure

### 3.1 GitHub Organization

**Repository:** https://github.com/gHashTag/trinity

**Structure:**
```
trinity/
├── README.md                    # Project overview
├── LICENSE                      # MIT License
├── NOTICE                       # Third-party attributions
├── .zenodo/                     # Zenodo metadata
├── CLAUDE.md                   # Project instructions
├── build.zig                    # Build system
├── docs/                        # Documentation
│   ├── submissions/              # DARPA/NeurIPS/ICLR
│   └── research/                # Research papers
├── specs/                       # .tri specifications
├── src/                         # Source code
│   ├── hslm/                   # HSLM language model
│   ├── tri27/                  # TRI-27 ISA
│   ├── vsa.zig                 # VSA operations
│   ├── temple/                 # Sacred math (TTT layer)
│   └── ...
├── tools/                       # Tools and utilities
│   └── mcp/                    # MCP servers
├── fpga/                        # FPGA designs
│   └── openxc7-synth/           # Zero-DSP synthesis
└── tests/                       # Test suites
```

### 3.2 Branching Strategy

**Main Branch:** `main`
- Production-ready code
- Tagged releases (v6.3.0, v7.0, v8.0)

**Feature Branches:** `feat/issue-{N}`
- Issue-specific development
- Merged via PR after review

**Release Branches:** `release/v{X}.{Y}.{Z}`
- Release preparation
- Bug fixes only

---

## 4. Reproducibility Plan

### 4.1 Build Reproducibility

**Determined Build:**
```bash
# Zig provides deterministic builds by default
zig build --cache-dir ./zig-cache --global-cache-dir ./zig-global-cache
```

**Docker Image:**
```dockerfile
FROM ziglang/zig:0.15.2

# Copy source
COPY . /trinity

# Deterministic build
WORKDIR /trinity
RUN zig build --release-fast --Ddeterministic

# Verify checksum
RUN sha256sum zig-out/bin/tri > trin.sha256
```

**Checksum Verification:**
```bash
# Verify reproducible build
sha256sum zig-out/bin/tri
```

### 4.2 Experiment Reproducibility

**Seeding:** All experiments use fixed seeds for reproducibility.

```zig
// Random number generator with fixed seed
var rng = std.Random.DefaultPrng.init(12345);
```

**Configuration Tracking:**
```json
{
  "experiment_id": "exp_001",
  "seed": 12345,
  "model": "hslm_v6.3",
  "dataset": "tinystories",
  "hyperparameters": {
    "learning_rate": 0.001,
    "batch_size": 64,
    "epochs": 100
  },
  "git_commit": "abc123def",
  "zig_version": "0.15.2"
}
```

### 4.3 Dataset Versioning

**Datasets:**
- Hosted on Hugging Face for versioning
- DOI via Zenodo for each dataset version
- MD5 checksums for integrity

**Example:**
```bash
# Download specific version
wget https://huggingface.co/datasets/trinity/tinystories-v1/resolve/main/train.jsonl

# Verify checksum
md5sum train.jsonl
```

---

## 5. Documentation Plan

### 5.1 API Documentation

**Generated from Source:**
```bash
# Generate Zig documentation
zig build docs

# Output: zig-out/docs/index.html
```

**Coverage:** All public APIs documented.

### 5.2 User Guides

**Documents:**
- `README.md` — Getting started guide
- `docs/INSTALL.md` — Installation instructions
- `docs/USAGE.md` — Command reference
- `docs/TUTORIAL.md` — Tutorial examples
- `docs/SACRED_MATH.md` — φ-based mathematics
- `docs/TRI27_ISA.md` — Assembly reference
- `docs/VIBEE.md` — Compiler guide

### 5.3 Research Documentation

**Papers and Reports:**
- NeurIPS 2026 paper (Q4)
- ICLR 2027 paper (Q5-Q6)
- Technical reports (quarterly)
- Zenodo bundle descriptions (8 bundles)

---

## 6. Release Process

### 6.1 Versioning

**Semantic Versioning:** `MAJOR.MINOR.PATCH`

- **MAJOR:** Breaking changes (v6 → v7)
- **MINOR:** New features (v6.3 → v6.4)
- **PATCH:** Bug fixes (v6.3.0 → v6.3.1)

**Current Version:** v6.3.0

### 6.2 Release Checklist

Before each release:
- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version tags created
- [ ] Zenodo bundle updated
- [ ] GitHub release created
- [ ] Docker images pushed

### 6.3 GitHub Release

**Release Content:**
- Source code (tagged commit)
- Compiled binaries (Linux, macOS, Windows)
- Docker image
- Documentation
- CHANGELOG

**Example:**
```
Release: v7.0.0
Date: 2026-12-01
Assets:
  - tri-linux-amd64
  - tri-macos-arm64
  - tri-windows-amd64
  - trinity:7.0.0 (Docker)
```

---

## 7. Community Engagement

### 7.1 Contribution Guidelines

**CONTRIBUTING.md:**
1. Fork repository
2. Create feature branch (`feat/issue-{N}`)
3. Write tests for new code
4. Run `zig fmt` and `zig test`
5. Submit PR with issue reference
6. Code review and merge

**Code of Conduct:** Be respectful, inclusive, collaborative.

### 7.2 Issue Tracking

**GitHub Issues:**
- Bug reports: template with reproduction steps
- Feature requests: clear use case description
- Questions: tagged as `question`
- Security: private reporting to maintainers

### 7.3 Discussion Channels

**Forums:**
- GitHub Discussions: General questions
- Gitter/Slack: Real-time chat
- Email: Direct contact option

---

## 8. Continuous Integration

### 8.1 GitHub Actions

**Workflows:**
- `ci.yml` — Build and test on every push
- `release.yml` — Create release artifacts
- `security.yml` — Security scanning
- `docker.yml` — Build and push images

**Triggers:**
- Push to `main`: Full CI
- Pull request: Full CI + coverage
- Release: Release artifacts

### 8.2 Coverage Requirements

**Target:** > 80% code coverage

**Measurement:**
```bash
# Generate coverage report
zig build coverage

# Check coverage
zig build coverage --summary
```

**Failure:** If coverage < 70%, PR cannot merge.

---

## 9. Security and Privacy

### 9.1 Security Policy

**Reporting Security Issues:**
- Email: security@trinity-research.org
- PGP Key: [to be published]
- Response time: 48 hours

**Vulnerability Handling:**
1. Acknowledge receipt
2. Investigate severity
3. Develop fix
4. Coordinate disclosure
5. Publish patch + advisory

### 9.2 Data Privacy

**Datasets:**
- Public domain or CC-BY licensed
- No personally identifiable information
- Documented data collection process

---

## 10. Intellectual Property

### 10.1 Ownership

**Trinity Research Collective** owns all intellectual property created under this DARPA CLARA project.

**DARPA Rights:**
- Unlimited data rights (government purpose)
- Unlimited rights (public release)
- Copyright retained by Trinity

### 10.2 Patent Policy

**Patent Strategy:**
- Defensive publications via Zenodo
- Open-source first (MIT license)
- Patent only if required for transition

---

## 11. Long-Term Maintenance

### 11.1 Maintenance Commitment

**Minimum:** 12 months post-DARPA completion
**Target:** Indefinite maintenance
**Responsibility:** Trinity Research Collective

### 11.2 Support Channels

**Support Tiers:**
- Community: GitHub Discussions, issues
- Commercial: Paid support option
- Government: Dedicated support via contract

---

## 12. Success Metrics

**Open Source Metrics:**
| Metric | Target | Timeline |
|--------|--------|-----------|
| GitHub Stars | 100+ | Q4 |
| Forks | 20+ | Q4 |
| Issues/Closed Ratio | < 0.2 | Q6 |
| Contributors (external) | 10+ | Q8 |
| Production deployments | 5+ | Q8 |

**Reproducibility Metrics:**
| Metric | Target |
|--------|--------|
| Build reproducibility | 100% |
| Experiment reproducibility | 95% |
| Documentation coverage | > 90% |
| Test coverage | > 80% |

---

## 13. Conclusion

Trinity S³AI will be fully open source under the MIT License with:

- ✅ **Permissive licensing** — Commercial and government use allowed
- ✅ **Reproducible builds** — Deterministic, checksummed
- ✅ **Comprehensive documentation** — API, guides, tutorials
- ✅ **Active CI/CD** — Automated testing and releases
- ✅ **Community engagement** — Contribution guidelines, discussions
- ✅ **Security process** — Vulnerability reporting, fixes
- ✅ **Long-term maintenance** — 12+ months post-DARPA

---

**φ² + 1/φ² = 3 | TRINITY**
**Document:** docs/submissions/darpa_clara_2026/OPEN_SOURCE_PLAN.md
