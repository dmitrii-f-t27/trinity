//! VIBEE v9 - Auto-Scaler Module
//! HorizontalPodAutoscaler for Trinity Swarm: 32 → 128 agents
//! φ² + 1/φ² = 3

const std = @import("std");
const Allocator = std.mem.Allocator;

// ═══════════════════════════════════════════════════════════════════════════════
// Auto-Scaler Configuration
// ═══════════════════════════════════════════════════════════════════════════════

/// Scaling policy thresholds
pub const ScalingPolicy = struct {
    /// Queue length that triggers scale up
    scale_up_threshold: u64 = 100,
    /// Queue length that triggers scale down
    scale_down_threshold: u64 = 10,
    /// Minimum number of agents
    min_agents: usize = 32,
    /// Maximum number of agents
    max_agents: usize = 128,
    /// Agents to add per scale step
    scale_step: usize = 32,
    /// Cooldown period between scaling operations (seconds)
    cooldown_sec: u64 = 60,
    /// Target queue length per agent
    target_queue_per_agent: f64 = 3.0,
};

/// Scaling direction
pub const ScalingDirection = enum {
    none,
    up,
    down,
};

/// Scaling decision
pub const ScalingDecision = struct {
    direction: ScalingDirection,
    current_agents: usize,
    target_agents: usize,
    reason: []const u8,
    confidence: f64, // 0.0 to 1.0
    timestamp_ns: u64,

    pub fn format(self: ScalingDecision, allocator: Allocator) ![]const u8 {
        return std.fmt.allocPrint(allocator,
            \\ScalingDecision: {s} {d}→{d} agents (confidence: {d:.1}%, reason: {s})
        , .{ @tagName(self.direction), self.current_agents, self.target_agents, self.confidence * 100, self.reason });
    }
};

/// Scaling event for audit log
pub const ScalingEvent = struct {
    timestamp_ns: u64,
    direction: ScalingDirection,
    before_count: usize,
    after_count: usize,
    trigger_metric: []const u8,
    metric_value: f64,
    policy: ScalingPolicy,
};

/// Auto-scaler state
pub const AutoScaler = struct {
    allocator: Allocator,
    policy: ScalingPolicy,
    last_scale_time_ns: u64,
    scaling_history: std.ArrayList(ScalingEvent),
    metrics_history: std.ArrayList(struct {
        timestamp_ns: u64,
        agent_count: usize,
        queue_length: usize,
        consensus: f64,
    }),

    const Self = @This();

    /// Initialize new auto-scaler
    pub fn init(allocator: Allocator, policy: ScalingPolicy) AutoScaler {
        return AutoScaler{
            .allocator = allocator,
            .policy = policy,
            .last_scale_time_ns = 0,
            .scaling_history = std.ArrayList(ScalingEvent).init(allocator),
            .metrics_history = std.ArrayList(struct {
                timestamp_ns: u64,
                agent_count: usize,
                queue_length: usize,
                consensus: f64,
            }).init(allocator),
        };
    }

    /// Evaluate scaling decision based on current state
    pub fn evaluateScaling(self: *Self, agent_count: usize, queue_length: usize, consensus_agreement: f64) !ScalingDecision {
        const now_ns = @intCast(std.time.nanoTimestamp());

        // Check cooldown
        if (now_ns < self.last_scale_time_ns + (self.policy.cooldown_sec * 1_000_000_000)) {
            // In cooldown period
            return ScalingDecision{
                .direction = .none,
                .current_agents = agent_count,
                .target_agents = agent_count,
                .reason = "cooldown period active",
                .confidence = 1.0,
                .timestamp_ns = now_ns,
            };
        }

        // Calculate target agents based on queue load
        const queue_per_agent = if (agent_count > 0)
            then @as(f64, @floatFromInt(queue_length)) / @as(f64, @floatFromInt(agent_count))
            else 0;

        // Primary trigger: queue length
        var target = agent_count;
        var direction = ScalingDirection.none;
        var reason: []const u8 = "within thresholds";
        var confidence: f64 = 0.9;

        if (queue_length >= self.policy.scale_up_threshold) {
            // Scale up based on queue size
            const desired = @min(
                self.policy.max_agents,
                @as(usize, @intFromFloat(@ceil(@as(f64, @floatFromInt(queue_length)) / self.policy.target_queue_per_agent)))
            );
            target = @max(agent_count + self.policy.scale_step, desired);
            direction = .up;
            reason = "queue length exceeds threshold";
            confidence = 1.0;
        } else if (queue_length <= self.policy.scale_down_threshold and agent_count > self.policy.min_agents) {
            // Scale down if queue is small and we have extra agents
            target = @max(self.policy.min_agents, agent_count - self.policy.scale_step);
            if (target < agent_count) {
                direction = .down;
                reason = "queue length below threshold";
                confidence = 0.8;
            }
        } else if (consensus_agreement < 0.99 and agent_count < self.policy.max_agents) {
            // Low consensus indicates need for more agents
            target = @min(self.policy.max_agents, agent_count + self.policy.scale_step);
            direction = .up;
            reason = "consensus below 99%";
            confidence = 0.7;
        } else if (queue_per_agent > 10 and agent_count < self.policy.max_agents) {
            // High per-agent load
            target = @min(self.policy.max_agents, agent_count + self.policy.scale_step);
            direction = .up;
            reason = "high per-agent queue load";
            confidence = 0.8;
        }

        return ScalingDecision{
            .direction = direction,
            .current_agents = agent_count,
            .target_agents = target,
            .reason = reason,
            .confidence = confidence,
            .timestamp_ns = now_ns,
        };
    }

    /// Apply scaling decision
    pub fn applyScaling(self: *Self, decision: ScalingDecision) !bool {
        if (decision.direction == .none) return false;

        // Record scaling event
        try self.scaling_history.append(ScalingEvent{
            .timestamp_ns = decision.timestamp_ns,
            .direction = decision.direction,
            .before_count = decision.current_agents,
            .after_count = decision.target_agents,
            .trigger_metric = decision.reason,
            .metric_value = if (decision.direction == .up)
                then @floatFromInt(self.policy.scale_up_threshold)
                else @floatFromInt(self.policy.scale_down_threshold),
            .policy = self.policy,
        });

        // Update last scale time
        self.last_scale_time_ns = decision.timestamp_ns;

        // Keep history manageable
        if (self.scaling_history.items.len > 1000) {
            // Remove oldest events
            const remove_count = self.scaling_history.items.len - 1000;
            for (0..remove_count) |_| {
                _ = self.scaling_history.orderedRemove(0);
            }
        }

        return true;
    }

    /// Record metrics snapshot
    pub fn recordMetrics(self: *Self, agent_count: usize, queue_length: usize, consensus: f64) !void {
        try self.metrics_history.append(.{
            .timestamp_ns = @intCast(std.time.nanoTimestamp()),
            .agent_count = agent_count,
            .queue_length = queue_length,
            .consensus = consensus,
        });

        // Keep metrics history manageable
        if (self.metrics_history.items.len > 10000) {
            const remove_count = self.metrics_history.items.len - 10000;
            for (0..remove_count) |_| {
                _ = self.metrics_history.orderedRemove(0);
            }
        }
    }

    /// Get scaling statistics
    pub fn getStats(self: *const Self) struct {
        total_scale_ups: usize,
        total_scale_downs: usize,
        last_scale_direction: ?ScalingDirection,
        avg_scale_interval_sec: f64,
    } {
        var total_ups: usize = 0;
        var total_downs: usize = 0;
        var last_dir: ?ScalingDirection = null;
        var first_scale_ns: u64 = 0;
        var last_scale_ns: u64 = 0;

        for (self.scaling_history.items) |event| {
            if (event.direction == .up) total_ups += 1 else if (event.direction == .down) total_downs += 1;
            last_dir = event.direction;
            if (first_scale_ns == 0) first_scale_ns = event.timestamp_ns;
            last_scale_ns = @max(last_scale_ns, event.timestamp_ns);
        };

        const avg_interval = if (total_ups + total_downs > 1 and last_scale_ns > first_scale_ns)
            then @as(f64, @floatFromInt(last_scale_ns - first_scale_ns)) / @as(f64, @floatFromInt(total_ups + total_downs - 1)) / 1e9
        else 0;

        return .{
            .total_scale_ups = total_ups,
            .total_scale_downs = total_downs,
            .last_scale_direction = last_dir,
            .avg_scale_interval_sec = avg_interval,
        };
    }

    /// Get recommended configuration
    pub fn getRecommendedConfig(self: *const Self) struct {
        estimated_max_tasks_per_min: f64,
        estimated_cost_per_hour: f64,
        suggested_instance_type: []const u8,
    } {
        const stats = self.getStats();
        const scale_frequency = if (stats.avg_scale_interval_sec > 0)
            then 3600.0 / stats.avg_scale_interval_sec
            else 0;

        // Estimate: each agent can handle ~3-5 tasks/min
        const avg_agents = (@as(f64, @floatFromInt(self.policy.min_agents)) +
                              @as(f64, @floatFromInt(self.policy.max_agents))) / 2.0;
        const tasks_per_min = avg_agents * 4.0;
        const max_tasks = self.policy.max_agents * 5.0;

        // Cost estimation (rough, in USD/hour)
        const cost_per_agent = 0.05; // $0.05 per agent per hour
        const avg_cost = avg_agents * cost_per_agent;
        const max_cost = @as(f64, @floatFromInt(self.policy.max_agents)) * cost_per_agent;

        const instance_type = if (self.policy.max_agents <= 64)
            then "c6i.xlarge (32 vCPU, 64 GB RAM)"
            else "c6i.2xlarge (64 vCPU, 128 GB RAM)";

        return .{
            .estimated_max_tasks_per_min = max_tasks,
            .estimated_cost_per_hour = max_cost,
            .suggested_instance_type = instance_type,
        };
    }

    /// Export scaling events as JSON
    pub fn exportEventsAsJson(self: *const AutoScaler, allocator: Allocator) ![]const u8 {
        var output = std.ArrayList(u8).init(allocator);
        try output.appendSlice("{\n  \"events\": [\n");

        var iter = self.scaling_history.iterator();
        var first = true;
        while (iter.next()) |event| {
            if (!first) try output.appendSlice(",\n");
            first = false;

            try output.writer().print(
                \\    {{
                \\      "timestamp_ns": {d},
                \\      "direction": "{s}",
                \\      "before_count": {d},
                \\      "after_count": {d},
                \\      "trigger_metric": "{s}",
                \\      "metric_value": {d:.3}
                \\    }}
            , .{
                event.timestamp_ns,
                @tagName(event.direction),
                event.before_count,
                event.after_count,
                event.trigger_metric,
                event.metric_value,
            });
        }

        try output.appendSlice("\n  ],\n");
        try output.writer().print(
            \\  "stats": {{
            \\    "total_scale_ups": {d},
            \\    "total_scale_downs": {d},
            \\    "avg_scale_interval_sec": {d:.1}
            \\  }}
            \\
        , .{
            self.scaling_history.items.len,
            stats.total_scale_ups,
            stats.total_scale_downs,
            stats.avg_scale_interval_sec,
        });

        try output.appendSlice("}\n");
        return output.toOwnedSlice();
    }

    /// Cleanup
    pub fn deinit(self: *AutoScaler) void {
        self.scaling_history.deinit();
        self.metrics_history.deinit();
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// Kubernetes HorizontalPodAutoscaler compatibility
// ═══════════════════════════════════════════════════════════════════════════════

/// HPA metric spec
pub const HPAMetricSpec = struct {
    name: []const u8,
    current_value: f64,
    target_value: f64,
    metric_type: []const u8, // "Resource", "Pods", "External"
};

/// Generate HPA manifest for the swarm
pub fn generateHPAManifest(allocator: Allocator, namespace: []const u8, policy: ScalingPolicy) ![]const u8 {
    return std.fmt.allocPrint(allocator,
        \\---
        \\apiVersion: autoscaling/v2
        \\kind: HorizontalPodAutoscaler
        \\metadata:
        \\  name: trinity-swarm-hpa
        \\  namespace: {s}
        \\spec:
        \\  scaleTargetRef:
        \\    apiVersion: apps/v1
        \\    kind: Deployment
        \\    name: trinity-swarm
        \\  minReplicas: {d}
        \\  maxReplicas: {d}
        \\  metrics:
        \\  - type: External
        \\    external:
        \\      metric:
        \\        name: trinity_swarm_queue_length
        \\        target:
        \\          type: AverageValue
        \\          averageValue: "{d}"
        \\  behavior:
        \\    scaleUp:
        \\      stabilizationWindowSeconds: 60
        \\      policies:
        \\      - type: Pods
        \\        value: 1
        \\        periodSeconds: 15
        \\    scaleDown:
        \\      stabilizationWindowSeconds: 300
        \\      policies:
        \\      - type: Pods
        \\        value: 1
        \\        periodSeconds: 60
        \\
    , .{ namespace, policy.min_agents, policy.max_agents, policy.scale_down_threshold / 2 });
}
