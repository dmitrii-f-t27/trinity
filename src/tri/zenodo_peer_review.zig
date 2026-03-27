//! Zenodo V16: Peer Review Workflow Integration
//!
//! Peer review management following:
//! - ICLR/NeurIPS review format
//! - OpenReview structured reviews
//! - Rebuttal/response best practices
//! - Review scoring systems (1-10)

const std = @import("std");

/// Review score (1-10 scale)
pub const ReviewScore = enum(u8) {
    /// Reject (1-2)
    reject_1 = 1,
    reject_2 = 2,
    /// Weak Reject (3-4)
    weak_reject_3 = 3,
    weak_reject_4 = 4,
    /// Borderline (5-6)
    borderline_5 = 5,
    borderline_6 = 6,
    /// Weak Accept (7-8)
    weak_accept_7 = 7,
    weak_accept_8 = 8,
    /// Accept (9-10)
    accept_9 = 9,
    accept_10 = 10,

    pub fn fromScore(score: u8) !ReviewScore {
        if (score < 1 or score > 10) return error.InvalidScore;
        return @enumFromInt(score);
    }

    pub fn displayName(self: ReviewScore) []const u8 {
        return switch (self) {
            .reject_1, .reject_2 => "Reject",
            .weak_reject_3, .weak_reject_4 => "Weak Reject",
            .borderline_5, .borderline_6 => "Borderline",
            .weak_accept_7, .weak_accept_8 => "Weak Accept",
            .accept_9, .accept_10 => "Accept",
        };
    }

    pub fn toEmoji(self: ReviewScore) []const u8 {
        return switch (self) {
            .reject_1, .reject_2 => "🔴",
            .weak_reject_3, .weak_reject_4 => "🟠",
            .borderline_5, .borderline_6 => "🟡",
            .weak_accept_7, .weak_accept_8 => "🟢",
            .accept_9, .accept_10 => "✅",
        };
    }
};

/// Confidence level of reviewer
pub const ConfidenceLevel = enum(u4) {
    very_low = 1,
    low = 2,
    medium = 3,
    high = 4,
    very_high = 5,

    pub fn displayName(self: ConfidenceLevel) []const u8 {
        return switch (self) {
            .very_low => "Very Low",
            .low => "Low",
            .medium => "Medium",
            .high => "High",
            .very_high => "Very High",
        };
    }
};

/// Review comment with action
pub const ReviewComment = struct {
    /// Comment ID
    id: u32,
    /// Comment text
    text: []const u8,
    /// Suggested action (auto-detected from text)
    action: ?ReviewAction = null,
    /// Section reference (e.g., "Section 3.2")
    section: ?[]const u8 = null,
    /// Is this a major concern?
    is_major: bool = false,
    /// Has been addressed?
    addressed: bool = false,
};

/// Review action type
pub const ReviewAction = enum {
    clarification,
    fix_bug,
    add_experiment,
    add_citation,
    improve_writing,
    reorganize,
    expand_discussion,
    other,

    pub fn displayName(self: ReviewAction) []const u8 {
        return switch (self) {
            .clarification => "Clarification",
            .fix_bug => "Fix Bug",
            .add_experiment => "Add Experiment",
            .add_citation => "Add Citation",
            .improve_writing => "Improve Writing",
            .reorganize => "Reorganize",
            .expand_discussion => "Expand Discussion",
            .other => "Other",
        };
    }

    pub fn toEmoji(self: ReviewAction) []const u8 {
        return switch (self) {
            .clarification => "❓",
            .fix_bug => "🐛",
            .add_experiment => "🧪",
            .add_citation => "📚",
            .improve_writing => "✍️",
            .reorganize => "📁",
            .expand_discussion => "💬",
            .other => "📝",
        };
    }

    /// Detect action from comment text
    pub fn detectFromText(text: []const u8) ?ReviewAction {
        // Simple keyword detection (case-insensitive not implemented for brevity)
        if (std.mem.indexOf(u8, text, "clarif") != null) return .clarification;
        if (std.mem.indexOf(u8, text, "bug") != null or std.mem.indexOf(u8, text, "error") != null) return .fix_bug;
        if (std.mem.indexOf(u8, text, "experiment") != null) return .add_experiment;
        if (std.mem.indexOf(u8, text, "cite") != null) return .add_citation;
        if (std.mem.indexOf(u8, text, "reference") != null) return .add_citation;
        if (std.mem.indexOf(u8, text, "writing") != null) return .improve_writing;
        if (std.mem.indexOf(u8, text, "grammar") != null) return .improve_writing;
        if (std.mem.indexOf(u8, text, "organiz") != null) return .reorganize;
        if (std.mem.indexOf(u8, text, "discuss") != null) return .expand_discussion;

        return null;
    }
};

/// Individual reviewer
pub const Reviewer = struct {
    /// Reviewer ID
    id: []const u8,
    /// Reviewer name (optional, can be anonymous)
    name: ?[]const u8 = null,
    /// Has conflict of interest?
    has_conflict: bool = false,
    /// Assigned?
    assigned: bool = false,
    /// Submitted review?
    submitted: bool = false,
};

/// Peer review workflow
pub const PeerReviewWorkflow = struct {
    paper_id: []const u8,
    paper_title: []const u8,
    venue: []const u8,
    submission_round: u32,
    deadline: i64,

    reviewers: std.StringHashMap(Reviewer),
    comments: std.ArrayList(ReviewComment),
    next_comment_id: u32 = 1,

    pub fn init(allocator: std.mem.Allocator, paper_id: []const u8, paper_title: []const u8, venue: []const u8) PeerReviewWorkflow {
        return .{
            .paper_id = paper_id,
            .paper_title = paper_title,
            .venue = venue,
            .submission_round = 1,
            .deadline = 0,
            .reviewers = std.StringHashMap(Reviewer).init(allocator),
            .comments = std.ArrayList(ReviewComment).initCapacity(allocator, 16) catch unreachable,
        };
    }

    pub fn deinit(self: *PeerReviewWorkflow, allocator: std.mem.Allocator) void {
        var iter = self.reviewers.iterator();
        while (iter.next()) |entry| {
            if (entry.value_ptr.name) |name| {
                allocator.free(name);
            }
        }
        self.reviewers.deinit();
        self.comments.deinit(allocator);
    }

    /// Assign reviewer to paper
    pub fn assignReviewer(self: *PeerReviewWorkflow, allocator: std.mem.Allocator, reviewer_id: []const u8, name: ?[]const u8) !void {
        const name_clone = if (name) |n|
            try allocator.dupe(u8, n)
        else
            null;

        try self.reviewers.put(reviewer_id, .{
            .id = reviewer_id,
            .name = name_clone,
            .has_conflict = false,
            .assigned = true,
            .submitted = false,
        });
    }

    /// Mark reviewer as having conflict of interest
    pub fn markConflict(self: *PeerReviewWorkflow, reviewer_id: []const u8) !void {
        var entry = self.reviewers.getPtr(reviewer_id) orelse return error.ReviewerNotFound;
        entry.has_conflict = true;
        entry.assigned = false;
    }

    /// Add comment with auto-detected action
    pub fn addComment(self: *PeerReviewWorkflow, allocator: std.mem.Allocator, text: []const u8, section: ?[]const u8, is_major: bool) !u32 {
        const action = ReviewAction.detectFromText(text);
        const comment_id = self.next_comment_id;
        self.next_comment_id += 1;

        try self.comments.append(allocator, .{
            .id = comment_id,
            .text = text,
            .action = action,
            .section = section,
            .is_major = is_major,
            .addressed = false,
        });

        return comment_id;
    }

    /// Mark comment as addressed
    pub fn markAddressed(self: *PeerReviewWorkflow, comment_id: u32) !void {
        for (self.comments.items) |*comment| {
            if (comment.id == comment_id) {
                comment.addressed = true;
                return;
            }
        }
        return error.CommentNotFound;
    }

    /// Generate response document with color coding
    pub fn generateResponse(self: *const PeerReviewWorkflow, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 1024);
        defer result.deinit(allocator);
        const writer = result.writer(allocator);

        // Header
        try writer.print("# Response to Reviewers\n\n", .{});
        try writer.print("**Paper**: {s}\n", .{self.paper_title});
        try writer.print("**Venue**: {s}\n\n", .{self.venue});

        // Summary
        try writer.print("## Summary\n\n", .{});
        const major_count = self.countMajor();
        const addressed_count = self.countAddressed();
        try writer.print("- Total comments: {d}\n", .{self.comments.items.len});
        try writer.print("- Major concerns: {d}\n", .{major_count});
        try writer.print("- Addressed: {d}\n\n", .{addressed_count});

        // Comments by action type
        try writer.print("## Detailed Response\n\n", .{});

        var action_groups = std.AutoHashMap(ReviewAction, std.ArrayList(u32)).init(allocator);
        defer {
            var iter = action_groups.iterator();
            while (iter.next()) |entry| {
                entry.value_ptr.deinit(allocator);
            }
            action_groups.deinit();
        }

        // Group comments by action
        for (self.comments.items) |comment| {
            if (comment.action) |action| {
                const entry = try action_groups.getOrPut(action);
                if (!entry.found_existing) {
                    entry.value_ptr.* = std.ArrayList(u32).initCapacity(allocator, 4) catch unreachable;
                }
                try entry.value_ptr.append(allocator, comment.id);
            }
        }

        // Output grouped comments
        const actions_order = [_]ReviewAction{
            .fix_bug,         .add_experiment, .add_citation,      .clarification,
            .improve_writing, .reorganize,     .expand_discussion, .other,
        };

        for (actions_order) |action| {
            if (action_groups.get(action)) |comment_ids| {
                if (comment_ids.items.len == 0) continue;

                try writer.print("{s} {s}\n\n", .{ action.toEmoji(), action.displayName() });

                for (comment_ids.items) |cid| {
                    const comment = self.getCommentById(cid) orelse continue;
                    try writer.print("**Comment {d}**: {s}\n", .{ cid, comment.text });
                    const status_emoji = if (comment.addressed) "✅" else "⏳";
                    const status_text = if (comment.addressed) "Addressed" else "Pending";
                    try writer.print("{s} **Status**: {s}\n\n", .{ status_emoji, status_text });
                }
            }
        }

        // Ungrouped comments
        try writer.print("## Other Comments\n\n", .{});
        for (self.comments.items) |comment| {
            if (comment.action == null) {
                try writer.print("**Comment {d}**: {s}\n\n", .{ comment.id, comment.text });
            }
        }

        return result.toOwnedSlice(allocator);
    }

    fn countMajor(self: *const PeerReviewWorkflow) u32 {
        var count: u32 = 0;
        for (self.comments.items) |comment| {
            if (comment.is_major) count += 1;
        }
        return count;
    }

    fn countAddressed(self: *const PeerReviewWorkflow) u32 {
        var count: u32 = 0;
        for (self.comments.items) |comment| {
            if (comment.addressed) count += 1;
        }
        return count;
    }

    fn getCommentById(self: *const PeerReviewWorkflow, id: u32) ?*const ReviewComment {
        for (self.comments.items) |*comment| {
            if (comment.id == id) return comment;
        }
        return null;
    }

    /// Generate review summary score
    pub fn calculateAverageScore(self: *const PeerReviewWorkflow, scores: []const ReviewScore) f64 {
        _ = self;
        if (scores.len == 0) return 0.0;

        var sum: f64 = 0.0;
        for (scores) |score| {
            sum += @as(f64, @floatFromInt(@intFromEnum(score)));
        }
        return sum / @as(f64, @floatFromInt(scores.len));
    }
};

// ═════════════════════════════════════════════════════════════════════════
// TESTS
// ═════════════════════════════════════════════════════════════════════════

test "ReviewScore fromScore" {
    const score1 = try ReviewScore.fromScore(5);
    try std.testing.expectEqual(ReviewScore.borderline_5, score1);
    try std.testing.expectEqual("Borderline", score1.displayName());

    const score2 = try ReviewScore.fromScore(10);
    try std.testing.expectEqual(ReviewScore.accept_10, score2);
}

test "ReviewScore toEmoji" {
    try std.testing.expectEqual("🔴", ReviewScore.reject_1.toEmoji());
    try std.testing.expectEqual("🟡", ReviewScore.borderline_5.toEmoji());
    try std.testing.expectEqual("✅", ReviewScore.accept_10.toEmoji());
}

test "ReviewAction detectFromText" {
    const action1 = ReviewAction.detectFromText("Please clarify this section");
    try std.testing.expectEqual(ReviewAction.clarification, action1);

    const action2 = ReviewAction.detectFromText("There is a bug in line 42");
    try std.testing.expectEqual(ReviewAction.fix_bug, action2);

    const action3 = ReviewAction.detectFromText("Random text without keywords");
    try std.testing.expectEqual(@as(?ReviewAction, null), action3);
}

test "PeerReviewWorkflow basic" {
    var workflow = PeerReviewWorkflow.init(std.testing.allocator, "test-paper", "Test Paper", "ICLR 2025");
    defer workflow.deinit(std.testing.allocator);

    try workflow.assignReviewer(std.testing.allocator, "reviewer1", "Alice");
    try workflow.assignReviewer(std.testing.allocator, "reviewer2", "Bob");

    const comment_id = try workflow.addComment(std.testing.allocator, "Please clarify the method", "Section 3", true);

    try std.testing.expectEqual(@as(u32, 1), comment_id);
    try std.testing.expectEqual(@as(usize, 2), workflow.reviewers.count());
}

test "PeerReviewWorkflow generateResponse" {
    var workflow = PeerReviewWorkflow.init(std.testing.allocator, "test-paper", "Test Paper", "NeurIPS 2025");
    defer workflow.deinit(std.testing.allocator);

    _ = try workflow.addComment(std.testing.allocator, "There is a bug in line 42", "Section 4", true);
    _ = try workflow.addComment(std.testing.allocator, "Please add more experiments", "Section 5", true);

    const response = try workflow.generateResponse(std.testing.allocator);
    defer std.testing.allocator.free(response);

    try std.testing.expect(std.mem.indexOf(u8, response, "# Response to Reviewers") != null);
    try std.testing.expect(std.mem.indexOf(u8, response, "Test Paper") != null);
    try std.testing.expect(std.mem.indexOf(u8, response, "NeurIPS 2025") != null);
    try std.testing.expect(std.mem.indexOf(u8, response, "🐛") != null);
}
