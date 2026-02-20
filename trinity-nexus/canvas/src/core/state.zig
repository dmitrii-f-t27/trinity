const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const types = @import("types.zig");
const constants = @import("constants.zig");

pub const RalphAgent = struct {
    // Identity
    name: [32:0]u8 = [_:0]u8{0} ** 32,
    name_len: usize = 0,
    branch: [64:0]u8 = [_:0]u8{0} ** 64,
    branch_len: usize = 0,
    // Metrics
    loop: usize = 0,
    total_calls: usize = 0,
    is_healthy: bool = true,
    goal: [128:0]u8 = [_:0]u8{0} ** 128,
    goal_len: usize = 0,
    last_action: [64:0]u8 = [_:0]u8{0} ** 64,
    last_action_len: usize = 0,
    log_ptr: usize = 0,
    // Per-agent state
    cb_state: types.CircuitBreakerState = .closed,
    running: bool = false,
    reachable: bool = false,
    // Ralph loop logs
    logs: [30][128:0]u8 = undefined,
    log_count: usize = 0,
    // Live Claude Code output
    live_result: [4096:0]u8 = [_:0]u8{0} ** 4096,
    live_result_len: usize = 0,
    live_num_turns: usize = 0,
    live_duration_ms: usize = 0,
    live_cost_usd: [16:0]u8 = [_:0]u8{0} ** 16,
    live_cost_len: usize = 0,
    live_is_error: bool = false,
    live_session_id: [40:0]u8 = [_:0]u8{0} ** 40,
    live_session_len: usize = 0,
    // Status monitor data
    loop_count_status: usize = 0,
    calls_this_hour: usize = 0,
    max_calls_hour: usize = 100,
    status_text: [32:0]u8 = [_:0]u8{0} ** 32,
    status_text_len: usize = 0,
    next_reset: [16:0]u8 = [_:0]u8{0} ** 16,
    next_reset_len: usize = 0,
    // Progress tracking
    progress_status: [32:0]u8 = [_:0]u8{0} ** 32,
    progress_status_len: usize = 0,
    recent_commits_count: usize = 0,
    // Data freshness tracking
    log_mtime: i64 = 0,
    status_mtime: i64 = 0,
    live_mtime: i64 = 0,
    data_age_seconds: i64 = 0,
    rate_limited: bool = false,
    is_executing: bool = false,
    // Todo list
    todo_items: [10][96:0]u8 = [_][96:0]u8{[_:0]u8{0} ** 96} ** 10,
    todo_statuses: [10]u8 = [_]u8{0} ** 10,
    todo_count: usize = 0,
    // Per-agent poll timer
    update_timer: f32 = 0,
    // Unified chat dialog messages
    chat_msgs: [50]types.ChatMsg = [_]types.ChatMsg{types.ChatMsg{}} ** 50,
    chat_count: usize = 0,
    chat_built_log_mt: i64 = 0,
    chat_built_live_mt: i64 = 0,
};

pub const CanvasState = struct {
    // Screen / View properties
    width: c_int = 1512,
    height: c_int = 982,
    pixel_size: c_int = 4,
    font_scale: f32 = 1.0,
    dpi_scale: f32 = 1.0,

    // Fonts
    font_chat: rl.Font = undefined,
    font_emoji: rl.Font = undefined,

    // Wave Mode
    wave_mode: types.WaveMode = .idle,
    wave_mode_prev: types.WaveMode = .idle,
    wave_transition: f32 = 0.0,

    // Chat state
    chat_messages: [constants.MAX_CHAT_MSGS][constants.MAX_CHAT_MSG_LEN]u8 = undefined,
    chat_msg_lens: [constants.MAX_CHAT_MSGS]usize = .{0} ** constants.MAX_CHAT_MSGS,
    chat_msg_types: [constants.MAX_CHAT_MSGS]types.ChatMsgType = .{.ai} ** constants.MAX_CHAT_MSGS,
    chat_msg_count: usize = 0,
    chat_input: [constants.MAX_CHAT_INPUT_LEN]u8 = undefined,
    chat_input_len: usize = 0,
    chat_scroll_y: f32 = 0.0,
    chat_scroll_target: f32 = 0.0,

    // Ralph state
    ralph_agents: [constants.MAX_RALPH_AGENTS]RalphAgent = [_]RalphAgent{RalphAgent{}} ** constants.MAX_RALPH_AGENTS,
    ralph_agent_count: usize = 0,
    ralph_active_tab: usize = 0,
    ralph_initialized: bool = false,
    ralph_chat_scroll_y: f32 = 0.0,
    ralph_chat_scroll_target: f32 = 0.0,

    // DePIN Node state
    depin_running: bool = false,
    depin_earned_tri: f64 = 0.0,
    depin_peers: u32 = 0,

    // ... more state can be added as needed

    pub fn init() CanvasState {
        return CanvasState{};
    }
};
