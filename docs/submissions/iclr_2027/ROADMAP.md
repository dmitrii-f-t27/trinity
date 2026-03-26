# ICLR 2027 — Roadmap

## Overview

This document outlines the 7-month timeline from now (March 2026) to ICLR 2027 submission (September 2026). The roadmap is organized into phases with clear milestones and dependencies.

---

## Submission Timeline

**ICLR 2027 Key Dates:**
- **Abstract deadline:** ~September 2026 (exact date TBD)
- **Paper deadline:** ~October 2026 (exact date TBD)
- **Notification:** ~December 2026
- **Conference:** ~May 2027

**Our Timeline:**
- **Target:** Complete paper by August 2026 (1 month buffer)
- **Internal deadline:** July 2026 (2 months buffer)

---

## Phase 1: Preparation (Weeks 1-4, April 2026)

### Goals
- Complete literature review
- Finalize experimental design
- Set up infrastructure

### Tasks

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 1 | Literature review | Annotated bibliography | PI |
| 2 | Experimental design | Experiment specification | PI |
| 3 | Infrastructure setup | Compute resources ready | Senior Engineer |
| 4 | Baseline reproduction | TinyStories baseline replicated | ML Engineer |

### Milestones

- M1.1: Literature review complete (20+ papers)
- M1.2: Experimental protocol documented
- M1.3: All systems operational

### Dependencies

- None — can start immediately

---

## Phase 2: Multi-Dataset Experiments (Weeks 5-10, May-June 2026)

### Goals
- Evaluate HSLM on 4 datasets
- Validate calibration improvement across domains

### Tasks

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 5-6 | Dataset preprocessing | 4 datasets ready | ML Engineer |
| 7-8 | Training (WikiText, C4) | 2 models trained | ML Engineer |
| 9-10 | Training (Code, ImageNet) | 2 models trained | ML Engineer |
| 10 | Evaluation | Results table | ML Engineer |

### Milestones

- M2.1: All datasets preprocessed
- M2.2: All 4 models trained
- M2.3: ECE < 0.12 on all datasets (or analysis of failure)

### Dependencies

- Requires Phase 1 completion

---

## Phase 3: Cross-Architecture Validation (Weeks 11-16, July-August 2026)

### Goals
- Validate ternary calibration across architectures
- Demonstrate generality beyond transformers

### Tasks

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 11-12 | Implement architectures | LSTM, CNN, MLP ready | Senior Engineer |
| 13-14 | Training (all 4 arch) | 4 models trained | ML Engineer |
| 15-16 | Evaluation + analysis | Cross-arch results table | PI |

### Milestones

- M3.1: All architectures implemented
- M3.2: All models trained
- M3.3: Consistent calibration trend across architectures

### Dependencies

- Can run in parallel with Phase 2 (different compute)

---

## Phase 4: Theoretical Analysis (Weeks 9-20, June-August 2026)

### Goals
- Develop mathematical explanation
- Write theorems and proofs
- Integrate with empirical results

### Tasks

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 9-12 | Literature review (theory) | Theory bibliography | Research Assistant |
| 13-16 | Theorem development | 1-2 theorems | Research Assistant |
| 17-18 | Proof verification | Z3 verification | Research Assistant |
| 19-20 | Paper section (theory) | 2-3 pages written | PI |

### Milestones

- M4.1: Theorem statement complete
- M4.2: Proof verified (Z3)
- M4.3: Paper section written

### Dependencies

- Overlaps with Phases 2-3 (uses empirical data)

---

## Phase 5: Baseline Comparisons (Weeks 17-22, August-September 2026)

### Goals
- Compare to other calibration methods
- Establish fair comparison

### Tasks

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 17-18 | Implement baselines | 5 methods ready | ML Engineer |
| 19-20 | Training (all baselines) | 5 models trained | ML Engineer |
| 21-22 | Evaluation + comparison | Results table | PI |

### Milestones

- M5.1: All baselines implemented
- M5.2: Comparison table complete
- M5.3: Ternary in top 2 for ECE

### Dependencies

- Requires Phase 2 completion (need datasets)

---

## Phase 6: Paper Writing (Weeks 20-26, September-October 2026)

### Goals
- Complete full paper draft
- Internal review and revision

### Tasks

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 20-22 | Methods section | 3 pages | PI |
| 23-24 | Results section | 4 pages | PI |
| 25 | Discussion + Conclusion | 2 pages | PI |
| 26 | Internal review | Feedback from team | All |

### Milestones

- M6.1: First draft complete (9 pages)
- M6.2: Internal review feedback incorporated
- M6.3: Final draft ready for external review

### Dependencies

- Requires all experimental phases complete

---

## Phase 7: Final Preparation (Weeks 27-29, October 2026)

### Goals
- External review
- Final polish
- Submission package

### Tasks

| Week | Task | Deliverable | Owner |
|------|------|-------------|-------|
| 27 | External review | Feedback from 2 reviewers | PI |
| 28 | Revisions | Address feedback | PI |
| 29 | Submission package | PDF, code, supplementary | PI |

### Milestones

- M7.1: External review complete
- M7.2: All feedback addressed
- M7.3: Submission uploaded

### Dependencies

- Requires Phase 6 complete

---

## Resource Plan

### Personnel

| Role | FTE | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 | Phase 6 | Phase 7 |
|------|-----|--------|--------|--------|--------|--------|--------|--------|
| PI | 50% | ✅ | ✅ | ✅ | ✅ | ✅ | 100% | 100% |
| Senior Engineer | 50% | ✅ | — | ✅ | — | — | — | — |
| ML Engineer | 100% | ✅ | ✅ | ✅ | — | ✅ | — | — |
| Research Assistant | 100% | — | — | — | ✅ | — | ✅ | — |

### Compute

| Resource | Usage | Cost |
|----------|-------|------|
| CPU (16 cores) | 8 weeks | $800 |
| Storage (2 TB) | 7 months | $140 |
| Cloud backup | 7 months | $50 |
| **Total** | — | **~$1,000** |

---

## Risk Management

### Schedule Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Experiments overrun | Medium | High | Reduce dataset count (4→2) |
| Theoretical analysis fails | Medium | Medium | Focus on empirical contribution |
| Compute shortage | Low | High | Cloud backup |
| Personnel shortage | Low | Medium | Cross-train team members |

### Quality Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Calibration not consistent | Low | High | Acknowledge in limitations |
| Negative results | Low | Medium | Report honestly (ICLR values this) |
| Baseline outperforms | Low | Medium | Still novel contribution |

---

## Success Criteria

### Must Achieve (for submission)

- [ ] Multi-dataset evaluation: ≥2 datasets
- [ ] Cross-architecture validation: ≥2 architectures
- [ ] ECE improvement demonstrated: ternary < FP32
- [ ] Paper draft: 8-9 pages (ICLR format)

### Should Achieve (for acceptance)

- [ ] Multi-dataset evaluation: 4 datasets
- [ ] Cross-architecture validation: 4 architectures
- [ ] Theoretical contribution: 1 theorem + proof
- [ ] Strong baselines: Top 2 for ECE

### Nice to Have (for impact)

- [ ] Novel theoretical insight
- [ ] State-of-the-art ECE on ≥1 benchmark
- [ ] Open-source release with tutorials

---

## Timeline Visualization

```
Phase 1: ████████████████ (Weeks 1-4)  Preparation
Phase 2: ████████████████████████████████████████████████ (Weeks 5-10)  Multi-Dataset
Phase 3:           ████████████████████████████████████████████████████ (Weeks 11-16)  Cross-Arch
Phase 4:     ████████████████████████████████████████████████████████████████ (Weeks 9-20)  Theory
Phase 5:                                         ████████████████████████████████████ (Weeks 17-22)  Baselines
Phase 6:                                                       ████████████████████████████ (Weeks 20-26)  Writing
Phase 7:                                                                     ██████████████ (Weeks 27-29)  Final
         └────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴────────┴
Month:     Apr      May      Jun      Jul      Aug      Sep      Oct      (2026)
```

---

## Summary

**Timeline:** 29 weeks (~7 months) to submission
**Milestones:** 18 major milestones
**Experiments:** 4 datasets × 4 architectures = 16 models
**Theoretical:** 1-2 theorems + proofs
**Personnel:** 4 FTE across phases
**Budget:** ~$1,000 compute + personnel costs

**Readiness for ICLR 2027:**
- ✅ Concept defined (ternary representation learning)
- ✅ Preliminary results (ECE=0.084 on TinyStories)
- 🔄 Experiments needed (multi-dataset, cross-arch)
- 🔄 Theoretical contribution needed
- ✅ Timeline achievable

---

**φ² + 1/φ² = 3 | TRINITY**
**Document:** docs/submissions/iclr_2027/ROADMAP.md
