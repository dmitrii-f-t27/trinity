//! FPGA MCP Tools — wraps `tri fpga` CLI subcommands
//! Pattern: follows cloud_tools.zig (runTriCloud -> runTriFpga)
//!
//! Exposed tools:
//!   fpga_uart_scan     — tri fpga uart scan
//!   fpga_uart_ping     — tri fpga uart ping <device>
//!   fpga_power_flash   — tri fpga power flash
//!   fpga_power_measure — tri fpga power measure <device>
//!   fpga_power_report  — tri fpga power report
//!   fpga_synth_validate — tri fpga synth-validate [module]

const std = @import("std");

var global_arena: std.heap.ArenaAllocator = undefined;
var arena_initialized = false;

fn getAllocator() std.mem.Allocator {
    if (!arena_initialized) {
        global_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        arena_initialized = true;
    }
    return global_arena.allocator();
}

/// Run `tri fpga <args...>` and return stdout (or error string)
fn runTriFpga(buf: []u8, args: []const []const u8) []const u8 {
    const allocator = getAllocator();

    // Build argv: ["tri", "fpga"] ++ args
    var argv = std.ArrayList([]const u8).init(allocator);
    defer argv.deinit();
    argv.append("tri") catch return copyToBuffer(buf, "error: OOM");
    argv.append("fpga") catch return copyToBuffer(buf, "error: OOM");
    for (args) |a| {
        argv.append(a) catch return copyToBuffer(buf, "error: OOM");
    }

    var child = std.process.Child.init(argv.items, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    child.spawn() catch |err| {
        const msg = std.fmt.bufPrint(buf, "error: spawn tri failed: {}", .{err}) catch buf;
        return msg;
    };

    const stdout = child.stdout.?.reader().readAllAlloc(allocator, 256 * 1024) catch
        return copyToBuffer(buf, "error: read stdout failed");
    defer allocator.free(stdout);
    const stderr = child.stderr.?.reader().readAllAlloc(allocator, 16 * 1024) catch "";
    defer if (stderr.len > 0) allocator.free(stderr);
    _ = child.wait() catch {};

    const output = if (stdout.len > 0) stdout else stderr;
    return copyToBuffer(buf, output);
}

fn copyToBuffer(buf: []u8, src: []const u8) []const u8 {
    const n = @min(src.len, buf.len - 1);
    @memcpy(buf[0..n], src[0..n]);
    buf[n] = 0;
    return buf[0..n];
}

// ============================================================
// Public MCP tool functions
// ============================================================

/// Scan for connected CH340/FTDI UART devices on /dev/tty.*
pub fn fpgaUartScan(buf: []u8) []const u8 {
    return runTriFpga(buf, &.{ "uart", "scan" });
}

/// Ping FPGA via UART — sends 0x03, expects 0x83 PONG
/// device: e.g. "/dev/tty.wchusbserial10"
pub fn fpgaUartPing(buf: []u8, device: []const u8) []const u8 {
    return runTriFpga(buf, &.{ "uart", "ping", device });
}

/// Send raw hex bytes to FPGA, print response
/// device: serial port, hex: e.g. "AA1042"
pub fn fpgaUartSend(buf: []u8, device: []const u8, hex: []const u8) []const u8 {
    return runTriFpga(buf, &.{ "uart", "send", device, hex });
}

/// Synthesize and flash power_modes.v via Docker openXC7 + JTAG
pub fn fpgaPowerFlash(buf: []u8) []const u8 {
    return runTriFpga(buf, &.{ "power", "flash" });
}

/// Run power measurement across all 5 modes and collect watt readings
/// device: serial port connected to FPGA UART
pub fn fpgaPowerMeasure(buf: []u8, device: []const u8) []const u8 {
    return runTriFpga(buf, &.{ "power", "measure", device });
}

/// Generate power_results.md markdown table from collected measurements
pub fn fpgaPowerReport(buf: []u8) []const u8 {
    return runTriFpga(buf, &.{ "power", "report" });
}

/// Run Yosys synthesis validation via Docker openXC7
/// module: optional specific module name (null = all 10 targets)
pub fn fpgaSynthValidate(buf: []u8, module: ?[]const u8) []const u8 {
    if (module) |m| {
        return runTriFpga(buf, &.{ "synth-validate", m });
    }
    return runTriFpga(buf, &.{"synth-validate"});
}
