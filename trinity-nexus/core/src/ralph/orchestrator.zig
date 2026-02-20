const std = @import("std");
const engine = @import("engine.zig");
const telemetry = @import("telemetry.zig");
const gatekeeper = @import("gatekeeper.zig");

pub const RalphOrchestrator = struct {
    allocator: std.mem.Allocator,
    engine: engine.RalphEngine,
    gate: gatekeeper.Gatekeeper,

    pub fn init(allocator: std.mem.Allocator, config: engine.RalphConfig) RalphOrchestrator {
        return .{
            .allocator = allocator,
            .engine = engine.RalphEngine.init(allocator, config),
            .gate = gatekeeper.Gatekeeper{ .allocator = allocator },
        };
    }

    pub fn run(self: *RalphOrchestrator) !void {
        while (true) {
            // Check rate limit
            if (!self.engine.checkRateLimit()) {
                std.log.info("Rate limit reached, waiting...", .{});
                std.time.sleep(60 * std.time.ns_per_s);
                continue;
            }

            // Perform a cycle
            try self.engine.startCycle();

            // Execute Claude via child process
            // This is where we'd spawn "claude" and stream its output

            // Increment call count
            self.engine.call_count += 1;

            // Wait for next loop
            std.time.sleep(10 * std.time.ns_per_s);
        }
    }
};
