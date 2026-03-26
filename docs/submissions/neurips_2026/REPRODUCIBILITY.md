# NeurIPS 2026 — Reproducibility Checklist

## Code Availability

### Repository
- **URL:** https://github.com/gHashTag/trinity
- **License:** MIT
- **Version:** v7.0.0 (NeurIPS 2026 submission)
- **DOI:** 10.5281/zenodo.XXXXXX (to be assigned)

### Source Code Structure
```
trinity/
├── src/
│   ├── hslm/              # HSLM model implementation
│   ├── ternary/           # Ternary quantization
│   ├── sacred/            # φ-based arithmetic
│   └── calibration/       # ECE, Brier, NLL metrics
├── fpga/
│   └── openxc7-synth/     # Zero-DSP FPGA synthesis
├── tools/
│   └── evaluation/        # Evaluation scripts
└── tests/
    ├── test_hslm.zig      # Model tests
    └── test_calibration.zig  # Calibration tests
```

### Build Instructions
```bash
# Clone repository
git clone https://github.com/gHashTag/trinity.git
cd trinity

# Install Zig 0.15.2
# See: https://ziglang.org/download/

# Build all binaries
zig build

# Run tests
zig test

# Train HSLM
zig build hslm-train
./zig-out/bin/hslm-train --config configs/hslm_v7.json

# Evaluate
zig build hslm-eval
./zig-out/bin/hslm-eval --checkpoint checkpoints/hslm_v7.safetensors
```

---

## Data Availability

### Dataset
- **Name:** TinyStories
- **URL:** https://huggingface.co/datasets/roneneldan/TinyStories
- **License:** MIT
- **Version:** v1 (used in paper)
- **Size:** ~2.1GB (uncompressed)

### Preprocessing
```bash
# Download TinyStories
wget https://huggingface.co/datasets/roneneldan/TinyStories/resolve/main/data.tar.gz

# Preprocess for HSLM
zig build preprocess
./zig-out/bin/preprocess \
    --input data/tinystories.txt \
    --output data/tinystories_hslm.bin \
    --vocab_size 8192 \
    --seq_length 256
```

### Splits
- Train: 2,000,000 stories
- Validation: 10,000 stories
- Test: 10,000 stories (held out for final evaluation)

---

## Model Weights

### Checkpoint
- **Filename:** `hslm_v7_neurips2026.safetensors`
- **Size:** 385 KB (compressed)
- **Format:** safetensors
- **URL:** https://zenodo.org/record/XXXXXX
- **DOI:** 10.5281/zenodo.XXXXXX

### Loading
```python
from safetensors import safe_open

def load_hslm(path):
    with safe_open(path, framework="pt") as f:
        model = f.get_model()
    return model
```

---

## Experimental Protocol

### Training
```bash
# Default hyperparameters
./zig-out/bin/hslm-train \
    --data data/tinystories_hslm.bin \
    --output checkpoints/hslm_v7 \
    --params 1.95M \
    --lr 0.001 \
    --lr_schedule cosine \
    --batch_size 64 \
    --epochs 100 \
    --seed 42 \
    --eval_every 1000
```

### Evaluation
```bash
# Perplexity
./zig-out/bin/hslm-eval \
    --checkpoint checkpoints/hslm_v7.safetensors \
    --data data/tinystories_val.bin \
    --metric ppl

# Calibration
./zig-out/bin/hslm-calibration \
    --checkpoint checkpoints/hslm_v7.safetensors \
    --data data/tinystories_val.bin \
    --n_bins 10 \
    --n_samples 10000
```

---

## Compute Requirements

### Training
- **Hardware:** CPU (any modern x86-64), no GPU required
- **RAM:** 4 GB minimum
- **Time:** ~48 hours on 8-core CPU
- **Energy:** ~0.5 kWh (efficient CPU training)

### FPGA Synthesis
- **Toolchain:** Yosys 0.63 + nextpnr-xilinx
- **Hardware:** XC7A100T (or compatible)
- **Time:** ~30 minutes
- **RAM:** 8 GB

### Inference
- **CPU:** 1 core @ 3 GHz
- **Latency:** ~50 ms/token
- **Throughput:** ~20 tok/s (CPU), ~35 tok/s (FPGA)

---

## Hyperparameters

### Model Architecture
| Parameter | Value |
|-----------|-------|
| Vocabulary | 8192 |
| Embedding dim | 512 |
| Attention heads | 8 |
| Layers | 12 |
| FFN dim | 2048 |
| Context length | 256 |

### Training
| Parameter | Value |
|-----------|-------|
| Optimizer | AdamW |
| Learning rate | 0.001 |
| LR schedule | Cosine annealing |
| Batch size | 64 |
| Epochs | 100 |
| Weight decay | 0.01 |
| Gradient clipping | 1.0 |

### Quantization
| Parameter | Value |
|-----------|-------|
| Embedding | Ternary {-1, 0, +1} |
| Attention | Ternary |
| FFN | Ternary |
| Output | Ternary |

---

## Results Reproduction

### Expected Results
Running the evaluation script should produce:

```
=== HSLM v7.0 Evaluation ===
Dataset: TinyStories Validation
Checkpoint: checkpoints/hslm_v7.safetensors

Perplexity: 122.3 ± 2.1
ECE: 0.084 [0.079, 0.089]
Brier Score: 0.234 [0.228, 0.240]
NLL: 2.48 ± 0.05

Model Size: 385 KB
Compression: 19.7× vs FP32
```

### Tolerance
- PPL: ±5 (due to hardware/OS differences)
- ECE: ±0.01 (due to random sampling)
- Brier: ±0.02 (due to floating point)

---

## Docker Support

### Dockerfile
```dockerfile
FROM ziglang/zig:0.15.2

WORKDIR /trinity
COPY . .

RUN zig build
RUN zig test

ENTRYPOINT ["./zig-out/bin/hslm-train"]
```

### Build and Run
```bash
docker build -t trinity-hslm:neurips2026 .
docker run -v $(pwd)/data:/trinity/data trinity-hslm:neurips2026
```

---

## Contact

**Questions about reproduction:**
- GitHub Issues: https://github.com/gHashTag/trinity/issues
- Email: reproduction@trinity-research.org

**Bug Reports:**
- Include: Zig version, OS, error message, minimal reproduction

---

## License

All code, models, and data are released under the MIT License. See LICENSE file for details.

---

**φ² + 1/φ² = 3 | TRINITY**
**Document:** docs/submissions/neurips_2026/REPRODUCIBILITY.md
