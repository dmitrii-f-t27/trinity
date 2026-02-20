const std = @import("std");

pub const RalphConfig = struct {
    max_calls_per_hour: u32 = 100,
    prompt_file: []const u8 = ".ralph/PROMPT.md",
    timeout_minutes: u32 = 30,
    live_mode: bool = true,
};

pub const RalphStatus = enum {
    idle,
    running,
    blocked,
    waiting_reset,
};

pub const RalphEngine = struct {
    allocator: std.mem.Allocator,
    config: RalphConfig,
    status: RalphStatus = .idle,
    call_count: u32 = 0,
    last_reset: i64 = 0,

    pub fn init(allocator: std.mem.Allocator, config: RalphConfig) RalphEngine {
        return .{
            .allocator = allocator,
            .config = config,
            .last_reset = std.time.timestamp(),
        };
    }

    pub fn checkRateLimit(self: *RalphEngine) bool {
        const now = std.time.timestamp();
        if (now - self.last_reset >= 3600) {
            self.call_count = 0;
            self.last_reset = now;
        }
        return self.call_count < self.config.max_calls_per_hour;
    }

    pub fn startCycle(self: *RalphEngine) !void {
        if (!self.checkRateLimit()) {
            self.status = .waiting_reset;
            return error.RateLimitReached;
        }
        self.status = .running;
        // Logic to spawn Claude CLI will go here
    }
};
