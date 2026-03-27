// ═════════════════════════════════════════════════════════════════════════════════
// V110: CITATION NETWORK & PEER REVIEW MANAGEMENT
// ═════════════════════════════════════════════════════════════════════════════════

const std = @import("std");

/// Citation graph node representing a publication
pub const CitationNode = struct {
    doi: []const u8,
    title: []const u8,
    year: u32,
    venue: []const u8,
    citation_count: u32,
    authors: []const []const u8,
};

/// Citation edge linking two publications
pub const CitationEdge = struct {
    from_doi: []const u8,
    to_doi: []const u8,
    context: ?[]const u8 = null,
    citation_type: CitationType = .background,

    pub const CitationType = enum {
        background,
        method,
        result,
        compare,
        contrast,
        extends,
        survey,
    };
};

/// Citation graph for tracking influence and h-index
pub const CitationGraph = struct {
    nodes: []const CitationNode,
    edges: []const CitationEdge,
    built_date: i64,

    /// Find most influential papers (by citation count)
    pub fn findInfluence(self: *const CitationGraph, allocator: std.mem.Allocator, n: usize) ![][]const u8 {
        var sorted = try std.ArrayList(CitationNode).initCapacity(allocator, self.nodes.len);
        defer sorted.deinit(allocator);

        for (self.nodes) |node| {
            try sorted.append(allocator, node);
        }

        // Sort by citation count (descending)
        std.sort.insertion(CitationNode, sorted.items, {}, struct {
            fn lessThan(_: void, a: CitationNode, b: CitationNode) bool {
                return a.citation_count > b.citation_count;
            }
        }.lessThan);

        const result_n = @min(n, sorted.items.len);
        const result = try allocator.alloc([]const u8, result_n);

        for (sorted.items[0..result_n], 0..) |node, i| {
            const title_copy = try allocator.dupe(u8, node.title);
            result[i] = title_copy;
        }

        return result;
    }

    /// Calculate h-index from citation graph
    pub fn calculateHIndex(self: *const CitationGraph) u32 {
        if (self.nodes.len == 0) return 0;

        var h_index: u32 = 0;
        for (self.nodes) |node| {
            if (node.citation_count >= h_index + 1) {
                h_index += 1;
            }
        }
        return h_index;
    }
};

test "CitationGraph - calculates h-index" {
    const nodes = [_]CitationNode{
        .{ .doi = "10.1234/1", .title = "Paper A", .year = 2020, .venue = "NeurIPS", .citation_count = 10, .authors = &[_][]const u8{"Author 1"} },
        .{ .doi = "10.1234/2", .title = "Paper B", .year = 2021, .venue = "ICLR", .citation_count = 5, .authors = &[_][]const u8{"Author 1"} },
        .{ .doi = "10.1234/3", .title = "Paper C", .year = 2022, .venue = "ICML", .citation_count = 3, .authors = &[_][]const u8{"Author 2"} },
        .{ .doi = "10.1234/4", .title = "Paper D", .year = 2023, .venue = "AAAI", .citation_count = 0, .authors = &[_][]const u8{"Author 2"} },
    };

    const graph = CitationGraph{
        .nodes = &nodes,
        .edges = &[_]CitationEdge{},
        .built_date = 0,
    };

    const h_index = graph.calculateHIndex();
    try std.testing.expectEqual(@as(u32, 3), h_index);
}

test "CitationGraph - finds influential papers" {
    const nodes = [_]CitationNode{
        .{ .doi = "10.1234/1", .title = "High Impact Paper", .year = 2020, .venue = "NeurIPS", .citation_count = 100, .authors = &[_][]const u8{"Author 1"} },
        .{ .doi = "10.1234/2", .title = "Medium Impact", .year = 2021, .venue = "ICLR", .citation_count = 50, .authors = &[_][]const u8{"Author 1"} },
        .{ .doi = "10.1234/3", .title = "Low Impact", .year = 2022, .venue = "ICML", .citation_count = 5, .authors = &[_][]const u8{"Author 2"} },
    };

    const graph = CitationGraph{
        .nodes = &nodes,
        .edges = &[_]CitationEdge{},
        .built_date = 0,
    };

    const influential = try graph.findInfluence(std.testing.allocator, 2);
    defer {
        for (influential) |title| std.testing.allocator.free(title);
        std.testing.allocator.free(influential);
    }

    try std.testing.expectEqual(@as(usize, 2), influential.len);
    try std.testing.expectEqualStrings("High Impact Paper", influential[0]);
}

// ═══════════════════════════════════════════════════════════════════════════
// PEER REVIEW STRUCTURES (depend on zenodo_templates)
// ═══════════════════════════════════════════════════════════════════════════

// Note: These structures reference types from zenodo_templates.zig:
// - Conference, PeerReviewScore
// For full functionality, integrate V110 into zenodo_templates.zig

/// Peer review confidence level
pub const ReviewConfidence = enum(u8) {
    very_low = 1,
    low = 2,
    neutral = 3,
    high = 4,
    very_high = 5,

    pub fn toString(self: ReviewConfidence) []const u8 {
        return switch (self) {
            .very_low => "Very Low",
            .low => "Low",
            .neutral => "Neutral",
            .high => "High",
            .very_high => "Very High",
        };
    }
};

/// Portal review comment with metadata
pub const PortalReviewComment = struct {
    section: ReviewSection,
    text: []const u8,
    severity: CommentSeverity,

    pub const ReviewSection = enum {
        abstract,
        introduction,
        method,
        results,
        discussion,
        conclusion,
        references,
        general,
    };

    pub const CommentSeverity = enum {
        critical,
        major,
        minor,
        nit,
    };
};

/// Rebuttal response draft
pub const ResponseDraft = struct {
    review_id: []const u8,
    responded: bool = false,
    responses: []const CommentResponse,
    submitted_at: ?i64 = null,

    pub const CommentResponse = struct {
        original_comment: []const u8,
        response_text: []const u8,
        accepted_changes: bool,
    };
};

/// Citation sentiment classification
pub const CitationSentiment = enum {
    positive,
    neutral,
    negative,
    critical,
};

/// Semantic citation with context and sentiment
pub const SemanticCitation = struct {
    from: []const u8,
    to: []const u8,
    citation_type: CitationEdge.CitationType,
    sentiment: CitationSentiment,
    relevance: f32,
    context: ?[]const u8 = null,

    /// Classify sentiment from text (heuristic)
    pub fn classifySentiment(text: []const u8) CitationSentiment {
        const lower = std.ascii.allocLowerString(std.heap.page_allocator, text) catch return .neutral;
        defer std.heap.page_allocator.free(lower);

        const positive_keywords = [_][]const u8{ "excellent", "outstanding", "remarkable", "novel", "innovative", "strong" };
        const negative_keywords = [_][]const u8{ "weak", "limited", "fails", "inadequate", "poor", "insufficient" };
        const critical_keywords = [_][]const u8{ "however", "but", "although", "despite", "unfortunately" };

        var has_critical = false;
        for (critical_keywords) |kw| {
            if (std.mem.indexOf(u8, lower, kw) != null) {
                has_critical = true;
                break;
            }
        }

        var positive_count: usize = 0;
        var negative_count: usize = 0;

        for (positive_keywords) |kw| {
            if (std.mem.indexOf(u8, lower, kw) != null) positive_count += 1;
        }
        for (negative_keywords) |kw| {
            if (std.mem.indexOf(u8, lower, kw) != null) negative_count += 1;
        }

        if (has_critical) return .critical;
        if (positive_count > negative_count) return .positive;
        if (negative_count > positive_count) return .negative;
        return .neutral;
    }
};

test "SemanticCitation - classifies sentiment" {
    try std.testing.expectEqual(CitationSentiment.positive, SemanticCitation.classifySentiment("This is an excellent and outstanding work."));
    try std.testing.expectEqual(CitationSentiment.negative, SemanticCitation.classifySentiment("The method has weak and limited results."));
    try std.testing.expectEqual(CitationSentiment.critical, SemanticCitation.classifySentiment("However, the approach fails to handle edge cases."));
    try std.testing.expectEqual(CitationSentiment.neutral, SemanticCitation.classifySentiment("The paper presents a standard algorithm."));
}

// φ² + 1/φ² = 3 | TRINITY
