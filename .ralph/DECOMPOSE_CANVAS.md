# Decomposing photon_trinity_canvas.zig

This document outlines the architectural strategy for decomposing the massive 10,000+ line `photon_trinity_canvas.zig` monolith into a scalable, modular structure under `trinity-nexus/canvas/src/`.

## 1. Target Directory Structure
To adhere to the principles of modularity and separation of concerns, the code will be distributed logically:

```text
trinity-nexus/canvas/src/
├── photon_trinity_canvas.zig     // Main entry point, minimal wiring (Init/Main Loop)
├── core/                         // Core definitions and global context
│   ├── types.zig                 // Shared Enums (WaveMode, ChatMsgType)
│   ├── state.zig                 // Global state context (DPI, Chat History, Scroll)
│   └── constants.zig             // Colors, dimensions, timeouts
├── engine/                       // Non-visual business logic
│   ├── chat_engine.zig           // Interface to IglaLocalChat / FluentChatEngine
│   ├── swarm_agents.zig          // Immortal Agent Swarm tracking logic
│   ├── ralph/                    // NATIVE RALPH CORE (Golden Chain implementation)
│   │   ├── links.zig             // Tri-Decompose, Tri-Plan, Tri-Verdict, etc.
│   │   ├── orchestrator.zig      // Main Loop native implementation
│   │   └── protocol.zig          // Communication with Claude Code / Gatekeeping
│   └── tools_api.zig             // Sub-system calls (Depin, Finder)
├── ui/                           // Rendering modules
│   ├── render_core.zig           // Core Raylib/Raygui abstractions & DPI scaling
│   ├── view_chat.zig             // Rendering logic for conversational UI
│   ├── view_tools.zig            // Rendering logic for tool panels and grid
│   ├── view_code.zig             // Rendering code editor / debug views
│   └── components/               // Reusable atomic UI elements
│       ├── button.zig
│       ├── pills.zig
│       ├── waves.zig             // Animated background shader/drawing logic
│       └── layouts.zig           // Flex / grid positioning utilities
└── state_machine/                // High-level routing
    └── transitions.zig           // Logic for switching & animating between WaveModes
```

## 2. Step-by-Step Migration Plan

### Phase 1: Foundation (Types & Constants)
- Extract pure data structures: `WaveMode`, `ChatMsgType`.
- Extract constant values (e.g., `MAX_CHAT_MSGS`, layout constants, hex colors) into `core/constants.zig`.
- **Goal:** Create a dependency-free foundation that other modules can import.

### Phase 2: Global State Encapsulation
- Currently, variables like `g_chat_messages`, `g_dpi_scale`, and `g_chat_scroll_y` are defined at the top level.
- Move these into a centralized `CanvasState` struct inside `core/state.zig`. This context will be initialized in `main()` and passed (by reference) to UI and Engine functions.

### Phase 3: UI Abstraction & Background (Waves)
- Isolate the animated wave background logic and generic drawing helpers into `ui/components/waves.zig` and `ui/render_core.zig`.
- This includes managing font loading (`g_font_chat`, `g_font_emoji`) and making them accessible securely.

### Phase 4: Feature View Extraction
Decompose the massive `draw_` / `update_` functions based on their active mode:
- `ui/view_chat.zig`: Handles rendering the message stream, input box, and parsing message types like `.chain_decompose`, `.immortal_persist`.
- `ui/view_tools.zig`: Handles the tool cards/pills (Vision, Finder, Ralph).

### Phase 5: Engine Logic & Native Ralph
- Move all business logic related to generating chat responses, polling for tools, and managing swarm phases out of the UI rendering loop into the `engine/` directory.
- **Native Ralph Integration**: Port `ralph_loop.sh` logic into `engine/ralph/`. 
  - Rewrite the 9 Golden Links as Zig modules.
  - Integrate `.ralph/gate.sh` logic into `links.zig`.
  - Ensure the UI renders the native Ralph telemetry instead of just watching file changes.

### Phase 6: Refactoring the Entry Point
- Rewrite `photon_trinity_canvas.zig` to serve exclusively as the `main()` function:
  1. Bootstraps Raylib window + Fonts.
  2. Initializes `CanvasState`.
  3. Runs `while (!rl.WindowShouldClose())` loop.
  4. Delegates to `transitions.update(state)` and the respective active `view.render(state)`.

## 3. Benefits of this Refactoring
- **Maintainability:** 10,000 lines reduced to 10-15 files of < 1,000 lines.
- **Compilation Speed:** Incremental compilation improves isolation.
- **Collaboration:** Easy to assign specific modules (e.g., `view_chat.zig` or `swarm_agents.zig`) to different developers or AI agents without merge conflicts.
