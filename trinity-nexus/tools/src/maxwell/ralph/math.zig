const std = @import("std");
const math = std.math;
const constants = @import("constants.zig");

/// φ-интерполяция
pub fn phi_lerp(a: f64, b: f64, t: f64) f64 {
    const phi_t = math.pow(f64, t, constants.PHI_INV);
    return a + (b - a) * phi_t;
}

/// Генерация φ-спирали
pub fn generate_phi_spiral(n: u32, scale: f64, cx: f64, cy: f64, buffer: []f64) u32 {
    const max_points = buffer.len / 2;
    const count = if (n > max_points) @as(u32, @intCast(max_points)) else n;
    var i: u32 = 0;
    while (i < count) : (i += 1) {
        const fi: f64 = @floatFromInt(i);
        const angle = fi * constants.TAU * constants.PHI_INV;
        const radius = scale * math.pow(f64, constants.PHI, fi * 0.1);
        buffer[i * 2] = cx + radius * @cos(angle);
        buffer[i * 2 + 1] = cy + radius * @sin(angle);
    }
    return count;
}

test "phi_constants" {
    try std.testing.expectApproxEqAbs(constants.PHI * constants.PHI_INV, 1.0, 1e-10);
    try std.testing.expectApproxEqAbs(constants.PHI_SQ - constants.PHI, 1.0, 1e-10);
}
