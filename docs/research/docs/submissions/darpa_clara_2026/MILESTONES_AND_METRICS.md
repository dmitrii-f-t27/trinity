# DARPA CLARA Proposal — Milestones and Metrics

## 1. Milestones Overview

This document defines all milestones for the 24-month Trinity S³AI development program under DARPA CLARA. Each milestone includes measurable success criteria, verification methods, and contingency plans.

---

## 2. Critical Path Milestones

### M1: CI/CD Pipeline Operational (Week 4, Q1)

**Success Criteria:**
- All 3000+ tests passing in GitHub Actions
- Build time < 10 minutes
- Zero flaky tests (3 consecutive runs)

**Verification:**
```
# Verify pipeline
gh run list --workflow=ci.yml --limit=10
tri test --ci --all

# Check build time
time zig build
```

**Contingency:** If build time > 10 min, enable caching for dependencies.

---

### M2: Calibration Baseline Established (Week 6, Q1)

**Success Criteria:**
- HSLM ECE < 0.12 (NeurIPS 2025 threshold)
- Brier Score < 0.25
- 95% CI width < 0.02 for ECE

**Verification:**
```python
from calibration import compute_ece, compute_brier

ece, ci_ece = compute_ece(predictions, labels, n_bins=10)
brier, ci_brier = compute_brier(predictions, labels)

assert ece < 0.12
assert brier < 0.25
assert (ci_ece[1] - ci_ece[0]) < 0.02
```

**Contingency:** If ECE > 0.12, re-train with temperature scaling.

---

### M3: FPGA Synthesis Successful (Week 8, Q1)

**Success Criteria:**
- Yosys synthesis completes without errors
- nextpnr place-and-route succeeds
- Bitstream loads to XC7A100T
- Clock frequency > 50 MHz

**Verification:**
```bash
# Synthesis
yosys -p "synth_xilinx; write_json" sacred_alu.v

# Place-and-route
nextpnr-xilinx --json sacred_alu.json --pcf sacred_alu.pcf --fpga xc7a100t

# Verify timing
grep "Max frequency" sacred_alu.rpt
```

**Contingency:** If timing fails, reduce target clock to 25 MHz.

---

### M4: Power Target Met (Week 14, Q2)

**Success Criteria:**
- Zero-DSP FPGA power consumption < 1W
- Throughput > 30 tok/s
- Temperature < 60°C (nominal operation)

**Verification:**
```bash
# Measure power
./tools/power_meter.xc7a100t --duration 3600

# Verify throughput
tri bench hslm --dataset tinystories --count 10000 --iterations 10
```

**Contingency:** If power > 1W, reduce parallel inference lanes.

---

### M5: Formal Proof Coverage > 80% (Week 16, Q2)

**Success Criteria:**
- 50+ theorems formally verified
- Z3 SMT solver confirms all proofs
- Proof documentation complete

**Verification:**
```bash
# Verify proofs
zig build temple test

# Check coverage
zig build temple coverage
grep "TOTAL" coverage_report.txt
```

**Contingency:** If coverage < 80%, prioritize core operations (VSA, ALU).

---

### M6: Queen Convergence < 100 Episodes (Week 28, Q3)

**Success Criteria:**
- Queen-enabled agents reach quality="good" in < 100 episodes
- crash_rate < 5%
- byzantine_rate < 1%

**Verification:**
```bash
# Monitor convergence
tri queen self-learning --monitor 1000episodes

# Check metrics
tri queen metrics --json > metrics.json
jq '.crash_rate' metrics.json
```

**Contingency:** If convergence slow, tune kill_threshold.

---

### M7: VSA Composition Laws Verified (Week 28, Q3)

**Success Criteria:**
- Invertibility: unbind(bind(a, b), b) ≈ a (error < 0.1%)
- Associativity: bundle3(bundle3(a, b, c), d, e) = bundle3(a, b, bundle3(c, d, e))
- Commutativity: bundle2(a, b) = bundle2(b, a)

**Verification:**
```zig
// Invertibility test
const bound = try vsa.bind(a, b);
const recovered = try vsa.unbind(bound, b);
const error = distance(a, recovered);
try testing.expect(error < 0.001);
```

**Contingency:** If laws fail, investigate dimension selection.

---

### M8: NeurIPS Paper Submitted (Week 43, Q4)

**Success Criteria:**
- Paper uploaded to NeurIPS CMT portal
- All figures generated (PDF + PNG, 300 DPI)
- Code submission package complete
- Supplementary materials uploaded

**Verification:**
- Check NeurIPS submission status
- Verify all files present in submission package
- Run reproducibility checklist

**Contingency:** If deadline missed, submit to ICLR 2027.

---

### M9: Zero Critical Vulnerabilities (Week 62, Q6)

**Success Criteria:**
- Security audit report shows 0 critical, 0 high
- All medium/low issues addressed
- Penetration test passed

**Verification:**
```
# Static analysis
zig build security-audit

# Dependency scan
tri security scan --all

# Penetration test
tri security fuzz --duration 24h
```

**Contingency:** If critical issues found, allocate sprint to fix.

---

### M10: 2× Speedup Achieved (Week 64, Q6)

**Success Criteria:**
- Inference throughput doubled vs baseline
- Training speed improved by at least 1.5×
- Regression tests pass

**Verification:**
```bash
# Benchmark baseline
tri bench baseline --save baseline.json

# Benchmark optimized
tri bench optimized --save optimized.json

# Compare
tri bench compare baseline.json optimized.json
```

**Contingency:** If speedup < 2×, profile and optimize hotspots.

---

## 3. Monthly Metrics

### Development Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Tests passing | > 99.5% | `zig test` |
| Code coverage | > 80% | `zig build coverage` |
| Documentation coverage | > 90% | `tri docs check` |
| Build time | < 10 min | `time zig build` |

### ML Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| HSLM PPL (TinyStories) | < 130 | `tri hslm eval` |
| HSLM ECE | < 0.12 | `tri hslm calibration` |
| Calibration stability | ±0.02 | Monthly audit |
| Training convergence | < 100K steps | Monitor logs |

### Hardware Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| FPGA power | < 1W | Power meter |
| FPGA throughput | > 30 tok/s | Benchmark |
| FPGA temperature | < 60°C | Thermal sensor |
| Zero-DSP verification | 0 DSPs | Synthesis report |

### System Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Queen crash_rate | < 5% | `tri queen metrics` |
| Queen convergence episodes | < 100 | Episode tracking |
| Uptime | > 99% | Monitoring dashboard |
| Response time | < 100ms | Load testing |

---

## 4. Quarterly Reviews

### Q1 Review (Month 3)
**Attendees:** PI, Senior Engineer, ML Engineer, Research Assistant
**Agenda:**
- Review M1-M3 completion
- Assess risk register
- Adjust Q2 plans if needed
**Deliverable:** Q1 Progress Report

### Q2 Review (Month 6)
**Attendees:** All team + DARPA PM
**Agenda:**
- Review M4-M5 completion
- Demo Zero-DSP FPGA
- Discuss formal proof progress
**Deliverable:** Q2 Progress Report + Demo

### Q3 Review (Month 9)
**Attendees:** All team + External Reviewer
**Agenda:**
- Review M6-M7 completion
- VSA composition demo
- Queen production status
**Deliverable:** Q3 Progress Report

### Q4 Review (Month 12)
**Attendees:** All team + DARPA PM
**Agenda:**
- Review M8 completion
- NeurIPS submission status
- v7.0 release readiness
**Deliverable:** Q4 Progress Report

### Q5-Q8 Reviews (Months 15, 18, 21, 24)
Similar format with relevant milestones.

---

## 5. Success Metrics Summary

**Primary Success Metrics (Must Achieve):**
1. All critical path milestones (M1-M10) met on time
2. ECE < 0.12 maintained across all releases
3. 3000+ tests passing at all times
4. Zero critical security vulnerabilities
5. At least 1 peer-reviewed paper accepted

**Secondary Success Metrics (Stretch Goals):**
1. 2 peer-reviewed papers accepted
2. 3× power improvement (vs 1W target)
3. 3× speedup improvement (vs 2× target)
4. 100+ external users by Q8
5. Technology adopted by 2+ DARPA programs

**Failure Criteria:**
- Any critical path milestone missed by > 2 weeks
- ECE > 0.15 for 2 consecutive quarters
- > 5% test failures for 1 month
- Security breach or data loss

---

## 6. Reporting Schedule

| Report | Frequency | Due Date | Recipient |
|--------|------------|-----------|------------|
| Weekly Status | Weekly | Friday 5pm | DARPA PM |
| Monthly Metrics | Monthly | Last day of month | DARPA PM |
| Quarterly Progress | Quarterly | End of month 3,6,9,12,15,18,21 | DARPA PM |
| Annual Report | Yearly | End of month 12, 24 | DARPA PM |
| Final Report | One-time | Week 96 | DARPA PM |

---

**φ² + 1/φ² = 3 | TRINITY**
**Document:** docs/submissions/darpa_clara_2026/MILESTONES_AND_METRICS.md
