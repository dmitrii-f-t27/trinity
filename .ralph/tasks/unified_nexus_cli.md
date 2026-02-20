# TASK-001: Unified Nexus CLI Implementation

**Priority:** HIGH
**Status:** PENDING
**Domain:** TOOLS / CLI

## Description
Develop a high-performance, unified CLI orchestrator for the Trinity Nexus ecosystem. The tool, tentatively named `tri`, should act as a single entry point for all system modules, replacing the fragmented shell scripts and legacy build-step commands.

## Requirements
1.  **Command Dispatcher**: Implement a subcommand-based router in `trinity-nexus/tools/src/cli/tri_cmd.zig`.
2.  **Legacy Proxy**: Port all commands from root `build.zig` (e.g., `query`, `search`, `node`) into `tri <command>`.
3.  **Module Integration**:
    - `tri ralph`: Native integration with `core.ralph.engine`.
    - `tri canvas`: Launch the modular Photon UI.
    - `tri build`: Optimize and run `zig build` with custom caching.
4.  **Telemetry**: Every command must report status to the `.ralph/status_report.json` via the `core.ralph.telemetry` module.
5.  **Maxwell Sync**: Integrate with the Maxwell speculation agent to provide context-aware help.

## Verification
- `zig build test-tools` passes.
- `tri --help` lists all subcommands correctly.
- `tri ralph --status` returns native JSON status.
