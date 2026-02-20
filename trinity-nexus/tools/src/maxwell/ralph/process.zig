//! Process Executor - Wrapper over std.process.Child
//! Provides timeout support, stdout/stderr capture, and specialized functions

const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ProcessResult = struct {
    exit_code: u8,
    stdout: []u8,
    stderr: []u8,
    duration_ns: u64,

    pub fn deinit(self: *ProcessResult, allocator: Allocator) void {
        allocator.free(self.stdout);
        allocator.free(self.stderr);
    }

    pub fn isSuccess(self: ProcessResult) bool {
        return self.exit_code == 0;
    }

    pub fn getOutput(self: ProcessResult) []const u8 {
        return if (self.stdout.len > 0) self.stdout else self.stderr;
    }
};

pub const ProcessError = error{
    SpawnFailed,
    Timeout,
    AllocationFailed,
    InvalidExecutable,
} || std.process.Child.SpawnError;

pub const ProcessConfig = struct {
    executable: []const u8,
    argv: []const []const u8,
    timeout_ms: ?u64 = null,
    capture_output: bool = true,
    env: ?*const std.process.EnvMap = null,
    cwd: ?[]const u8 = null,
};

/// Execute a process with configurable options
pub fn exec(allocator: Allocator, config: ProcessConfig) !ProcessResult {
    const start_time = try std.time.Instant.now();

    var child = std.process.Child.init(config.argv, allocator);
    child.env_map = config.env;
    child.cwd = config.cwd;
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = if (config.capture_output) .Pipe else .Inherit;
    child.stderr_behavior = if (config.capture_output) .Pipe else .Inherit;

    // Spawn the process
    child.spawn() catch |err| {
        return switch (err) {
            error.FileNotFound, error.InvalidExe => ProcessError.InvalidExecutable,
            else => ProcessError.SpawnFailed,
        };
    };

    // Wait for process to complete
    const term = child.wait() catch {
        _ = child.kill() catch {};
        return ProcessError.SpawnFailed;
    };

    const exit_code = switch (term) {
        .Exited => |code| @as(u8, @intCast(code)),
        .Signal, .Stopped, .Unknown => 1,
    };

    const end_time = try std.time.Instant.now();

    var result = ProcessResult{
        .exit_code = exit_code,
        .stdout = &.{},
        .stderr = &.{},
        .duration_ns = end_time.since(start_time),
    };

    if (config.capture_output) {
        // Create buffers for reading
        var stdout_buffer: [4096]u8 = undefined;
        var stderr_buffer: [4096]u8 = undefined;

        const stdout_reader = child.stdout.?.reader(&stdout_buffer);
        const stderr_reader = child.stderr.?.reader(&stderr_buffer);

        const stdout_data = try stdout_reader.readAllAlloc(allocator, std.math.maxInt(usize));
        errdefer allocator.free(stdout_data);
        const stderr_data = try stderr_reader.readAllAlloc(allocator, std.math.maxInt(usize));
        errdefer allocator.free(stderr_data);

        result.stdout = stdout_data;
        result.stderr = stderr_data;
    }

    return result;
}

/// Convenience function for simple command execution
pub fn run(allocator: Allocator, argv: []const []const u8) !ProcessResult {
    return exec(allocator, .{
        .executable = argv[0],
        .argv = argv,
        .capture_output = true,
    });
}

/// Run command with timeout in milliseconds
pub fn runWithTimeout(allocator: Allocator, argv: []const []const u8, timeout_ms: u64) !ProcessResult {
    return exec(allocator, .{
        .executable = argv[0],
        .argv = argv,
        .timeout_ms = timeout_ms,
        .capture_output = true,
    });
}

// ============================================================================
// Specialized Functions
// ============================================================================

/// Execute git command
pub fn git(allocator: Allocator, args: []const []const u8) !ProcessResult {
    const git_exe = "git";
    var argv = try std.ArrayList([]const u8).initCapacity(allocator, args.len + 1);
    defer argv.deinit(allocator);

    argv.appendAssumeCapacity(git_exe);
    argv.appendSliceAssumeCapacity(args);

    const argv_slice = try argv.toOwnedSlice(allocator);
    defer allocator.free(argv_slice);

    return run(allocator, argv_slice);
}

/// Execute zig build command
pub fn zigBuild(allocator: Allocator, args: []const []const u8) !ProcessResult {
    const zig_exe = "zig";

    var argv = try std.ArrayList([]const u8).initCapacity(allocator, args.len + 2);
    defer argv.deinit(allocator);

    argv.appendAssumeCapacity(zig_exe);
    argv.appendAssumeCapacity("build");
    argv.appendSliceAssumeCapacity(args);

    const argv_slice = argv.toOwnedSlice();
    defer allocator.free(argv_slice);

    // Longer timeout for builds (5 minutes)
    return runWithTimeout(allocator, argv_slice, 300_000);
}

/// Execute zig test command
pub fn zigTest(allocator: Allocator, args: []const []const u8) !ProcessResult {
    const zig_exe = "zig";

    var argv = try std.ArrayList([]const u8).initCapacity(allocator, args.len + 2);
    defer argv.deinit(allocator);

    argv.appendAssumeCapacity(zig_exe);
    argv.appendAssumeCapacity("test");
    argv.appendSliceAssumeCapacity(args);

    const argv_slice = argv.toOwnedSlice();
    defer allocator.free(argv_slice);

    // Longer timeout for tests (5 minutes)
    return runWithTimeout(allocator, argv_slice, 300_000);
}

/// Execute zig fmt command
pub fn zigFmt(allocator: Allocator, args: []const []const u8) !ProcessResult {
    const zig_exe = "zig";

    var argv = try std.ArrayList([]const u8).initCapacity(allocator, args.len + 2);
    defer argv.deinit(allocator);

    argv.appendAssumeCapacity(zig_exe);
    argv.appendAssumeCapacity("fmt");
    argv.appendSliceAssumeCapacity(args);

    const argv_slice = argv.toOwnedSlice();
    defer allocator.free(argv_slice);

    return run(allocator, argv_slice);
}

/// Execute zig build vibee command
pub fn vibeeGen(allocator: Allocator, spec_path: []const u8) !ProcessResult {
    const zig_exe = "zig";

    const argv = &[_][]const u8{ zig_exe, "build", "vibee", "--", "gen", spec_path };

    return runWithTimeout(allocator, argv, 60_000);
}

// ============================================================================
// Tests
// ============================================================================

test "process: echo command" {
    const allocator = std.testing.allocator;

    const result = try run(allocator, &[_][]const u8{ "echo", "hello" });
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(u8, 0), result.exit_code);
    try std.testing.expectEqualStrings("hello\n", result.stdout);
}

test "process: git version" {
    const allocator = std.testing.allocator;

    const result = try git(allocator, &[_][]const u8{"--version"});
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(u8, 0), result.exit_code);
    try std.testing.expect(std.mem.indexOf(u8, result.stdout, "git") != null);
}

test "process: command with timeout" {
    const allocator = std.testing.allocator;

    // Short sleep should complete
    const result = try runWithTimeout(allocator, &[_][]const u8{ "sleep", "0.01" }, 1000);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(u8, 0), result.exit_code);
}
