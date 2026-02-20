pub const constants = @import("constants.zig");
pub const types = @import("types.zig");
pub const trit = @import("trit.zig");
pub const math = @import("math.zig");
pub const core = @import("core.zig");
pub const quality = @import("quality.zig");
pub const memory = @import("memory.zig");
pub const wasm = @import("wasm.zig");
pub const parser = @import("parser.zig");
pub const process = @import("process.zig");
pub const git = @import("git.zig");
pub const telegram = @import("telegram.zig");
pub const agent = @import("agent.zig");

// Re-export common types for ease of use
pub const Trit = trit.Trit;
pub const RalphAgent = agent.RalphAgent;
pub const RalphConfig = agent.RalphConfig;
pub const SessionState = types.SessionState;
pub const CircuitBreakerState = quality.CircuitBreakerState;
pub const GateResult = quality.GateResult;
pub const QualityGates = quality.QualityGates;

// Re-export core types
pub const RalphError = core.RalphError;
pub const PlanOptions = core.PlanOptions;
pub const NodeCandidate = core.NodeCandidate;
pub const LoopDecision = core.LoopDecision;
pub const LoopAction = core.LoopAction;
pub const ToxicVerdict = core.ToxicVerdict;
pub const TestResult = core.TestResult;
pub const BenchmarkResult = core.BenchmarkResult;
pub const GitCommitResult = core.GitCommitResult;

// Re-export memory types
pub const MemoryStore = memory.MemoryStore;
pub const SearchResult = memory.SearchResult;

// Re-export agent types
pub const CycleResult = agent.CycleResult;
pub const AgentSummary = agent.AgentSummary;

// Re-export constants
pub const PHI = constants.PHI;
pub const PHOENIX = constants.PHOENIX;
pub const TRIT_CPU = "ternary_trit_cpu";

// Tests
test {
    _ = constants;
    _ = types;
    _ = trit;
    _ = math;
    _ = core;
    _ = quality;
    _ = memory;
    _ = wasm;
    _ = parser;
    _ = process;
    _ = git;
    _ = telegram;
    _ = agent;
}
