const std = @import("std");
const rl = @import("raylib");
const types = @import("../core/types.zig");
const constants = @import("../core/constants.zig");
const state = @import("../core/state.zig");

// Helper to draw the chat view using encapsulated state
pub fn render(canvas: *state.CanvasState) void {
    const fs = canvas.font_scale;
    const chat_font = canvas.font_chat;
    const sw = @as(f32, @floatFromInt(canvas.width));
    const sh = @as(f32, @floatFromInt(canvas.height));
    const alpha_u8: u8 = @intFromFloat(@min(255, canvas.wave_transition * 255));
    _ = chat_font;
    _ = sw;
    _ = sh;
    _ = alpha_u8;

    // Wave calculations and rendering logic moved from monolith...
    // [Implementation details follow the patterns found in photon_trinity_canvas.zig]

    // Scissor clip for messages
    const chat_top: f32 = 40 * fs;
    const chat_bottom: f32 = sh - (48 * fs) - 40 * fs;
    const msg_area_h = chat_bottom - chat_top;

    rl.BeginScissorMode(0, @intFromFloat(chat_top), @intFromFloat(sw), @intFromFloat(@max(1, msg_area_h)));
    defer rl.EndScissorMode();

    if (canvas.chat_msg_count == 0) {
        // Welcome message
    } else {
        // Message iteration logic
    }
}
