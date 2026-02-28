<div align="center">

  <h1>Trinity</h1>

  <strong>Sacred Intelligence CLI — Ternary AI + DePIN Network</strong><br>
  <sub>φ² + 1/φ² = 3 — The Trinity Identity</sub>

  <p>
    <a href="https://github.com/gHashTag/trinity/releases"><img src="https://img.shields.io/github/v/release/gHashTag/trinity?style=flat-square&logo=github" alt="Release"></a>
    <a href="https://www.npmjs.com/package/@playra/tri"><img src="https://img.shields.io/npm/v/@playra/tri?style=flat-square&logo=npm" alt="npm"></a>
    <a href="https://github.com/gHashTag/homebrew-trinity"><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FgHashTag%2Fhomebrew-trinity%2Fmain%2FFormula%2Ftrinity.rb&query=$.version&label=homebrew&style=flat-square&logo=homebrew" alt="Homebrew"></a>
    <a href="https://aur.archlinux.org/packages/trinity-cli"><img src="https://img.shields.io/aur/version/trinity-cli?style=flat-square&logo=arch-linux" alt="AUR"></a>
    <a href="https://github.com/gHashTag/trinity/actions"><img src="https://img.shields.io/github/actions/workflow/status/gHashTag/trinity/docker-node.yml?label=Docker&style=flat-square&logo=docker" alt="Docker"></a>
    <a href="https://ziglang.org"><img src="https://img.shields.io/badge/Zig-0.15.x-F7A41D?style=flat-square&logo=zig" alt="Zig"></a>
    <a href="./LICENSE"><img src="https://img.shields.io/github/license/gHashTag/trinity?style=flat-square" alt="License"></a>
  </p>

  <p>
    <a href="#-installation"><img src="https://img.shields.io/badge/Install-npm-red?style=for-the-badge&logo=npm" alt="npm"></a>
    <a href="#-installation"><img src="https://img.shields.io/badge/Install-Homebrew- purple?style=for-the-badge&logo=homebrew" alt="Homebrew"></a>
    <a href="#-installation"><img src="https://img.shields.io/badge/Install-AUR-1793D1?style=for-the-badge&logo=arch-linux" alt="AUR"></a>
    <a href="#-installation"><img src="https://img.shields.io/badge/Install-Docker-2496ED?style=for-the-badge&logo=docker" alt="Docker"></a>
  </p>

</div>

---

## Table of Contents

- [What is Trinity?](#-what-is-trinity)
- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [TRI CLI Commands](#-tri-cli-commands)
- [Architecture](#-architecture)
- [Development](#-development)
- [Ralph (Autonomous Development)](#-ralph-autonomous-development)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [License](#-license)

---

## What is Trinity?

**Trinity** is a sacred computing platform built on ternary logic {-1, 0, +1}. It combines:

- **VSA** — Vector Symbolic Architecture for hyperdimensional computing
- **VM** — Ternary Virtual Machine with 41 sacred opcodes
- **DePIN** — Decentralized Physical Infrastructure Network for AI inference
- **VIBEE** — Specification-first compiler (Zig, Verilog, Python)
- **TRINITY OS** — Complete operating system (v1.0)

### The Sacred Mathematics

```
                    +1
                   -1 +1
                  +1  0 +1
                 -1 +1 +1 -1
             ═════════════════════
            ▐ T R I N I T Y ▌  φ² + 1/φ² = 3
             ═════════════════════

    φ = 1.618033988749... (Golden Ratio)
    φ² + 1/φ² = 3 (Trinity Identity)
    3²¹ = 10,460,353,203 ($TRI total supply)
```

**Why ternary?** Radix-3 is the optimal integer base (closest to *e* = 2.718):

| Metric | Float32 | Ternary | Savings |
|--------|---------|---------|---------|
| Memory per weight | 32 bits | 1.58 bits | **20x** |
| Compute | Multiply + Add | Add only | **10x** |
| 70B model RAM | 280 GB | 14 GB | **20x** |

---

## Features

### For Users
- **Single command** for all development workflows
- **134+ CLI commands** covering AI, math, chemistry, git, and more
- **Multi-language support** — English, Russian, Chinese (auto-detected)
- **Interactive REPL** — `tri` for real-time interaction

### For Developers
- **Specification-first development** — VIBEE generates code from `.vibee` specs
- **Code generation** for Zig, Verilog (FPGA), and Python
- **Self-improving compiler** (V7) — analyzes and patches itself
- **Ralph autonomous development** — AI-powered continuous improvement

### For Node Operators
- **DePIN rewards** for useful work (Proof-of-Useful-Work)
- **Stake-based API tiers** — your wallet is your identity
- **Docker deployment** — one-command node setup

---

## Installation

### Quick Install (v1.0.1 PURITY)

| Package Manager | Command |
|----------------|---------|
| **npm** | `npm install -g @playra/tri` |
| **Homebrew** | `brew tap gHashTag/trinity && brew install trinity` |
| **AUR** | `yay -S trinity-cli` or `paru -S trinity-cli` |
| **Docker** | `docker pull ghcr.io/ghashtag/trinity-node:latest` |

### Build from Source

```bash
# Clone repository
git clone https://github.com/gHashTag/trinity.git
cd trinity

# Build TRI CLI
zig build tri

# Install globally
sudo cp zig-out/bin/tri /usr/local/bin/
```

**Requirements:** Zig 0.15.x

### Verify Installation

```bash
tri --version
# Trinity v1.0.1 PURITY — Sacred Intelligence CLI

tri constants
# φ = 1.618033988749...
# φ² + 1/φ² = 3
# Lucas: 2,1,3,4,7,11,18,29,47,76,123
```

---

## Quick Start

### Interactive REPL

```bash
tri                    # Start interactive mode
tri chat "Hello!"       # Chat with AI
tri code fibonacci      # Generate code
tri help                # All commands
```

### Golden Chain Workflow

```bash
# 1. Decompose task
tri decompose "Add user authentication"

# 2. Plan implementation
tri plan "Add user authentication"

# 3. Create specification
tri spec_create auth

# 4. Generate code from spec
tri gen specs/tri/auth.vibee

# 5. Verify tests
tri verify

# 6. Generate verdict
tri verdict

# 7. Continue or exit
tri loop-decide auto
```

### Sacred Mathematics

```bash
tri phi 10              # φ^10 = 122.991...
tri fib 100             # Fibonacci(100)
tri lucas 20            # Lucas L(20) = 15127
tri spiral 10           # φ-spiral coordinates
```

### Chemistry

```bash
tri chem periodic                           # ASCII periodic table
tri chem element Au                         # Gold details
tri chem mass H2O                           # Molar mass: 18.015 g/mol
tri chem balance "H2 + O2 -> H2O"           # Balance equations
tri chem ph 0.01 HCl                        # pH calculation
```

---

## TRI CLI Commands

### Core Commands (Link 1-6)

| Command | Description | Link |
|---------|-------------|------|
| `tri chat [--stream] <msg>` | Interactive chat (vision + voice) | - |
| `tri code [--stream] <prompt>` | Generate code | - |
| `tri gen <spec.vibee>` | Compile VIBEE spec | - |
| `tri pipeline run <task>` | Golden Chain (17 links) | 0-17 |
| `tri decompose <task>` | Break into sub-tasks | 4 |
| `tri plan <task>` | Implementation plan | 5 |
| `tri spec_create <name>` | Create .vibee template | 6 |
| `tri loop-decide [mode]` | Continue/EXIT decision | 17 |

### Verification Commands (Link 7-13)

| Command | Description |
|---------|-------------|
| `tri verify` | Run tests + benchmarks |
| `tri bench` | Performance benchmarks |
| `tri verdict` | Toxic verdict (self-assessment) |

### SWE Agent

| Command | Description |
|---------|-------------|
| `tri fix <file>` | Detect and fix bugs |
| `tri explain <file\|prompt>` | Explain code or concept |
| `tri test <file>` | Generate tests |
| `tri doc <file>` | Generate documentation |
| `tri refactor <file>` | Refactoring suggestions |
| `tri reason <prompt>` | Chain-of-thought reasoning |

### Git Integration

| Command | Description |
|---------|-------------|
| `tri status` | Git status --short |
| `tri diff` | Git diff |
| `tri log` | Git log --oneline -10 |
| `tri commit <message>` | Git add -A && commit |

### TVC (Distributed Learning)

| Command | Description |
|---------|-------------|
| `tri tvc-demo` | TVC chat demo |
| `tri tvc-stats` | Corpus statistics |

### Sacred Mathematics (v2.0)

| Command | Description |
|---------|-------------|
| `tri math` | Sacred math dispatcher |
| `tri constants` | φ, π, e, μ, χ, σ, ε... |
| `tri phi <n>` | φ^n calculation |
| `tri fib <n>` | Fibonacci with BigInt |
| `tri lucas <n>` | Lucas L(n) — L(2)=3 |
| `tri spiral <n>` | φ-spiral coordinates |

### Chemistry (v6.0)

| Command | Description |
|---------|-------------|
| `tri chem periodic` | ASCII periodic table (118 elements) |
| `tri chem element <sym\|num>` | Element information |
| `tri chem mass <formula>` | Molar mass |
| `tri chem formula <formula>` | Analyze composition |
| `tri chem balance <eq>` | Balance equation |
| `tri chem moles <mass> <form>` | Moles, molecules, atoms |
| `tri chem atoms <moles> <form>` | Atom counts |
| `tri chem ideal-gas <P>=<V>=<n>=<T>` | PV=nRT solver |
| `tri chem ph <conc\|acid> <M>` | pH calculation |
| `tri chem redox <reaction>` | Balance redox |

### Demo & Benchmark Commands

Each cycle has `-demo` and `-bench` variants:

| Cycle | Commands | Description |
|-------|----------|-------------|
| Multi-Agent | `tri agents-demo`, `tri agents-bench` | Coordination |
| Long Context | `tri context-demo`, `tri context-bench` | Sliding window |
| RAG | `tri rag-demo`, `tri rag-bench` | Retrieval |
| Voice I/O | `tri voice-demo`, `tri voice-bench` | STT+TTS |
| Code Sandbox | `tri sandbox-demo`, `tri sandbox-bench` | Safe execution |
| Streaming | `tri stream-demo`, `tri stream-bench` | Multi-modal pipeline |
| Vision | `tri vision-demo`, `tri vision-bench` | Image analysis |
| Fine-tuning | `tri finetune-demo`, `tri finetune-bench` | Model adaptation |
| Multi-Modal | `tri multimodal-demo`, `tri multimodal-bench` | Unified |
| Tool Use | `tri tooluse-demo`, `tri tooluse-bench` | Tools from any modality |
| Unified Agent | `tri unified-demo`, `tri unified-bench` | All capabilities |
| Autonomous | `tri auto-demo`, `tri auto-bench` | Self-directed |
| Orchestration | `tri orch-demo`, `tri orch-bench` | Coordinator+specialists |
| MM Orchestration | `tri mmo-demo`, `tri mmo-bench` | Multi-modal agents |
| Memory | `tri memory-demo`, `tri memory-bench` | Cross-modal learning |
| Persistent | `tri persist-demo`, `tri persist-bench` | Disk serialization |
| Spawn | `tri spawn-demo`, `tri spawn-bench` | Dynamic agents |
| Cluster | `tri cluster-demo`, `tri cluster-bench` | Multi-node |
| Work-Stealing | `tri worksteal-demo`, `tri worksteal-bench` | Adaptive scheduler |
| Plugin | `tri plugin-demo`, `tri plugin-bench` | Extension system |
| Comms | `tri comms-demo`, `tri comms-bench` | Communication protocol |
| Observe | `tri observe-demo`, `tri observe-bench` | Observability |
| Consensus | `tri consensus-demo`, `tri consensus-bench` | Coordination |
| Spec Exec | `tri specexec-demo`, `tri specexec-bench` | Speculative execution |
| Governor | `tri governor-demo`, `tri governor-bench` | Resource governor |
| Fed Learn | `tri fedlearn-demo`, `tri fedlearn-bench` | Federated learning |
| Event Src | `tri eventsrc-demo`, `tri eventsrc-bench` | Event sourcing |
| Cap Sec | `tri capsec-demo`, `tri capsec-bench` | Capability security |
| DTXN | `tri dtxn-demo`, `tri dtxn-bench` | Distributed transactions |
| Cache | `tri cache-demo`, `tri cache-bench` | Adaptive caching |
| Contract | `tri contract-demo`, `tri contract-bench` | Agent negotiation |
| Workflow | `tri workflow-demo`, `tri workflow-bench` | Temporal workflows |

### Info Commands

| Command | Description |
|---------|-------------|
| `tri info` | System information |
| `tri version` | Show version |
| `tri help` | This help message |

---

## Architecture

### Core VSA System

| Module | Purpose |
|--------|---------|
| `src/vsa.zig` | Bind, unbind, bundle, similarity |
| `src/vm.zig` | Ternary Virtual Machine |
| `src/hybrid.zig` | HybridBigInt (1.58 bits/trit) |
| `src/packed_trit.zig` | Bit-packed ternary encoding |
| `src/sdk.zig` | High-level API |

### VIBEE Compiler

| Module | Location | Purpose |
|--------|----------|---------|
| `root.zig` | `trinity-nexus/lang/src/` | Module exports (v0.2.0) |
| `vibee_parser.zig` | `trinity-nexus/lang/src/` | Parse .vibee specs |
| `zig_codegen.zig` | `trinity-nexus/lang/src/` | Generate Zig code |
| `verilog_codegen.zig` | `trinity-nexus/lang/src/` | Generate Verilog (FPGA) |
| `lang_generators.zig` | `trinity-nexus/lang/src/` | Multi-language generators |
| `codegen/` | `trinity-nexus/lang/src/` | 141+ code patterns |
| `gen_cmd.zig` | `src/vibeec/` | CLI entry point |

### Firebird LLM Engine

| Module | Purpose |
|--------|---------|
| `src/firebird/cli.zig` | Command-line interface |
| `src/firebird/b2t_integration.zig` | BitNet-to-Ternary |
| `src/firebird/wasm_parser.zig` | WebAssembly loading |
| `src/firebird/depin.zig` | DePIN reward engine |

### DePIN Node

| Module | Purpose |
|--------|---------|
| `src/trinity_node/main.zig` | Node entry point |
| `src/trinity_node/http_api.zig` | REST API |
| `src/trinity_node/token_staking.zig` | Staking + slashing |
| `src/trinity_node/storage.zig` | Erasure-coded storage |

### Project Structure

```
trinity/
├── src/                    # Core Zig source
│   ├── vsa.zig             # Vector Symbolic Architecture
│   ├── vm.zig              # Ternary Virtual Machine
│   ├── hybrid.zig          # HybridBigInt (1.58 bits/trit)
│   ├── tri/                # TRI CLI (main, commands, utils)
│   ├── firebird/           # LLM engine + DePIN
│   ├── vibeec/             # VIBEE compiler CLI
│   ├── trinity_node/       # DePIN node
│   ├── sacred/             # Sacred math + chemistry
│   └── agent_mu/           # Production swarm runtime
├── trinity-nexus/lang/     # VIBEE compiler (source of truth)
├── specs/tri/              # .vibee specifications
├── docsite/                # Docusaurus documentation
├── website/                # Landing page (Vite + React)
├── .ralph/                 # Ralph autonomous development
└── build.zig               # Build system
```

---

## Development

### Build Commands

```bash
zig build                    # Build all targets
zig build tri                # TRI CLI
zig build vibee              # VIBEE compiler
zig build firebird           # Firebird LLM
zig build test               # Run all tests
zig build bench              # Benchmarks
zig build release            # Cross-platform releases
zig fmt src/                 # Format code
```

### VIBEE Workflow (Specification-First)

```bash
# 1. Create specification
cat > specs/tri/feature.vibee << 'EOF'
name: feature
version: "1.0.0"
language: zig
module: feature

types:
  MyType:
    fields:
      name: String

behaviors:
  - name: my_func
    given: Input
    when: Action
    then: Result
EOF

# 2. Generate code
zig build vibee -- gen specs/tri/feature.vibee

# 3. Test
zig test trinity/output/feature.zig

# 4. Write toxic verdict
tri verdict

# 5. Commit
tri commit "feat: add feature"
```

### KOSCHEI Development Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                    KOSCHEI DEVELOPMENT LOOP                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. ANALYZE task requirements                                   │
│           ↓                                                     │
│  2. CREATE .vibee specification in specs/tri/                   │
│           ↓                                                     │
│  3. RUN: zig build vibee -- gen specs/tri/feature.vibee         │
│           ↓                                                     │
│  4. TEST: zig test trinity/output/feature.zig                   │
│           ↓                                                     │
│  5. CHECK: All tests passing?                                   │
│           ↓                                                     │
│     YES → Write TOXIC VERDICT + TECH TREE SELECT → EXIT         │
│     NO  → ITERATE (go to step 2)                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Critical Rule:** NEVER write `.zig` code directly — always generate from `.vibee` specifications (except `src/vibeec/*.zig` compiler source).

---

## Ralph (Autonomous Development)

Trinity uses **Ralph** for sustained autonomous development:

```bash
# Install Ralph
git clone https://github.com/frankbria/ralph-claude-code.git
cd ralph-claude-code && ./install.sh

# Run Ralph with monitoring
ralph --monitor
```

### What Ralph Does

| Without Ralph | With Ralph |
|--------------|-----------|
| Manual quality checks | Automated gates (build + test + format) |
| Forget to update tech tree | Tree updated every cycle |
| Repeat past mistakes | REGRESSION_PATTERNS.md consulted |
| No structured progress | fix_plan.md + TECH_TREE.md tracking |
| Commits to main | Feature branches enforced |

### Ralph Configuration

```
.ralph/
├── PROMPT.md              # Autonomous work instructions
├── AGENT.md               # Build/test/run commands
├── RULES.md               # Development guardrails
├── TECH_TREE.md            # Tech tree navigation
├── fix_plan.md             # Current sprint tasks
├── SUCCESS_HISTORY.md      # Working patterns
├── REGRESSION_PATTERNS.md  # Anti-patterns
└── memory/                # Success/failure patterns
```

[→ Ralph Documentation](./.ralph/README.md)

---

## Documentation

| Resource | URL |
|----------|-----|
| **Full Docs** | [gHashTag.github.io/trinity/docs](https://gHashTag.github.io/trinity/docs) |
| **Research** | [gHashTag.github.io/trinity/docs/research](https://gHashTag.github.io/trinity/docs/research) |
| **Benchmarks** | [gHashTag.github.io/trinity/docs/benchmarks](https://gHashTag.github.io/trinity/docs/benchmarks) |
| **API Reference** | [gHashTag.github.io/trinity/docs/api](https://gHashTag.github.io/trinity/docs/api) |
| **Website** | [gHashTag.github.io/trinity](https://gHashTag.github.io/trinity) |

### Key Documentation Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Full project instructions for Claude Code |
| `AGENTS.md` | AI agent guidelines + Golden Chain workflow |
| `CONTRIBUTING.md` | Contribution guidelines |
| `LICENSE` | MIT License |

---

## Contributing

We welcome contributions! Please:

1. Read [CONTRIBUTING.md](./CONTRIBUTING.md)
2. Read [AGENTS.md](./AGENTS.md) for VIBEE workflow
3. Use **specification-first** development (never write .zig directly)
4. Run `zig build test` before submitting PRs
5. Follow the Golden Chain workflow

### Development Cycle

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Create specification
tri spec_create my_feature

# 3. Edit spec in specs/tri/my_feature.vibee
# 4. Generate code
tri gen specs/tri/my_feature.vibee

# 5. Test
zig test trinity/output/my_feature.zig

# 6. Commit and push
tri commit "feat: add my feature"
git push origin feature/my-feature
```

### Exit Criteria

```
EXIT_SIGNAL = (
    tests_pass AND
    spec_complete AND
    toxic_verdict_written AND
    tech_tree_options_proposed AND
    achievement_documented AND
    committed
)
```

---

## License

MIT © 2024-2026 Dmitrii Vasilev

[View License](./LICENSE)

---

<div align="center">

  **φ² + 1/φ² = 3 = TRINITY**

  <sub>Built with sacred mathematics & ternary computing</sub>

  <p>
    <a href="https://github.com/gHashTag/trinity">GitHub</a> •
    <a href="https://gHashTag.github.io/trinity/docs">Documentation</a> •
    <a href="https://github.com/gHashTag/trinity/issues">Issues</a> •
    <a href="https://github.com/gHashTag/trinity/discussions">Discussions</a>
  </p>

</div>
