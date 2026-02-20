# Trinity Nexus: Unified System Map

This document serves as the "source of truth" for the Trinity Nexus modular architecture, capturing all domains, modules, and commands within the ecosystem.

## 1. Modular Architecture (Domains)

### [CORE] - Foundation Layer
*Location: `trinity-nexus/core/`*
- **VSA**: High-performance Vector Symbolic Architecture operations.
- **JIT**: ARM64-optimized JIT compiler for VSA and BigInt.
- **VM**: Ternary Virtual Machine (Trit-based architecture).
- **BigInt**: Hybrid fixed/dynamic size BigInt implementation.
- **Ralph Core**: Native implementation of the autonomous engine.

### [LANG] - Language Layer
*Location: `trinity-nexus/lang/`*
- **Coptic**: High-level binary/ternary language layer.
- **Bytecode**: Dense intermediate representation for the Trinity VM.
- **Parser**: Multi-dialect parser (Vibee, Coptic).

### [CANVAS] - Visualization & UI Layer
*Location: `trinity-nexus/canvas/`*
- **Photon**: Emergent AI visualization engine (shader-based).
- **Trinity UI**: Decentralized UI framework using Raylib/Raygui.
- **Views**: Specialized rendering modules (Chat, Ralph Monitor, Code).

### [TOOLS] - Agentic & Development Layer
*Location: `trinity-nexus/tools/`*
- **Maxwell**: Autonomous code analysis and speculation agent.
- **Phi-Engine**: Golden Chain logic and recursive self-improvement loops.
- **DevTools**: LSP server, Debugger, Profiler, Antipattern Detector.
- **CLI Ecosystem**: REPLs, evolved agents, and unified command dispatchers.

---

## 2. Command Registry (The Unified Interface)

The **Trinity Nexus CLI (`tri`)** aims to unify all legacy and nexus commands under a single dispatch system.

### Core Commands
- `tri version`: Display version and module metadata.
- `tri update`: Synchronize all nexus modules with the global state.

### Agentic Commands
- `tri ralph`: Launch the Ralph Autonomous Monitor (Native Core).
- `tri maxwell`: Initiate codebase spec speculation and analysis.
- `tri phi`: Start the Golden Chain recursive loop.

### Development & Build
- `tri build`: Wrapper for `zig build` with nexus-specific optimizations.
- `tri test`: Run unified test suites across all domains.
- `tri bench`: Execute the full matrix benchmark suite.
- `tri format`: Apply Trinity-standard formatting to Zig and Vibee files.

### Tools & Utilities
- `tri query`: Semantic search across the Knowledge Graph.
- `tri node`: Launch a decentralized Trinity Inference Node.
- `tri swarm`: Coordinate a production agent cluster.

---

## 3. Ralph Development Task: Unified CLI Orchestrator

**Status:** PENDING
**Assigned to:** RALPH (Native Core)
**Description:** Implement the unified command dispatcher in `trinity-nexus/tools/src/cli/tri_cmd.zig` that dynamically routes subcommands to their respective module implementations with consistent argument parsing and telemetry reporting.

### Objectives:
1. Port all legacy subcommands from the root `build.zig` to the `tri` dispatcher.
2. Implement auto-discovery of Nexus modules via the `trinity-core` metadata.
3. Integrate `maxwell_agent_loop` for spec-aware command hints.
4. Ensure 100% compatibility with existing shell aliases (`ralph`, `vibee`, `tri`).
