const std = @import("std");
const core = @import("trinity-core");
const core_ralph = core.ralph.engine;
const canvas_state = @import("../core/state.zig");

pub const RalphBridge = struct {
    engine: *core_ralph.RalphEngine,
    state: *canvas_state.CanvasState,

    pub fn sync(self: *RalphBridge) void {
        const agent = &self.state.ralph_agents[0];
        agent.total_calls = self.engine.call_count;
        agent.running = (self.engine.status == .running);
        // Additional sync logic for telemetry
    }
};
