const std = @import("std");
const constants = @import("constants.zig");

pub const CircuitBreakerState = enum {
    closed,
    half_open,
    open,
};

pub const GateResult = enum {
    pass,
    fail,
};

pub const TaskPriority = enum {
    p0_critical,
    p1_high,
    p2_medium,
    p3_low,
};

pub const WorkType = enum {
    implementation,
    testing,
    documentation,
    refactoring,
    benchmarking,
};

pub const VerdictStatus = enum {
    prod,
    fail,
};

pub const LoopDecision = enum {
    @"continue",
    complete,
    blocked,
    escalate,
};

pub const GoldenChainLink = enum {
    decompose,
    plan,
    spec_create,
    gen,
    @"test",
    bench,
    verdict,
    git,
    loop,
};

pub const QualityGates = struct {
    build: GateResult,
    @"test": GateResult,
    format: GateResult,
    branch_valid: GateResult,
};

pub const TechTreeNode = struct {
    id: []const u8,
    name: []const u8,
    branch: []const u8,
    impact: f64,
    complexity: f64,
    unlock_count: i64,
    status: []const u8,
    dependencies: []const u8,
};

pub const TaskEntry = struct {
    id: []const u8,
    description: []const u8,
    priority: TaskPriority,
    status: []const u8,
    tech_tree_node: []const u8,
    subtasks: []const u8,
    blocker_reason: []const u8,
};

pub const SessionState = struct {
    session_id: []const u8,
    call_count: i64,
    loop_count: i64,
    loop_start_sha: []const u8,
    current_branch: []const u8,
    current_link: GoldenChainLink,
    circuit_breaker: CircuitBreakerState,
    no_progress_count: i64,
    last_commit_sha: []const u8,
};

pub const MemoryStore = struct {
    success_patterns: []const u8,
    regression_patterns: []const u8,
    benchmark_baseline: []const u8,
};

pub const RalphConfig = struct {
    max_loops_per_session: i64,
    circuit_breaker_threshold: i64,
    max_file_lines: i64,
    test_effort_ratio: f64,
    report_interval_min: i64,
    telegram_chat_id: []const u8,
    report_enabled: bool,
};

pub const ToxicVerdict = struct {
    score: i64,
    status: VerdictStatus,
    flaws: []const u8,
    assessment: []const u8,
    recommendation: []const u8,
};

pub const RalphStatus = struct {
    status: []const u8,
    branch: []const u8,
    tasks_completed: i64,
    files_modified: i64,
    gates: QualityGates,
    history_consulted: bool,
    patterns_found: i64,
    tech_tree_node: []const u8,
    tech_tree_updated: bool,
    work_type: WorkType,
    exit_signal: bool,
    recommendation: []const u8,
};

pub const RalphAgent = struct {
    config: RalphConfig,
    session: SessionState,
    memory: MemoryStore,
    current_task: TaskEntry,
    gates: QualityGates,
    last_verdict: ToxicVerdict,
    tech_tree: []const u8,
};
