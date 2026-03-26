//! Zenodo V16: Statistical Rigor & Scientific Publication
//!
//! Enhanced structures for statistically rigorous scientific documentation.
//! Compatible with Zig 0.15 using std.fmt.allocPrint patterns.
//!
//! Features:
//! - Statistical significance with p-value thresholds
//! - Confidence intervals (bootstrap, Bayesian, analytical)
//! - Statistical test results (t-test, Wilcoxon, Mann-Whitney)
//! - Enhanced LaTeX table generation with significance markers

const std = @import("std");

// ═════════════════════════════════════════════════════════════════════════
// STATISTICAL RIGOR MODULE
// ═════════════════════════════════════════════════════════════════════════

/// Statistical significance level with formatting support
pub const StatisticalSignificance = enum {
    /// p >= 0.10 - not significant
    not_significant,

    /// 0.05 <= p < 0.10 (†)
    marginal,

    /// 0.01 <= p < 0.05 (*)
    significant,

    /// 0.001 <= p < 0.01 (**)
    very_significant,

    /// p < 0.001 (***)
    extremely_significant,

    pub fn fromPValue(p: f64) StatisticalSignificance {
        if (p >= 0.10) return .not_significant;
        if (p >= 0.05) return .marginal;
        if (p >= 0.01) return .significant;
        if (p >= 0.001) return .very_significant;
        return .extremely_significant;
    }

    pub fn toEmoji(self: StatisticalSignificance) []const u8 {
        return switch (self) {
            .not_significant => "",
            .marginal => "†",
            .significant => "*",
            .very_significant => "**",
            .extremely_significant => "***",
        };
    }

    pub fn toMarkdown(self: StatisticalSignificance) []const u8 {
        return switch (self) {
            .not_significant => "NS",
            .marginal => "†",
            .significant => "*",
            .very_significant => "**",
            .extremely_significant => "***",
        };
    }

    pub fn toLaTeX(self: StatisticalSignificance) []const u8 {
        return switch (self) {
            .not_significant => "\\text{NS}",
            .marginal => "\\dagger",
            .significant => "*",
            .very_significant => "**",
            .extremely_significant => "***",
        };
    }
};

/// Confidence interval calculation method
pub const CIMethod = enum {
    /// Non-parametric bootstrap
    bootstrap,

    /// Bayesian credible interval
    bayesian,

    /// Closed-form (t-distribution)
    analytical,
};

/// Confidence interval with formatting
pub const ConfidenceInterval = struct {
    lower: f64,
    upper: f64,
    level: f64 = 0.95,
    method: CIMethod = .bootstrap,

    pub fn formatAsLaTeX(self: *const ConfidenceInterval, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "[{d:.3}, {d:.3}]_{{{d:.0}%%}}", .{ self.lower, self.upper, self.level * 100 });
    }

    pub fn formatAsMarkdown(self: *const ConfidenceInterval, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "[{d:.3}, {d:.3}] ({d:.0}%% CI)", .{ self.lower, self.upper, self.level * 100 });
    }

    pub fn width(self: *const ConfidenceInterval) f64 {
        return self.upper - self.lower;
    }

    pub fn center(self: *const ConfidenceInterval) f64 {
        return (self.lower + self.upper) / 2.0;
    }
};

/// Statistical test type
pub const StatisticalTestType = enum {
    t_test,
    wilcoxon,
    mann_whitney,
    anova,
    chi_square,
    fisher_exact,

    pub fn displayName(self: StatisticalTestType) []const u8 {
        return switch (self) {
            .t_test => "Student's t-test",
            .wilcoxon => "Wilcoxon signed-rank test",
            .mann_whitney => "Mann-Whitney U test",
            .anova => "Analysis of Variance (ANOVA)",
            .chi_square => "Chi-square test",
            .fisher_exact => "Fisher's exact test",
        };
    }

    pub fn symbol(self: StatisticalTestType) []const u8 {
        return switch (self) {
            .t_test => "t",
            .wilcoxon => "W",
            .mann_whitney => "U",
            .anova => "F",
            .chi_square => "χ²",
            .fisher_exact => "p",
        };
    }
};

/// Statistical test result with full rigor
pub const StatisticalTestResult = struct {
    test_name: StatisticalTestType,
    statistic_value: f64,
    p_value: f64,
    degrees_of_freedom: ?u32 = null,
    significance: StatisticalSignificance,
    confidence_interval: ?ConfidenceInterval = null,
    sample_size_n: u32,

    pub fn formatAsLaTeX(self: *const StatisticalTestResult, allocator: std.mem.Allocator) ![]u8 {
        const test_symbol = self.test_name.symbol();
        const sig_str = try std.fmt.allocPrint(allocator, "{s}", .{self.significance.toLaTeX()});
        const ci_str = if (self.confidence_interval) |ci|
            try std.fmt.allocPrint(allocator, ", {s}", .{try ci.formatAsLaTeX(allocator)})
        else
            "";

        return std.fmt.allocPrint(allocator, "{s}_{{{d}}} = {d:.4}, $p = {d:.4f}{s}{s}", .{ test_symbol, self.degrees_of_freedom orelse 0, self.statistic_value, self.p_value, sig_str, ci_str });
    }

    pub fn formatAsMarkdown(self: *const StatisticalTestResult, allocator: std.mem.Allocator) ![]u8 {
        const test_name = self.test_name.displayName();
        const df_str = if (self.degrees_of_freedom) |df|
            try std.fmt.allocPrint(allocator, " (df={d})", .{df})
        else
            "";

        const sig_str = self.significance.toMarkdown();
        const ci_str = if (self.confidence_interval) |ci|
            try std.fmt.allocPrint(allocator, ", {s}", .{try ci.formatAsMarkdown(allocator)})
        else
            "";

        return std.fmt.allocPrint(allocator, "{s}{s}: statistic={d:.4}, p={d:.4f}{s}{s}", .{ test_name, df_str, self.statistic_value, self.p_value, sig_str, ci_str });
    }

    pub fn isSignificantAt(self: *const StatisticalTestResult, alpha: f64) bool {
        return self.p_value < alpha;
    }
};

/// Enhanced experiment result with statistics
pub const ExperimentResultEnhanced = struct {
    experiment_name: []const u8,
    metric_name: []const u8,
    metric_value: f64,
    standard_error: ?f64 = null,
    confidence_interval: ?ConfidenceInterval = null,
    sample_size: u32,
    is_best: bool = false,
    p_value_vs_baseline: ?f64 = null,
    significance_vs_baseline: StatisticalSignificance = .not_significant,

    pub fn formatAsMarkdown(self: *const ExperimentResultEnhanced, allocator: std.mem.Allocator) ![]u8 {
        const se_str = if (self.standard_error) |se|
            try std.fmt.allocPrint(allocator, " (SE={d:.3})", .{se})
        else
            "";

        const ci_str = if (self.confidence_interval) |ci|
            try std.fmt.allocPrint(allocator, " {s}", .{try ci.formatAsMarkdown(allocator)})
        else
            "";

        const sig_str = self.significance_vs_baseline.toMarkdown();
        const best_mark = if (self.is_best) " 🏆" else "";

        return std.fmt.allocPrint(allocator, "- {s}: {d:.3}{s}{s}{s}{s}", .{ self.experiment_name, self.metric_value, se_str, ci_str, sig_str, best_mark });
    }
};

/// Comparison of multiple experiments with statistical analysis
pub const ExperimentComparisonEnhanced = struct {
    caption: []const u8,
    label: ?[]const u8 = null,
    comparison_metric: []const u8,
    higher_is_better: bool,
    results: []const ExperimentResultEnhanced,
    statistical_test: ?StatisticalTestType = null,
    significance_level: f64 = 0.05,

    pub fn formatAsMarkdown(self: *const ExperimentComparisonEnhanced, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 512);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "### ");
        try result.appendSlice(allocator, self.caption);
        try result.appendSlice(allocator, "\n\n");

        if (self.statistical_test) |stat_test| {
            try result.appendSlice(allocator, "**Statistical Test**: ");
            try result.appendSlice(allocator, stat_test.displayName());
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, ", α = {d:.2}\n\n", .{self.significance_level}));
        }

        // Header
        try result.appendSlice(allocator, "| Experiment | ");
        try result.appendSlice(allocator, self.comparison_metric);
        try result.appendSlice(allocator, " | SE | 95% CI | Δ% |\n");
        try result.appendSlice(allocator, "|-----------|----------|-----|----------|-------|\n");

        // Calculate baseline
        if (self.results.len > 0) {
            const baseline = self.results[0];

            for (self.results) |r| {
                const se_str = if (r.standard_error) |se|
                    try std.fmt.allocPrint(allocator, "{d:.3}", .{se})
                else
                    "-";

                const ci_str = if (r.confidence_interval) |ci|
                    try ci.formatAsMarkdown(allocator)
                else
                    "-";

                const delta = (r.metric_value - baseline.metric_value) /
                    baseline.metric_value * 100.0;
                const delta_sign: []const u8 = if (delta >= 0.0) "+" else "-";

                try result.appendSlice(allocator, "| ");
                try result.appendSlice(allocator, r.experiment_name);
                try result.appendSlice(allocator, " | ");
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d:.3}", .{r.metric_value}));
                try result.appendSlice(allocator, " | ");
                try result.appendSlice(allocator, se_str);
                try result.appendSlice(allocator, " | ");
                try result.appendSlice(allocator, ci_str);
                try result.appendSlice(allocator, " | ");
                try result.appendSlice(allocator, delta_sign);
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d:.1}", .{@abs(delta)}));
                try result.appendSlice(allocator, "% |\n");
            }
        }

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════════════

test "StatisticalSignificance fromPValue" {
    try std.testing.expectEqual(StatisticalSignificance.extremely_significant, StatisticalSignificance.fromPValue(0.0001));
    try std.testing.expectEqual(StatisticalSignificance.very_significant, StatisticalSignificance.fromPValue(0.005));
    try std.testing.expectEqual(StatisticalSignificance.significant, StatisticalSignificance.fromPValue(0.03));
    try std.testing.expectEqual(StatisticalSignificance.marginal, StatisticalSignificance.fromPValue(0.08));
    try std.testing.expectEqual(StatisticalSignificance.not_significant, StatisticalSignificance.fromPValue(0.15));
}

test "StatisticalSignificance formatting" {
    try std.testing.expectEqual("***", StatisticalSignificance.extremely_significant.toEmoji());
    try std.testing.expectEqual("**", StatisticalSignificance.very_significant.toEmoji());
    try std.testing.expectEqual("*", StatisticalSignificance.significant.toEmoji());
    try std.testing.expectEqual("†", StatisticalSignificance.marginal.toEmoji());
    try std.testing.expectEqual("", StatisticalSignificance.not_significant.toEmoji());
}

test "ConfidenceInterval width" {
    const ci = ConfidenceInterval{ .lower = 1.0, .upper = 3.0 };
    try std.testing.expectEqual(2.0, ci.width());
    try std.testing.expectEqual(2.0, ci.center());
}

test "StatisticalTestResult isSignificantAt" {
    const result = StatisticalTestResult{
        .test_name = .t_test,
        .statistic_value = 2.5,
        .p_value = 0.01,
        .sample_size_n = 100,
        .significance = StatisticalSignificance.very_significant,
    };

    try std.testing.expect(result.isSignificantAt(0.05));
    try std.testing.expect(result.isSignificantAt(0.10));
    try std.testing.expect(!result.isSignificantAt(0.001));
}

test "ExperimentComparisonEnhanced formatAsMarkdown" {
    const results = [_]ExperimentResultEnhanced{
        .{
            .experiment_name = "Baseline",
            .metric_name = "Accuracy",
            .metric_value = 90.0,
            .sample_size = 1000,
        },
        .{
            .experiment_name = "Ours",
            .metric_name = "Accuracy",
            .metric_value = 95.0,
            .sample_size = 1000,
            .is_best = true,
        },
    };

    const comp = ExperimentComparisonEnhanced{
        .caption = "Accuracy Comparison",
        .comparison_metric = "Accuracy (%)",
        .higher_is_better = true,
        .results = &results,
    };

    const md = try comp.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "### Accuracy Comparison") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "| Ours | 95.000 |") != null);
}
