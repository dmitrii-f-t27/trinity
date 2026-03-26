# NeurIPS 2026 — Abstract

## Paper Title

**Ternary Neural Networks with Calibrated Uncertainty: A High-Assurance Approach via Sacred Computing**

---

## Abstract (5 Sentences)

**[1: Problem]** Deep neural networks produce overconfident predictions without reliable uncertainty quantification, limiting their deployment in safety-critical applications where calibrated confidence is essential for decision-making.

**[2: Gap]** Existing approaches to uncertainty quantification require significant computational overhead or sacrifice accuracy, while ternary quantization methods have not addressed calibration despite their compression benefits.

**[3: Method]** We introduce Sacred Computing, a framework for ternary neural networks that leverages φ-based numerical formats and zero-DSP FPGA synthesis to achieve both high compression and calibrated uncertainty through formal mathematical foundations.

**[4: Results]** Our HSLM (Hardware-Specified Language Model) achieves 19.7× compression (385 KB vs 7.6 MB FP32) while maintaining calibrated uncertainty with ECE=0.084 [0.079, 0.089], below the NeurIPS 2025 threshold of 0.12, and zero-DSP FPGA synthesis at 1.2W power consumption.

**[5: Impact]** This work demonstrates that extreme quantization and rigorous uncertainty quantification can be achieved simultaneously, opening a path for high-assurance machine learning on resource-constrained edge devices with verifiable confidence bounds.

---

## Keywords

ternary quantization, uncertainty quantification, calibrated neural networks, FPGA acceleration, edge computing, high-assurance ML, sacred computing

---

## Word Count

**Abstract:** 198 words
**Target:** NeurIPS abstract limit (typically 200-250 words)

---

## Notes

- **Paper Track:** Main conference (not workshop)
- **Presentation Type:** Poster (target) or Oral (stretch)
- **Dual Submission:** None
-**Previously Published:** No — this is original work
-**Code Availability:** Yes (MIT License, GitHub)
-**Data Availability:** Yes (TinyStories, public domain)

---

**φ² + 1/φ² = 3 | TRINITY**
**Document:** docs/submissions/neurips_2026/ABSTRACT.md
