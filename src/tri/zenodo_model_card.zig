//! Zenodo V16: Model Card Template — ICLR/NeurIPS 2025 Compliance
//!
//! Model Card structure following:
//! - Mitchell et al. (2019) "Model Cards for Model Reporting"
//! - Gebru et al. (2021) "Model Cards for Model Reporting" (FACC/ICLR 2021)
//! - Hugging Face Model Card schema
//! - ICLR 2025 ethical considerations requirements

const std = @import("std");

/// Model type classification
pub const ModelType = enum {
    language_model,
    computer_vision,
    audio_model,
    multimodal,
    recommender,
    time_series,

    pub fn displayName(self: ModelType) []const u8 {
        return switch (self) {
            .language_model => "Language Model",
            .computer_vision => "Computer Vision Model",
            .audio_model => "Audio/Speech Model",
            .multimodal => "Multimodal Model",
            .recommender => "Recommender System",
            .time_series => "Time Series Model",
        };
    }
};

/// Model architecture details
pub const ModelArchitecture = struct {
    name: []const u8,
    num_parameters: u64,
    num_layers: u32,
    hidden_dim: u32,
    num_heads: ?u32 = null,
    context_length: ?u32 = null,
    activation: []const u8 = "relu",
    special_features: []const []const u8 = &.{},

    pub fn formatAsMarkdown(self: *const ModelArchitecture, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 256);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "**Architecture**: ");
        try result.appendSlice(allocator, self.name);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "- **Parameters**: ");
        try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}", .{self.num_parameters}));
        try result.appendSlice(allocator, " (");
        try result.appendSlice(allocator, self.formatParameterCount());
        try result.appendSlice(allocator, ")\n");

        try result.appendSlice(allocator, "- **Layers**: ");
        try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}", .{self.num_layers}));
        try result.appendSlice(allocator, "\n");

        try result.appendSlice(allocator, "- **Hidden Dimension**: ");
        try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}", .{self.hidden_dim}));
        try result.appendSlice(allocator, "\n");

        return result.toOwnedSlice(allocator);
    }

    fn formatParameterCount(self: *const ModelArchitecture) []const u8 {
        if (self.num_parameters >= 1_000_000_000)
            return "B+"
        else if (self.num_parameters >= 1_000_000)
            return "M+"
        else if (self.num_parameters >= 1_000)
            return "K+"
        else
            return "";
    }
};

/// Data split information
pub const DataSplit = struct {
    name: []const u8,
    size: u64,
    percentage: f64,
};

/// Training data information
pub const TrainingData = struct {
    name: []const u8,
    size: u64,
    source: []const u8,
    splits: []const DataSplit,
    preprocessing_steps: []const []const u8 = &.{},

    pub fn formatAsMarkdown(self: *const TrainingData, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 256);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "**Training Data**: ");
        try result.appendSlice(allocator, self.name);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "- **Size**: ");
        try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}", .{self.size}));
        try result.appendSlice(allocator, " samples/tokens\n");

        try result.appendSlice(allocator, "- **Source**: ");
        try result.appendSlice(allocator, self.source);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "**Data Splits**:\n");

        for (self.splits) |split| {
            try result.appendSlice(allocator, "- **");
            try result.appendSlice(allocator, split.name);
            try result.appendSlice(allocator, "**: ");
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}", .{split.size}));
            try result.appendSlice(allocator, " (");
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d:.1}%", .{split.percentage}));
            try result.appendSlice(allocator, ")\n");
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Ethical considerations (ICLR 2025 requirement)
pub const EthicalConsiderations = struct {
    primary_use: []const u8,
    primary_users: []const u8,
    out_of_scope_uses: []const []const u8,
    risks: []const []const u8,
    mitigations: []const []const u8,

    pub fn formatAsMarkdown(self: *const EthicalConsiderations, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 256);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "**Ethical Considerations**\n\n");

        try result.appendSlice(allocator, "**Primary Intended Use**: ");
        try result.appendSlice(allocator, self.primary_use);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "**Primary Intended Users**: ");
        try result.appendSlice(allocator, self.primary_users);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "**Out-of-Scope Uses**:\n");
        for (self.out_of_scope_uses, 0..) |use_case, i| {
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{i + 1, use_case}));
        }

        try result.appendSlice(allocator, "\n**Risks and Harms**:\n");
        for (self.risks, 0..) |risk, i| {
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{i + 1, risk}));
        }

        try result.appendSlice(allocator, "\n**Risk Mitigation**:\n");
        for (self.mitigations, 0..) |mitigation, i| {
            try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{i + 1, mitigation}));
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Model Card — complete ICLR/NeurIPS compliant model documentation
pub const ModelCard = struct {
    model_name: []const u8,
    model_version: []const u8,
    model_type: ModelType,
    license: []const u8,
    repository: ?[]const u8 = null,

    architecture: ?ModelArchitecture = null,
    training_data: ?TrainingData = null,
    ethics: ?EthicalConsiderations = null,
    limitations: ?[]const u8 = null,
    tradeoffs: ?[]const u8 = null,
    citation_bibtex: ?[]const u8 = null,

    pub fn formatAsMarkdown(self: *const ModelCard, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 512);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "# Model Card: ");
        try result.appendSlice(allocator, self.model_name);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "**Model Type**: ");
        try result.appendSlice(allocator, self.model_type.displayName());
        try result.appendSlice(allocator, "\n");

        if (self.repository) |repo| {
            try result.appendSlice(allocator, "\n**Repository**: ");
            try result.appendSlice(allocator, repo);
            try result.appendSlice(allocator, "\n");
        }

        if (self.architecture) |arch| {
            try result.appendSlice(allocator, "\n## Model Architecture\n");
            const arch_md = try arch.formatAsMarkdown(allocator);
            defer allocator.free(arch_md);
            try result.appendSlice(allocator, arch_md);
            try result.appendSlice(allocator, "\n");
        }

        if (self.training_data) |td| {
            try result.appendSlice(allocator, "\n## Training Data\n");
            const data_md = try td.formatAsMarkdown(allocator);
            defer allocator.free(data_md);
            try result.appendSlice(allocator, data_md);
            try result.appendSlice(allocator, "\n");
        }

        if (self.ethics) |eth| {
            try result.appendSlice(allocator, "\n## Ethical Considerations\n");
            const eth_md = try eth.formatAsMarkdown(allocator);
            defer allocator.free(eth_md);
            try result.appendSlice(allocator, eth_md);
            try result.appendSlice(allocator, "\n");
        }

        if (self.limitations) |lim| {
            try result.appendSlice(allocator, "\n## Limitations\n");
            for (lim) |limit| {
                try result.appendSlice(allocator, "- ");
                try result.appendSlice(allocator, limit);
                try result.appendSlice(allocator, "\n");
            }
        }

        if (self.tradeoffs) |to| {
            try result.appendSlice(allocator, "\n## Trade-offs\n");
            for (to) |tradeoff| {
                try result.appendSlice(allocator, "- ");
                try result.appendSlice(allocator, tradeoff);
                try result.appendSlice(allocator, "\n");
            }
        }

        if (self.citation_bibtex) |bib| {
            try result.appendSlice(allocator, "\n## Citation\n```bibtex\n");
            try result.appendSlice(allocator, bib);
            try result.appendSlice(allocator, "\n```\n");
        }

        try result.appendSlice(allocator, "\n## License\n");
        try result.appendSlice(allocator, self.license);

        return result.toOwnedSlice(allocator);
    }
};

// ═════════════════════════════════════════════════════════════════════════
// TESTS
// ═════════════════════════════════════════════════════════════════════════

test "ModelType displayName" {
    try std.testing.expectEqual("Language Model", ModelType.language_model.displayName());
    try std.testing.expectEqual("Computer Vision Model", ModelType.computer_vision.displayName());
    try std.testing.expectEqual("Audio/Speech Model", ModelType.audio_model.displayName());
}

test "ModelCard basic formatAsMarkdown" {
    const arch = ModelArchitecture{
        .name = "HSLM",
        .num_parameters = 1_950_000,
        .num_layers = 12,
        .hidden_dim = 768,
    };

    const data = TrainingData{
        .name = "TinyStories",
        .size = 57_000_000,
        .source = "Eldan & Li (2023)",
        .splits = &.{
            .{ .name = "train", .size = 50_000_000, .percentage = 87.7 },
            .{ .name = "validation", .size = 7_000_000, .percentage = 12.3 },
        },
    };

    const ethics = EthicalConsiderations{
        .primary_use = "Creative writing assistance",
        .primary_users = "Researchers, developers",
        .out_of_scope_uses = &.{"High-stakes decision making"},
        .risks = &.{"May generate incorrect information"},
        .mitigations = &.{"Human oversight required"},
    };

    const card = ModelCard{
        .model_name = "HSLM-v1",
        .model_version = "1.0",
        .model_type = .language_model,
        .license = "MIT",
        .repository = "https://github.com/gHashTag/trinity",
        .architecture = arch,
        .training_data = data,
        .ethics = ethics,
        .limitations = &.{"Small model, limited to English"},
        .tradeoffs = &.{"Quantization improves speed but reduces accuracy"},
    };

    const md = try card.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "# Model Card: HSLM-v1") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "## Model Architecture") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "## Training Data") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "## Ethical Considerations") != null);
}
