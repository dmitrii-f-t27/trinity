//! Telegram Reporter via OpenClaw
//! Sends Ralph status updates to Telegram using OpenClaw gateway

const std = @import("std");
const Allocator = std.mem.Allocator;
const process = @import("process.zig");

pub const TelegramConfig = struct {
    enabled: bool,
    chat_id: []const u8,
    openclaw_bin: []const u8,

    pub fn default() TelegramConfig {
        return .{
            .enabled = true,
            .chat_id = "144022504",
            .openclaw_bin = "node /Users/playra/openclaw/openclaw.mjs",
        };
    }

    pub fn fromEnv(allocator: Allocator) !TelegramConfig {
        const enabled = std.process.getEnvVarOwned(allocator, "RALPH_REPORT_ENABLED") catch blk: {
            break :blk true;
        };
        defer if (enabled) |v| allocator.free(v);

        const chat_id = std.process.getEnvVarOwned(allocator, "RALPH_TELEGRAM_CHAT_ID") catch blk: {
            break :blk "144022504";
        };
        defer if (chat_id) |v| allocator.free(v);

        const openclaw = std.process.getEnvVarOwned(allocator, "OPENCLAW_BIN") catch blk: {
            break :blk "node /Users/playra/openclaw/openclaw.mjs";
        };
        defer if (openclaw) |v| allocator.free(v);

        return TelegramConfig{
            .enabled = std.mem.eql(u8, enabled.?, "true") or std.mem.eql(u8, enabled.?, "1"),
            .chat_id = try allocator.dupe(u8, chat_id.?),
            .openclaw_bin = try allocator.dupe(u8, openclaw.?),
        };
    }
};

pub const Event = enum {
    gate_pass,
    gate_fail,
    commit,
    circuit_open,
    circuit_close,
    loop_start,
    loop_end,
    verdict,
    status,
    custom,
};

pub const EventContext = struct {
    branch: []const u8 = "unknown",
    sha: []const u8 = "??????",
    gate_name: []const u8 = "",
    commit_message: []const u8 = "",
    loop_number: u32 = 0,
    verdict_text: []const u8 = "",
    custom_message: []const u8 = "",

    pub fn deinit(self: *EventContext, allocator: Allocator) void {
        // All slices are assumed to be string literals or owned elsewhere
        _ = allocator;
        _ = self;
    }
};

/// Send a Telegram notification
/// Gracefully fails if OpenClaw is unavailable (logs warning but doesn't error)
pub fn send(allocator: Allocator, config: TelegramConfig, event: Event, ctx: EventContext) !void {
    if (!config.enabled) {
        return;
    }

    const message = try formatMessage(allocator, event, ctx);
    defer allocator.free(message);

    // Build OpenClaw command
    const openclaw_parts = try std.ArrayList([]const u8).initCapacity(allocator, 10);
    defer {
        for (openclaw_parts.items) |part| {
            if (part.len > 0 and part[0] != '-' and part[0] != 'n') {
                // Skip freeing string literals
                allocator.free(part);
            }
        }
        openclaw_parts.deinit(allocator);
    }

    // Parse openclaw_bin into parts (e.g., "node /path/to/openclaw.mjs" -> ["node", "/path/to/openclaw.mjs"])
    var iter = std.mem.splitScalar(u8, config.openclaw_bin, ' ');
    while (iter.next()) |part| {
        if (part.len > 0) {
            try openclaw_parts.append(try allocator.dupe(u8, part));
        }
    }

    try openclaw_parts.append("message");
    try openclaw_parts.append("send");
    try openclaw_parts.append("--channel");
    try openclaw_parts.append("telegram");
    try openclaw_parts.append("--target");
    try openclaw_parts.append(config.chat_id);
    try openclaw_parts.append("--message");
    try openclaw_parts.append(message);
    try openclaw_parts.append("--silent");

    const result = process.run(allocator, openclaw_parts.items) catch |err| {
        std.log.warn("Failed to send Telegram notification: {}", .{err});
        return;
    };
    defer result.deinit(allocator);

    if (result.exit_code != 0) {
        std.log.warn("OpenClaw returned non-zero exit code: {s}", .{result.stderr});
    }
}

/// Format message based on event type
fn formatMessage(allocator: Allocator, event: Event, ctx: EventContext) ![]const u8 {
    return switch (event) {
        .gate_pass => std.fmt.allocPrint(allocator,
            \\**✅ RALPH GATE PASSED**
            \\Branch: `{s}`
            \\SHA: `{s}`
            \\Build + Test + Format: ALL GREEN
        , .{ ctx.branch, ctx.sha }),

        .gate_fail => std.fmt.allocPrint(allocator,
            \\**❌ RALPH GATE FAILED**
            \\Branch: `{s}`
            \\SHA: `{s}`
            \\Failed at: **{s}**
        , .{ ctx.branch, ctx.sha, ctx.gate_name }),

        .commit => std.fmt.allocPrint(allocator,
            \\**📦 RALPH COMMIT**
            \\Branch: `{s}`
            \\SHA: `{s}`
            \\Message: {s}
        , .{ ctx.branch, ctx.sha, ctx.commit_message }),

        .circuit_open => std.fmt.allocPrint(allocator,
            \\**🔴 CIRCUIT BREAKER OPEN**
            \\Branch: `{s}`
            \\Reason: {s}
            \\Ralph is cooling down...
        , .{ ctx.branch, ctx.gate_name }),

        .circuit_close => std.fmt.allocPrint(allocator,
            \\**🟢 CIRCUIT BREAKER CLOSED**
            \\Branch: `{s}`
            \\Ralph resumed normal operation.
        , .{ctx.branch}),

        .loop_start => std.fmt.allocPrint(allocator,
            \\**🔄 RALPH LOOP {d} STARTED**
            \\Branch: `{s}`
            \\SHA: `{s}`
        , .{ ctx.loop_number, ctx.branch, ctx.sha }),

        .loop_end => std.fmt.allocPrint(allocator,
            \\**⏹ RALPH LOOP ENDED**
            \\Branch: `{s}`
            \\SHA: `{s}`
        , .{ ctx.branch, ctx.sha }),

        .verdict => std.fmt.allocPrint(allocator,
            \\**⚖️ TOXIC VERDICT**
            \\Branch: `{s}`
            \\{s}
        , .{ ctx.branch, ctx.verdict_text }),

        .status => std.fmt.allocPrint(allocator,
            \\**📊 RALPH STATUS REPORT**
            \\Branch: `{s}`
            \\SHA: `{s}`
            \\{s}
        , .{ ctx.branch, ctx.sha, ctx.custom_message }),

        .custom => allocator.dupe(u8, ctx.custom_message),
    };
}

/// Convenience function for gate_pass event
pub fn sendGatePass(allocator: Allocator, config: TelegramConfig, branch: []const u8, sha: []const u8) !void {
    try send(allocator, config, .gate_pass, .{
        .branch = branch,
        .sha = sha,
    });
}

/// Convenience function for gate_fail event
pub fn sendGateFail(allocator: Allocator, config: TelegramConfig, branch: []const u8, sha: []const u8, gate_name: []const u8) !void {
    try send(allocator, config, .gate_fail, .{
        .branch = branch,
        .sha = sha,
        .gate_name = gate_name,
    });
}

/// Convenience function for commit event
pub fn sendCommit(allocator: Allocator, config: TelegramConfig, branch: []const u8, sha: []const u8, message: []const u8) !void {
    try send(allocator, config, .commit, .{
        .branch = branch,
        .sha = sha,
        .commit_message = message,
    });
}

/// Convenience function for circuit_open event
pub fn sendCircuitOpen(allocator: Allocator, config: TelegramConfig, branch: []const u8, reason: []const u8) !void {
    try send(allocator, config, .circuit_open, .{
        .branch = branch,
        .gate_name = reason,
    });
}

/// Convenience function for verdict event
pub fn sendVerdict(allocator: Allocator, config: TelegramConfig, branch: []const u8, verdict: []const u8) !void {
    try send(allocator, config, .verdict, .{
        .branch = branch,
        .verdict_text = verdict,
    });
}

/// Convenience function for custom message
pub fn sendCustom(allocator: Allocator, config: TelegramConfig, message: []const u8) !void {
    try send(allocator, config, .custom, .{
        .custom_message = message,
    });
}

// ============================================================================
// Tests
// ============================================================================

test "telegram: format gate pass message" {
    const allocator = std.testing.allocator;

    const ctx = EventContext{
        .branch = "test-branch",
        .sha = "abc123",
    };

    const msg = try formatMessage(allocator, .gate_pass, ctx);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "GATE PASSED") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "test-branch") != null);
}

test "telegram: format gate fail message" {
    const allocator = std.testing.allocator;

    const ctx = EventContext{
        .branch = "test-branch",
        .sha = "abc123",
        .gate_name = "build",
    };

    const msg = try formatMessage(allocator, .gate_fail, ctx);
    defer allocator.free(msg);

    try std.testing.expect(std.mem.indexOf(u8, msg, "GATE FAILED") != null);
    try std.testing.expect(std.mem.indexOf(u8, msg, "**build**") != null);
}
