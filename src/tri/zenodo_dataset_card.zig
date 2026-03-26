//! Zenodo V16: Dataset Card Template — NeurIPS 2025 Compliance
//!
//! Dataset Card structure following:
//! - Gebru et al. (2021) "Datasheets for Datasets"
//! - NeurIPS 2025 dataset documentation requirements
//! - Hugging Face Dataset Card schema
//! - FAIR principles for dataset documentation

const std = @import("std");

/// Motivation for dataset creation
pub const DatasetMotivation = enum {
    /// Academic research
    academic_research,
    /// Commercial application
    commercial,
    /// Educational purposes
    educational,
    /// Government/public sector
    government,
    /// Personal project
    personal,
    /// Other
    other,

    pub fn displayName(self: DatasetMotivation) []const u8 {
        return switch (self) {
            .academic_research => "Academic Research",
            .commercial => "Commercial Application",
            .educational => "Educational",
            .government => "Government/Public Sector",
            .personal => "Personal Project",
            .other => "Other",
        };
    }
};

/// Data split information
pub const DataSplit = struct {
    name: []const u8,
    size: u64,
    percentage: f64,
    description: []const u8 = "",
};

/// Data source provenance
pub const DataSource = struct {
    /// Source type (e.g., "web-scraped", "synthetic", "human-annotated")
    source_type: []const u8,
    /// Collection date range (ISO 8601)
    collection_date_start: ?[]const u8 = null,
    collection_date_end: ?[]const u8 = null,
    /// Collection location/region
    collection_location: ?[]const u8 = null,
    /// Original source URL if applicable
    source_url: ?[]const u8 = null,
    /// Contact information for source
    contact: ?[]const u8 = null,

    pub fn formatAsMarkdown(self: *const DataSource, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 256);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "**Source Type**: ");
        try result.appendSlice(allocator, self.source_type);
        try result.appendSlice(allocator, "\n");

        if (self.collection_date_start) |start| {
            try result.appendSlice(allocator, "**Collection Period**: ");
            try result.appendSlice(allocator, start);
            if (self.collection_date_end) |end| {
                try result.appendSlice(allocator, " to ");
                try result.appendSlice(allocator, end);
            }
            try result.appendSlice(allocator, "\n");
        }

        if (self.collection_location) |loc| {
            try result.appendSlice(allocator, "**Collection Location**: ");
            try result.appendSlice(allocator, loc);
            try result.appendSlice(allocator, "\n");
        }

        if (self.source_url) |url| {
            try result.appendSlice(allocator, "**Source URL**: ");
            try result.appendSlice(allocator, url);
            try result.appendSlice(allocator, "\n");
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Bias assessment for dataset
pub const BiasAssessment = struct {
    /// Known biases in the dataset
    known_biases: []const []const u8,
    /// Steps taken to mitigate bias
    mitigation_steps: []const []const u8 = &.{},
    /// Areas where bias may still exist
    remaining_concerns: []const []const u8 = &.{},

    pub fn formatAsMarkdown(self: *const BiasAssessment, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 512);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "**Known Biases**:\n");
        for (self.known_biases, 0..) |bias, i| {
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{ i + 1, bias }));
        }

        if (self.mitigation_steps.len > 0) {
            try result.appendSlice(allocator, "\n**Mitigation Steps**:\n");
            for (self.mitigation_steps, 0..) |step, i| {
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{ i + 1, step }));
            }
        }

        if (self.remaining_concerns.len > 0) {
            try result.appendSlice(allocator, "\n**Remaining Concerns**:\n");
            for (self.remaining_concerns, 0..) |concern, i| {
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{ i + 1, concern }));
            }
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Preprocessing step description
pub const PreprocessingStep = struct {
    step_name: []const u8,
    description: []const u8,
    parameters: []const []const u8 = &.{},
};

/// Dataset Card — complete NeurIPS compliant dataset documentation
pub const DatasetCard = struct {
    dataset_name: []const u8,
    dataset_version: []const u8,
    description: []const u8,

    /// Basic metadata
    homepage: ?[]const u8 = null,
    download_url: ?[]const u8 = null,
    license: []const u8,
    size_bytes: u64,
    num_examples: u64,

    /// Motivation
    motivation: DatasetMotivation,
    intended_use: []const u8,
    prohibited_use: ?[]const []const u8 = null,

    /// Data structure
    splits: []const DataSplit,
    source: DataSource,
    preprocessing: []const PreprocessingStep = &.{},

    /// Quality assessment
    bias_assessment: BiasAssessment,
    curation_rationale: ?[]const u8 = null,
    maintenance: ?[]const u8 = null,

    /// Citation
    citation_bibtex: ?[]const u8 = null,

    pub fn formatAsMarkdown(self: *const DatasetCard, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 1024);
        defer result.deinit(allocator);

        // Header
        try result.appendSlice(allocator, "# Dataset Card: ");
        try result.appendSlice(allocator, self.dataset_name);
        try result.appendSlice(allocator, "\n\n");

        // Basic info
        try result.appendSlice(allocator, "**Version**: ");
        try result.appendSlice(allocator, self.dataset_version);
        try result.appendSlice(allocator, "\n");

        if (self.homepage) |hp| {
            try result.appendSlice(allocator, "**Homepage**: ");
            try result.appendSlice(allocator, hp);
            try result.appendSlice(allocator, "\n");
        }

        if (self.download_url) |url| {
            try result.appendSlice(allocator, "**Download**: ");
            try result.appendSlice(allocator, url);
            try result.appendSlice(allocator, "\n");
        }

        try result.appendSlice(allocator, "**License**: ");
        try result.appendSlice(allocator, self.license);
        try result.appendSlice(allocator, "\n");

        try result.appendSlice(allocator, "\n## Dataset Description\n\n");
        try result.appendSlice(allocator, self.description);
        try result.appendSlice(allocator, "\n");

        // Motivation
        try result.appendSlice(allocator, "\n## Motivation\n\n");
        try result.appendSlice(allocator, "**Purpose**: ");
        try result.appendSlice(allocator, self.motivation.displayName());
        try result.appendSlice(allocator, "\n\n");
        try result.appendSlice(allocator, "**Intended Use**: ");
        try result.appendSlice(allocator, self.intended_use);
        try result.appendSlice(allocator, "\n");

        if (self.prohibited_use) |pu| {
            try result.appendSlice(allocator, "\n**Prohibited Use**:\n");
            for (pu, 0..) |prohibited, i| {
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{ i + 1, prohibited }));
            }
        }

        // Statistics
        try result.appendSlice(allocator, "\n## Dataset Statistics\n\n");
        try result.appendSlice(allocator, "**Size**: ");
        try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d} bytes", .{self.size_bytes}));
        try result.appendSlice(allocator, "\n");

        try result.appendSlice(allocator, "**Examples**: ");
        try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}", .{self.num_examples}));
        try result.appendSlice(allocator, "\n");

        // Splits
        try result.appendSlice(allocator, "\n## Data Splits\n\n");
        try result.appendSlice(allocator, "| Split | Size | Percentage | Description |\n");
        try result.appendSlice(allocator, "|-------|------|------------|-------------|\n");

        for (self.splits) |split| {
            try result.appendSlice(allocator, "| ");
            try result.appendSlice(allocator, split.name);
            try result.appendSlice(allocator, " | ");
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}", .{split.size}));
            try result.appendSlice(allocator, " | ");
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d:.1}%", .{split.percentage}));
            try result.appendSlice(allocator, "% | ");
            try result.appendSlice(allocator, split.description);
            try result.appendSlice(allocator, " |\n");
        }

        // Source
        try result.appendSlice(allocator, "\n## Data Source\n\n");
        const source_md = try self.source.formatAsMarkdown(allocator);
        defer allocator.free(source_md);
        try result.appendSlice(allocator, source_md);

        // Preprocessing
        if (self.preprocessing.len > 0) {
            try result.appendSlice(allocator, "\n## Preprocessing\n\n");
            for (self.preprocessing, 0..) |step, i| {
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. **{s}**: {s}\n", .{ i + 1, step.step_name, step.description }));
                for (step.parameters) |param| {
                    try result.appendSlice(allocator, "   - ");
                    try result.appendSlice(allocator, param);
                    try result.appendSlice(allocator, "\n");
                }
            }
        }

        // Bias Assessment
        try result.appendSlice(allocator, "\n## Bias Assessment\n\n");
        const bias_md = try self.bias_assessment.formatAsMarkdown(allocator);
        defer allocator.free(bias_md);
        try result.appendSlice(allocator, bias_md);

        // Curation Rationale
        if (self.curation_rationale) |cr| {
            try result.appendSlice(allocator, "\n## Curation Rationale\n\n");
            try result.appendSlice(allocator, cr);
            try result.appendSlice(allocator, "\n");
        }

        // Maintenance
        if (self.maintenance) |mnt| {
            try result.appendSlice(allocator, "\n## Maintenance\n\n");
            try result.appendSlice(allocator, mnt);
            try result.appendSlice(allocator, "\n");
        }

        // Citation
        if (self.citation_bibtex) |bib| {
            try result.appendSlice(allocator, "\n## Citation\n```bibtex\n");
            try result.appendSlice(allocator, bib);
            try result.appendSlice(allocator, "\n```\n");
        }

        return result.toOwnedSlice(allocator);
    }

    /// Format size as human-readable (KB, MB, GB)
    pub fn formatSize(self: *const DatasetCard, allocator: std.mem.Allocator) ![]u8 {
        if (self.size_bytes >= 1_000_000_000) {
            const gb = @as(f64, @floatFromInt(self.size_bytes)) / 1_000_000_000.0;
            return std.fmt.allocPrint(allocator, "{d:.2} GB", .{gb});
        } else if (self.size_bytes >= 1_000_000) {
            const mb = @as(f64, @floatFromInt(self.size_bytes)) / 1_000_000.0;
            return std.fmt.allocPrint(allocator, "{d:.2} MB", .{mb});
        } else if (self.size_bytes >= 1_000) {
            const kb = @as(f64, @floatFromInt(self.size_bytes)) / 1_000.0;
            return std.fmt.allocPrint(allocator, "{d:.2} KB", .{kb});
        } else {
            return std.fmt.allocPrint(allocator, "{d} bytes", .{self.size_bytes});
        }
    }
};

// ═════════════════════════════════════════════════════════════════════════
// TESTS
// ═════════════════════════════════════════════════════════════════════════

test "DatasetMotivation displayName" {
    try std.testing.expectEqual("Academic Research", DatasetMotivation.academic_research.displayName());
    try std.testing.expectEqual("Commercial Application", DatasetMotivation.commercial.displayName());
    try std.testing.expectEqual("Educational", DatasetMotivation.educational.displayName());
}

test "DataSource formatAsMarkdown" {
    const source = DataSource{
        .source_type = "synthetic",
        .collection_date_start = "2024-01-01",
        .collection_date_end = "2024-12-31",
        .collection_location = "United States",
        .source_url = "https://example.com/data",
    };

    const md = try source.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "synthetic") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "2024-01-01") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "United States") != null);
}

test "DatasetCard basic formatAsMarkdown" {
    const source = DataSource{
        .source_type = "synthetic",
        .collection_date_start = "2024-01-01",
    };

    const bias = BiasAssessment{
        .known_biases = &.{"English language bias"},
        .mitigation_steps = &.{"Balanced sampling"},
    };

    const splits = [_]DataSplit{
        .{ .name = "train", .size = 50_000, .percentage = 87.7, .description = "Training data" },
        .{ .name = "validation", .size = 7_000, .percentage = 12.3, .description = "Validation data" },
    };

    const card = DatasetCard{
        .dataset_name = "TinyStories-Ternary",
        .dataset_version = "1.0",
        .description = "Ternary-encoded version of TinyStories dataset for HSLM training.",
        .license = "MIT",
        .size_bytes = 57_000_000,
        .num_examples = 57_000,
        .motivation = .academic_research,
        .intended_use = "Research in ternary language models",
        .splits = &splits,
        .source = source,
        .bias_assessment = bias,
        .curation_rationale = "Selected for simplicity and ternary encoding research.",
    };

    const md = try card.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "# Dataset Card: TinyStories-Ternary") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "## Data Splits") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "## Bias Assessment") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "Academic Research") != null);
}

test "DatasetCard formatSize" {
    const card = DatasetCard{
        .dataset_name = "Test",
        .dataset_version = "1.0",
        .description = "Test dataset",
        .license = "MIT",
        .size_bytes = 1_500_000_000,
        .num_examples = 1000,
        .motivation = .academic_research,
        .intended_use = "Testing",
        .splits = &.{},
        .source = .{ .source_type = "test" },
        .bias_assessment = .{ .known_biases = &.{} },
    };

    const size_str = try card.formatSize(std.testing.allocator);
    defer std.testing.allocator.free(size_str);

    try std.testing.expect(std.mem.indexOf(u8, size_str, "GB") != null);
}
