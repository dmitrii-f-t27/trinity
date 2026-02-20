const std = @import("std");

pub const StatusReport = struct {
    timestamp: []const u8,
    loop_count: u32,
    calls_made_this_hour: u32,
    max_calls_per_hour: u32,
    last_action: []const u8,
    status: []const u8,
    exit_reason: []const u8 = "",
    next_reset: []const u8,

    pub fn save(self: StatusReport, allocator: std.mem.Allocator, path: []const u8) !void {
        _ = allocator;
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        try std.json.stringify(self, .{}, file.writer());
    }
};

pub const ProgressReport = struct {
    completed_tasks: u32,
    total_tasks: u32,
    current_task: []const u8,

    pub fn save(self: ProgressReport, allocator: std.mem.Allocator, path: []const u8) !void {
        _ = allocator;
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        try std.json.stringify(self, .{}, file.writer());
    }
};
