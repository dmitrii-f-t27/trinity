const std = @import("std");

pub const Gatekeeper = struct {
    allocator: std.mem.Allocator,

    pub fn runGate(self: *Gatekeeper) !bool {
        var child = std.process.Child.init(&[_][]const u8{ "/bin/bash", ".ralph/gate.sh" }, self.allocator);
        const result = try child.spawnAndWait();
        return result.Exited == 0;
    }

    pub fn verifyCompilation(self: *Gatekeeper) !bool {
        var child = std.process.Child.init(&[_][]const u8{ "zig", "build" }, self.allocator);
        const result = try child.spawnAndWait();
        return result.Exited == 0;
    }
};
