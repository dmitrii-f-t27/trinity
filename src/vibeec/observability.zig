//! VIBEE v9 - Observability & Metrics Module
//! OpenTelemetry tracing + Prometheus metrics v2 for Trinity Swarm
//! φ² + 1/φ² = 3

const std = @import("std");
const Allocator = std.mem.Allocator;

// ═══════════════════════════════════════════════════════════════════════════════
// OpenTelemetry Span Context
// ═══════════════════════════════════════════════════════════════════════════════

/// Span trace identifier (128-bit)
pub const TraceId = struct {
    high: u64,
    low: u64,

    pub fn format(self: TraceId, allocator: Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "{x:0>16}{x:0>16}", .{ self.high, self.low });
    }

    pub fn initRandom() TraceId {
        var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
        return .{
            .high = rng.next(),
            .low = rng.next(),
        };
    }
};

/// Span identifier (64-bit)
pub const SpanId = struct {
    id: u64,

    pub fn format(self: SpanId, allocator: Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "{x:0>16}", .{self.id});
    }

    pub fn initRandom() SpanId {
        var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
        return .{ .id = rng.next() };
    }
};

/// Span context for trace propagation
pub const SpanContext = struct {
    trace_id: TraceId,
    span_id: SpanId,
    parent_span_id: ?SpanId,

    pub fn initChild(parent: SpanContext) SpanContext {
        return .{
            .trace_id = parent.trace_id,
            .span_id = SpanId.initRandom(),
            .parent_span_id = parent.span_id,
        };
    }

    pub fn initRoot() SpanContext {
        return .{
            .trace_id = TraceId.initRandom(),
            .span_id = SpanId.initRandom(),
            .parent_span_id = null,
        };
    }
};

/// Span status
pub const SpanStatus = enum {
    ok,
    error,
    cancelled,
};

/// OpenTelemetry Span
pub const Span = struct {
    name: []const u8,
    context: SpanContext,
    start_time_ns: u64,
    end_time_ns: u64,
    status: SpanStatus,
    attributes: std.StringHashMap([]const u8),
    events: std.ArrayList(SpanEvent),
    children: std.ArrayList(Span),

    pub const SpanEvent = struct {
        name: []const u8,
        timestamp_ns: u64,
        attributes: std.StringHashMap([]const u8),
    };

    /// Create a new root span
    pub fn initRoot(allocator: Allocator, name: []const u8) !Span {
        var attributes = std.StringHashMap([]const u8).init(allocator);
        var events = std.ArrayList(SpanEvent).init(allocator);
        var children = std.ArrayList(Span).init(allocator);

        return Span{
            .name = name,
            .context = SpanContext.initRoot(),
            .start_time_ns = @intCast(std.time.nanoTimestamp()),
            .end_time_ns = 0,
            .status = .ok,
            .attributes = attributes,
            .events = events,
            .children = children,
        };
    }

    /// Create a child span
    pub fn initChild(parent: *const Span, allocator: Allocator, name: []const u8) !Span {
        var attributes = std.StringHashMap([]const u8).init(allocator);
        var events = std.ArrayList(SpanEvent).init(allocator);
        var children = std.ArrayList(Span).init(allocator);

        return Span{
            .name = name,
            .context = SpanContext.initChild(parent.context),
            .start_time_ns = @intCast(std.time.nanoTimestamp()),
            .end_time_ns = 0,
            .status = .ok,
            .attributes = attributes,
            .events = events,
            .children = children,
        };
    }

    /// Set attribute on span
    pub fn setAttribute(self: *Span, key: []const u8, value: []const u8) !void {
        try self.attributes.put(key, try self.attributes.allocator.dupe(u8, value));
    }

    /// Add event to span
    pub fn addEvent(self: *Span, name: []const u8, attrs: std.StringHashMap([]const u8)) !void {
        var event_attrs = std.StringHashMap([]const u8).init(self.events.allocator);
        var iter = attrs.iterator();
        while (iter.next()) |entry| {
            try event_attrs.put(entry.key_ptr.*, try event_attrs.allocator.dupe(u8, entry.value_ptr.*));
        }

        try self.events.append(SpanEvent{
            .name = name,
            .timestamp_ns = @intCast(std.time.nanoTimestamp()),
            .attributes = event_attrs,
        });
    }

    /// End span with status
    pub fn end(self: *Span, status: SpanStatus) void {
        self.end_time_ns = @intCast(std.time.nanoTimestamp());
        self.status = status;
    }

    /// Get span duration in seconds
    pub fn durationSec(self: *const Span) f64 {
        if (self.end_time_ns == 0) {
            return 0;
        }
        return @as(f64, @floatFromInt(self.end_time_ns - self.start_time_ns)) / 1e9;
    }

    /// Cleanup span resources
    pub fn deinit(self: *Span) void {
        var attr_iter = self.attributes.iterator();
        while (attr_iter.next()) |entry| {
            self.attributes.allocator.free(entry.value_ptr.*);
        }
        self.attributes.deinit();

        for (self.events.items) |*event| {
            var event_attr_iter = event.attributes.iterator();
            while (event_attr_iter.next()) |entry| {
                event.attributes.allocator.free(entry.value_ptr.*);
            }
            event.attributes.deinit();
        }
        self.events.deinit();

        for (self.children.items) |*child| {
            child.deinit();
        }
        self.children.deinit();
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// Prometheus Metrics Exporter v2
// ═══════════════════════════════════════════════════════════════════════════════

/// Metric type
pub const MetricType = enum {
    counter,
    gauge,
    histogram,
    summary,
};

/// Prometheus metric
pub const Metric = struct {
    name: []const u8,
    help: []const u8,
    metric_type: MetricType,
    value: f64,
    labels: std.StringHashMap([]const u8),
    timestamp: u64,

    /// Format metric for Prometheus
    pub fn format(self: *const Metric, allocator: Allocator) ![]u8 {
        var label_buf = std.ArrayList(u8).init(allocator);
        try label_buf.append('{');

        var iter = self.labels.iterator();
        var first = true;
        while (iter.next()) |entry| {
            if (!first) try label_buf.append(',');
            try label_buf.writer().print("{s}=\"{s}\"", .{ entry.key_ptr.*, entry.value_ptr.* });
            first = false;
        }
        if (self.labels.count() > 0) {
            try label_buf.append('}');
        } else {
            // No labels, remove opening brace
            _ = label_buf.pop();
        }

        const type_str = switch (self.metric_type) {
            .counter => "counter",
            .gauge => "gauge",
            .histogram => "histogram",
            .summary => "summary",
        };

        return std.fmt.allocPrint(allocator,
            \\# HELP {s} {s}
            \\# TYPE {s} {s}
            \\{s}{s} {d}
            \\
        , .{ self.name, self.help, self.name, type_str, self.name, label_buf.items, self.value });
    }
};

/// Prometheus registry
pub const PrometheusRegistry = struct {
    allocator: Allocator,
    metrics: std.ArrayList(Metric),

    pub fn init(allocator: Allocator) PrometheusRegistry {
        return PrometheusRegistry{
            .allocator = allocator,
            .metrics = std.ArrayList(Metric).init(allocator),
        };
    }

    /// Register a new metric
    pub fn register(self: *PrometheusRegistry, name: []const u8, help: []const u8, metric_type: MetricType) !void {
        for (self.metrics.items) |*m| {
            if (std.mem.eql(u8, m.name, name)) return; // Already registered
        }

        var labels = std.StringHashMap([]const u8).init(self.allocator);
        try self.metrics.append(Metric{
            .name = name,
            .help = help,
            .metric_type = metric_type,
            .value = 0,
            .labels = labels,
            .timestamp = @intCast(std.time.nanoTimestamp()),
        });
    }

    /// Set metric value
    pub fn set(self: *PrometheusRegistry, name: []const u8, value: f64, label_pairs: []const []const u8) !void {
        for (self.metrics.items) |*m| {
            if (std.mem.eql(u8, m.name, name)) {
                m.value = value;
                m.timestamp = @intCast(std.time.nanoTimestamp());

                // Update labels if provided
                if (label_pairs.len > 0) {
                    var i: usize = 0;
                    while (i < label_pairs.len) : (i += 2) {
                        try m.labels.put(label_pairs[i], label_pairs[i + 1]);
                    }
                }
                return;
            }
        }
        return error.MetricNotFound;
    }

    /// Increment counter
    pub fn increment(self: *PrometheusRegistry, name: []const u8, label_pairs: []const []const u8) !void {
        for (self.metrics.items) |*m| {
            if (std.mem.eql(u8, m.name, name)) {
                m.value += 1;
                m.timestamp = @intCast(std.time.nanoTimestamp());

                if (label_pairs.len > 0) {
                    var i: usize = 0;
                    while (i < label_pairs.len) : (i += 2) {
                        try m.labels.put(label_pairs[i], label_pairs[i + 1]);
                    }
                }
                return;
            }
        }
        return error.MetricNotFound;
    }

    /// Export all metrics in Prometheus text format
    pub fn export(self: *const PrometheusRegistry) ![]const u8 {
        var output = std.ArrayList(u8).init(self.allocator);

        for (self.metrics.items) |*metric| {
            const formatted = try metric.format(self.allocator);
            defer self.allocator.free(formatted);
            try output.appendSlice(formatted);
        }

        return output.toOwnedSlice();
    }

    /// Cleanup
    pub fn deinit(self: *PrometheusRegistry) void {
        for (self.metrics.items) |*m| {
            var iter = m.labels.iterator();
            while (iter.next()) |entry| {
                self.allocator.free(entry.value_ptr.*);
            }
            m.labels.deinit();
        }
        self.metrics.deinit();
    }
};

/// Swarm metrics collector
pub const SwarmMetrics = struct {
    allocator: Allocator,
    registry: PrometheusRegistry,
    root_span: ?Span,

    pub fn init(allocator: Allocator) !SwarmMetrics {
        var self = SwarmMetrics{
            .allocator = allocator,
            .registry = PrometheusRegistry.init(allocator),
            .root_span = null,
        };

        // Register standard metrics
        try self.registry.register("trinity_swarm_online_agents", "Number of online agents", .gauge);
        try self.registry.register("trinity_swarm_tasks_completed", "Total tasks completed", .counter);
        try self.registry.register("trinity_swarm_tasks_failed", "Total tasks failed", .counter);
        try self.registry.register("trinity_swarm_consensus_agreement", "Current consensus agreement", .gauge);
        try self.registry.register("trinity_swarm_tasks_per_second", "Processing rate", .gauge);
        try self.registry.register("trinity_swarm_self_improve_pct", "Real pattern percentage after improvement", .gauge);
        try self.registry.register("trinity_swarm_patterns_improved", "Number of patterns improved per cycle", .counter);
        try self.registry.register("trinity_swarm_active_agents", "Currently active agents", .gauge);
        try self.registry.register("trinity_swarm_queue_length", "Current task queue length", .gauge);
        try self.registry.register("trinity_swarm_avg_task_duration_sec", "Average task duration in seconds", .gauge);

        return self;
    }

    /// Start a trace root span
    pub fn startTrace(self: *SwarmMetrics, name: []const u8) !void {
        if (self.root_span == null) {
            self.root_span = try Span.initRoot(self.allocator, name);
        }
    }

    /// Record agent online count
    pub fn recordOnlineAgents(self: *SwarmMetrics, count: u64) !void {
        try self.registry.set("trinity_swarm_online_agents", @floatFromInt(count), &.{});
    }

    /// Record task completion
    pub fn recordTaskCompleted(self: *SwarmMetrics, task_type: []const u8) !void {
        try self.registry.increment("trinity_swarm_tasks_completed", &.{ "task_type", task_type });
    }

    /// Record task failure
    pub fn recordTaskFailed(self: *SwarmMetrics, task_type: []const u8) !void {
        try self.registry.increment("trinity_swarm_tasks_failed", &.{ "task_type", task_type });
    }

    /// Record consensus agreement
    pub fn recordConsensus(self: *SwarmMetrics, agreement: f64) !void {
        try self.registry.set("trinity_swarm_consensus_agreement", agreement, &.{});
    }

    /// Record tasks per second
    pub fn recordTasksPerSecond(self: *SwarmMetrics, tps: f64) !void {
        try self.registry.set("trinity_swarm_tasks_per_second", tps, &.{});
    }

    /// Record self-improvement result
    pub fn recordSelfImprove(self: *SwarmMetrics, before_pct: f64, after_pct: f64, improved: u64) !void {
        try self.registry.set("trinity_swarm_self_improve_pct", after_pct, &.{});
        try self.registry.set("trinity_swarm_patterns_improved", @floatFromInt(improved), &.{});
    }

    /// Export Prometheus metrics
    pub fn exportPrometheus(self: *const SwarmMetrics) ![]const u8 {
        return self.registry.export();
    }

    /// End trace and export
    pub fn endTrace(self: *SwarmMetrics) !void {
        if (self.root_span) |*span| {
            span.end(.ok);
            span.deinit();
            self.root_span = null;
        }
    }

    /// Cleanup
    pub fn deinit(self: *SwarmMetrics) void {
        if (self.root_span) |*span| {
            span.deinit();
        }
        self.registry.deinit();
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// Health Check Server
// ═══════════════════════════════════════════════════════════════════════════════

/// Health check response
pub const HealthCheckResponse = struct {
    status: []const u8 = "ok",
    online_agents: u64 = 0,
    tasks_completed: u64 = 0,
    tasks_failed: u64 = 0,
    consensus_agreement: f64 = 0.0,
    uptime_sec: f64 = 0.0,

    pub fn toJson(self: *const HealthCheckResponse, allocator: Allocator) ![]const u8 {
        return std.fmt.allocPrint(allocator,
            \\{{"status":"{s}","online_agents":{d},"tasks_completed":{d},"tasks_failed":{d},"consensus_agreement":{d:.3},"uptime_sec":{d:.1}}}
        , .{ self.status, self.online_agents, self.tasks_completed, self.tasks_failed, self.consensus_agreement, self.uptime_sec });
    }
};
