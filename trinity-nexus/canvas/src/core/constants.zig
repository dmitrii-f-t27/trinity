const rl = @cImport({
    @cInclude("raylib.h");
});

pub const PHI: f32 = 1.61803398875;
pub const PHI_INV: f32 = 0.61803398875;
pub const TAU: f32 = 6.28318530718;

pub const MAX_CHAT_MSGS = 128;
pub const MAX_CHAT_MSG_LEN = 512;
pub const MAX_CHAT_INPUT_LEN = 256;

// ── v8.6: Aceternity Glassmorphism Neon Palette ──
pub const GLASS_NEON_PURPLE = rl.Color{ .r = 0x88, .g = 0x44, .b = 0xFF, .a = 255 };
pub const GLASS_NEON_CYAN = rl.Color{ .r = 0x00, .g = 0xFF, .b = 0xFF, .a = 255 };
pub const GLASS_NEON_MAGENTA = rl.Color{ .r = 0xFF, .g = 0x14, .b = 0x93, .a = 255 };
pub const GLASS_NEON_LIME = rl.Color{ .r = 0x00, .g = 0xFF, .b = 0x66, .a = 255 };
pub const GLASS_BG_DARK = rl.Color{ .r = 20, .g = 20, .b = 35, .a = 180 };
pub const GLASS_BG_LIGHT = rl.Color{ .r = 40, .g = 40, .b = 60, .a = 160 };

pub const MAX_RALPH_AGENTS = 4;
pub const LIVE_LOG_MAX = 16;
pub const FINDER_MAX_ENTRIES = 32;
