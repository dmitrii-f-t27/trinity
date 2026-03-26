# NeurIPS 2026 — Limitations

## Overview

This document outlines the limitations of the Sacred Computing framework and HSLM model. These limitations should be considered when interpreting results and applying the method to new domains.

---

## Scope Limitations

### 1. Single Dataset Evaluation

**Limitation:** HSLM is evaluated only on TinyStories, a synthetic dataset of short stories for children.

**Impact:** Results may not generalize to more complex domains (news, code, dialogue).

**Mitigation:** TinyStories is a standard benchmark for small language models. Future work will evaluate on diverse datasets.

---

### 2. Model Size Constraint

**Limitation:** HSLM has 1.95M parameters, much smaller than state-of-the-art LLMs (billions of parameters).

**Impact:** Scaling behavior of ternary quantization and φ-based arithmetic at larger scales is unknown.

**Mitigation:** The 1.95M size is intentional for edge deployment. Scaling laws for ternary models are an open research question.

---

### 3. FPGA Platform Specificity

**Limitation:** Zero-DSP synthesis results are specific to Xilinx XC7A100T FPGA.

**Impact:** Results may not translate to other FPGA families (Intel, Lattice) or ASIC implementations.

**Mitigation:** XC7A100T is a widely available platform. Toolchain (Yosys) is open-source and portable.

---

## Technical Limitations

### 4. Calibration Dataset Dependence

**Limitation:** ECE calibration quality depends on validation set distribution. Shift from training distribution may degrade calibration.

**Impact:** Out-of-distribution inputs may produce poorly calibrated uncertainties.

**Mitigation:** Continuous monitoring and adaptive calibration can address distribution shift.

---

### 5. Trit Precision Trade-off

**Limitation:** Ternary representation {-1, 0, +1} has limited precision compared to FP32/FP16. Some accuracy loss is unavoidable.

**Impact:** Tasks requiring high precision (scientific computing, some classification tasks) may suffer.

**Mitigation:** Hybrid approaches (ternary embeddings + FP32 attention) can be used for precision-sensitive tasks.

---

### 6. FPGA Clock Frequency

**Limitation:** Zero-DSP design runs at 50 MHz, slower than DSP-based designs (100+ MHz).

**Impact:** Throughput limited by clock frequency, despite parallelization benefits.

**Mitigation:** Pipelining and multiple parallel lanes can increase effective throughput.

---

## Methodological Limitations

### 7. Lack of Theoretical Calibration Guarantees

**Limitation:** We observe good calibration empirically (ECE=0.084) but lack theoretical guarantees for why ternary quantization improves calibration.

**Impact:** The calibration benefit may not hold for all architectures or datasets.

**Mitigation:** Ongoing research into theoretical connections between quantization and calibration.

---

### 8. VSA Dimension Selection

**Limitation:** VSA operations require careful dimension selection. Too few dimensions cause interference; too many waste memory.

**Impact:** Optimal dimensions are task-dependent and require tuning.

**Mitigation:** Heuristics exist (dimension ≥ 10× vocabulary size), but automatic selection is an open problem.

---

### 9. Queen Lotus Hyperparameter Sensitivity

**Limitation:** Queen Lotus self-learning has several hyperparameters (kill_threshold, crash_rate_limit) that affect convergence.

**Impact:** Poor hyperparameter choices can lead to slow convergence or instability.

**Mitigation:** Default values work well for most scenarios; auto-tuning is planned for future work.

---

## Evaluation Limitations

### 10. Calibration Metric Selection

**Limitation:** We report ECE with 10 bins. Different bin counts or calibration metrics (adaptive ECE, NLL) may show different results.

**Impact:** Ranking of methods may change under different metrics.

**Mitigation:** We report multiple metrics (ECE, Brier, NLL) and 95% confidence intervals for robustness.

---

### 11. Single-Run Baselines

**Limitation:** Some baseline results (FP32, FP16) are from single runs, not multiple seeds.

**Impact:** Variance estimates for baselines may be inaccurate.

**Mitigation:** We ran 5 seeds for HSLM; future work will include multi-seed baselines.

---

### 12. Energy Measurement Constraints

**Limitation:** Power measurements are at the FPGA level only. Full system power (CPU, memory, I/O) not measured.

**Impact:** Real-world energy consumption may be higher than reported (1.2W FPGA only).

**Mitigation:** We report FPGA power as a lower bound; full system power depends on deployment scenario.

---

## Open Questions

### 13. Scaling Behavior

**Question:** How does ternary quantization scale to 10M, 100M, 1B+ parameter models?

**Status:** Unknown — requires significant compute resources to investigate.

---

### 14. Transfer Learning

**Question:** Can HSLM be fine-tuned for downstream tasks while maintaining calibration?

**Status:** Preliminary results show calibration degrades after fine-tuning. Methods to preserve calibration under investigation.

---

### 15. Multimodal Extension

**Question:** Can Sacred Computing extend to vision, audio, or multimodal models?

**Status:** Ternary quantization applies to any modality, but calibration behavior is unknown.

---

## Conclusion

These limitations are acknowledged to set appropriate expectations:

- **HSLM is designed for edge deployment** — not a replacement for large-scale LLMs
- **Calibration is empirically observed** — theoretical understanding is ongoing
- **Results are dataset-specific** — generalization requires further validation
- **FPGA results are platform-specific** — other hardware may show different characteristics

**Future Work Directions:**
1. Multi-dataset evaluation (code, news, dialogue)
2. Scaling studies (10M, 100M parameters)
3. Theoretical analysis of quantization-calibration relationship
4. Cross-platform FPGA/ASIC validation
5. Transfer learning with preserved calibration

---

**φ² + 1/φ² = 3 | TRINITY**
**Document:** docs/submissions/neurips_2026/LIMITATIONS.md
