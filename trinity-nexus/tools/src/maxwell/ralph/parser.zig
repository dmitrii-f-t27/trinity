//! Markdown Parser for .ralph/*.md files
//! Parses fix_plan.md, TECH_TREE.md, SUCCESS_HISTORY.md, REGRESSION_PATTERNS.md

const std = @import("std");
const Allocator = std.mem.Allocator;

pub const FixPlanTask = struct {
    id: []const u8,
    description: []const u8,
    checked: bool,
    priority: Priority,
    status: TaskStatus,
    subtasks: []Subtask,
    acceptance_criteria: []AcceptanceCriterion,

    pub const Priority = enum { p0_critical, p1_high, p2_medium, p3_low };
    pub const TaskStatus = enum { pending, in_progress, complete, blocked };

    pub fn deinit(self: *FixPlanTask, allocator: Allocator) void {
        allocator.free(self.id);
        allocator.free(self.description);
        for (self.subtasks) |*st| st.deinit(allocator);
        allocator.free(self.subtasks);
        for (self.acceptance_criteria) |*ac| ac.deinit(allocator);
        allocator.free(self.acceptance_criteria);
    }
};

pub const Subtask = struct {
    description: []const u8,
    checked: bool,

    pub fn deinit(self: *Subtask, allocator: Allocator) void {
        allocator.free(self.description);
    }
};

pub const AcceptanceCriterion = struct {
    description: []const u8,
    met: bool,

    pub fn deinit(self: *AcceptanceCriterion, allocator: Allocator) void {
        allocator.free(self.description);
    }
};

pub const TechTreeNode = struct {
    id: []const u8,
    name: []const u8,
    status: NodeStatus,
    branch: []const u8,
    complexity: f64,
    impact: f64,
    dependencies: [][]const u8,
    description: []const u8,

    pub const NodeStatus = enum { available, in_progress, completed, locked };

    pub fn deinit(self: *TechTreeNode, allocator: Allocator) void {
        allocator.free(self.id);
        allocator.free(self.name);
        allocator.free(self.branch);
        allocator.free(self.description);
        for (self.dependencies) |dep| allocator.free(dep);
        allocator.free(self.dependencies);
    }
};

pub const SuccessPattern = struct {
    commit_sha: []const u8,
    description: []const u8,
    tags: [][]const u8,
    codeSnippet: ?[]const u8,

    pub fn deinit(self: *SuccessPattern, allocator: Allocator) void {
        allocator.free(self.commit_sha);
        allocator.free(self.description);
        for (self.tags) |tag| allocator.free(tag);
        allocator.free(self.tags);
        if (self.codeSnippet) |snippet| allocator.free(snippet);
    }
};

pub const RegressionPattern = struct {
    pattern_name: []const u8,
    description: []const u8,
    root_cause: []const u8,
    solution: []const u8,
    related_commits: [][]const u8,

    pub fn deinit(self: *RegressionPattern, allocator: Allocator) void {
        allocator.free(self.pattern_name);
        allocator.free(self.description);
        allocator.free(self.root_cause);
        allocator.free(self.solution);
        for (self.related_commits) |c| allocator.free(c);
        allocator.free(self.related_commits);
    }
};

// ============================================================================
// Fix Plan Parser
// ============================================================================

pub fn parseFixPlan(allocator: Allocator, content: []const u8) ![]FixPlanTask {
    // Use ArrayLists during parsing for efficient appending
    var tasks = try std.ArrayList(FixPlanTask).initCapacity(allocator, 0);
    errdefer {
        for (tasks.items) |*t| t.deinit(allocator);
        tasks.deinit(allocator);
    }

    // Track ArrayLists for current task's subtasks and acceptance criteria
    var current_subtasks = try std.ArrayList(Subtask).initCapacity(allocator, 0);
    defer current_subtasks.deinit(allocator);
    var current_criteria = try std.ArrayList(AcceptanceCriterion).initCapacity(allocator, 0);
    defer {
        for (current_criteria.items) |*c| c.deinit(allocator);
        current_criteria.deinit(allocator);
    }

    var lines = std.mem.splitScalar(u8, content, '\n');
    var in_acceptance = false;
    var in_subtasks = false;
    var task_count: usize = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");

        // Skip empty lines
        if (trimmed.len == 0) continue;

        // Check for acceptance criteria section
        if (std.mem.indexOf(u8, trimmed, "## Acceptance Criteria") != null) {
            in_acceptance = true;
            in_subtasks = false;
            continue;
        }

        // Check for tasks section
        if (std.mem.indexOf(u8, trimmed, "## Задачи") != null or
            std.mem.indexOf(u8, trimmed, "## Tasks") != null) {
            in_acceptance = false;
            in_subtasks = true;
            continue;
        }

        // Parse acceptance criteria: - [ ] description
        if (in_acceptance) {
            if (trimmed[0] == '-' and trimmed.len > 2) {
                const criterion = try parseCriterion(allocator, trimmed);
                try current_criteria.append(allocator, criterion);
            }
            continue;
        }

        // Parse tasks: - [ ] description
        if (in_subtasks) {
            // Top level task
            if (trimmed.len > 4 and trimmed[0] == '-' and trimmed[2] == '[') {
                // Save previous task if exists
                if (task_count > 0) {
                    const last_task = &tasks.items[tasks.items.len - 1];
                    last_task.subtasks = try current_subtasks.toOwnedSlice(allocator);
                    last_task.acceptance_criteria = try current_criteria.toOwnedSlice(allocator);
                    current_subtasks.clearRetainingCapacity();
                    current_criteria.clearAndFree(allocator);
                    _ = try current_criteria.ensureTotalCapacity(allocator, 0);
                }

                const checked = trimmed[3] == 'x' or trimmed[3] == 'X';
                const colon_idx = std.mem.indexOfScalar(u8, trimmed, ':') orelse trimmed.len;
                const desc_start = if (colon_idx < trimmed.len) colon_idx + 1 else 4;
                const description = std.mem.trim(u8, trimmed[desc_start..], " \t");

                const task_id = try std.fmt.allocPrint(allocator, "task{d}", .{task_count});
                const task = FixPlanTask{
                    .id = task_id,
                    .description = try allocator.dupe(u8, description),
                    .checked = checked,
                    .priority = .p2_medium,
                    .status = if (checked) .complete else .in_progress,
                    .subtasks = &.{},
                    .acceptance_criteria = &.{},
                };
                try tasks.append(allocator, task);
                task_count += 1;
            }
            // Subtask (indented)
            else if (trimmed.len > 6 and trimmed[0] == ' ' and trimmed[2] == '-' and trimmed[4] == '[') {
                const checked = trimmed[5] == 'x' or trimmed[5] == 'X';
                const desc_start = std.mem.indexOfScalar(u8, trimmed, ':') orelse 6;
                var subtask_desc = std.mem.trim(u8, trimmed[desc_start + 1 ..], " \t");
                if (subtask_desc.len == 0) subtask_desc = trimmed[desc_start..];

                const subtask = Subtask{
                    .description = try allocator.dupe(u8, subtask_desc),
                    .checked = checked,
                };
                try current_subtasks.append(allocator, subtask);
            }
        }
    }

    // Don't forget the last task
    if (task_count > 0) {
        const last_task = &tasks.items[tasks.items.len - 1];
        last_task.subtasks = try current_subtasks.toOwnedSlice(allocator);
        last_task.acceptance_criteria = try current_criteria.toOwnedSlice(allocator);
    }

    return try tasks.toOwnedSlice(allocator);
}

fn parseCriterion(allocator: Allocator, line: []const u8) !AcceptanceCriterion {
    const checked = line[3] == 'x' or line[3] == 'X';
    const desc_start = std.mem.indexOfScalar(u8, line, ']') orelse 3;
    var description = std.mem.trim(u8, line[desc_start + 1 ..], " \t");
    if (description.len > 0 and description[0] == '-') {
        description = std.mem.trim(u8, description[1..], " \t");
    }
    return AcceptanceCriterion{
        .description = try allocator.dupe(u8, description),
        .met = checked,
    };
}

// ============================================================================
// Tech Tree Parser
// ============================================================================

pub fn parseTechTree(allocator: Allocator, content: []const u8) !struct {
    in_progress: []TechTreeNode,
    available: []TechTreeNode,
    completed: []TechTreeNode,
    locked: []TechTreeNode,
} {
    var in_progress = try std.ArrayList(TechTreeNode).initCapacity(allocator, 0);
    var available = try std.ArrayList(TechTreeNode).initCapacity(allocator, 0);
    var completed = try std.ArrayList(TechTreeNode).initCapacity(allocator, 0);
    var locked = try std.ArrayList(TechTreeNode).initCapacity(allocator, 0);

    errdefer {
        cleanupNodeList(allocator, in_progress.items);
        cleanupNodeList(allocator, available.items);
        cleanupNodeList(allocator, completed.items);
        cleanupNodeList(allocator, locked.items);
    }

    var lines = std.mem.splitScalar(u8, content, '\n');
    var current_section: enum { none, in_progress, available, completed, locked } = .none;
    var in_table = false;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");

        // Detect section headers
        if (std.mem.indexOf(u8, trimmed, "## 🏗 In Progress") != null or
            std.mem.indexOf(u8, trimmed, "## In Progress") != null) {
            current_section = .in_progress;
            in_table = false;
            continue;
        }
        if (std.mem.indexOf(u8, trimmed, "## 🚀 Available") != null or
            std.mem.indexOf(u8, trimmed, "## Available") != null) {
            current_section = .available;
            in_table = false;
            continue;
        }
        if (std.mem.indexOf(u8, trimmed, "## ✅ Completed") != null or
            std.mem.indexOf(u8, trimmed, "## Recently Completed") != null) {
            current_section = .completed;
            in_table = false;
            continue;
        }
        if (std.mem.indexOf(u8, trimmed, "## 🔒 Locked") != null) {
            current_section = .locked;
            in_table = false;
            continue;
        }

        // Table header detection
        if (std.mem.startsWith(u8, trimmed, "|")) {
            if (std.mem.indexOf(u8, trimmed, "---") != null) {
                in_table = true;
                continue;
            }

            if (in_table) {
                const node = parseTableRow(allocator, trimmed) catch {
                    // Skip invalid rows
                    continue;
                };
                const target_list = switch (current_section) {
                    .in_progress => &in_progress,
                    .available => &available,
                    .completed => &completed,
                    .locked => &locked,
                    .none => continue,
                };
                try target_list.append(allocator, node);
            }
        }
    }

    return .{
        .in_progress = try in_progress.toOwnedSlice(allocator),
        .available = try available.toOwnedSlice(allocator),
        .completed = try completed.toOwnedSlice(allocator),
        .locked = try locked.toOwnedSlice(allocator),
    };
}

fn parseTableRow(allocator: Allocator, line: []const u8) !TechTreeNode {
    // Remove leading/trailing |
    var clean_line = line;
    if (clean_line.len > 0 and clean_line[0] == '|') clean_line = clean_line[1..];
    if (clean_line.len > 0 and clean_line[clean_line.len - 1] == '|')
        clean_line = clean_line[0 .. clean_line.len - 1];

    var parts = std.mem.splitScalar(u8, clean_line, '|');
    var id: []const u8 = "";
    var name: []const u8 = "";
    var branch: []const u8 = "";
    var metadata: []const u8 = "";

    var i: usize = 0;
    while (parts.next()) |part| {
        const trimmed = std.mem.trim(u8, part, " \t\r**");
        switch (i) {
            0 => id = trimmed,
            1 => name = trimmed,
            2 => branch = trimmed,
            3 => metadata = trimmed,
            else => {},
        }
        i += 1;
    }

    // Parse dependencies from metadata
    var deps = try std.ArrayList([]const u8).initCapacity(allocator, 0);
    if (std.mem.indexOf(u8, metadata, "❌") != null) {
        // Has unmet dependencies
        var dep_iter = std.mem.splitScalar(u8, metadata, ',');
        while (dep_iter.next()) |dep| {
            const trimmed = std.mem.trim(u8, dep, " ❌✅ ");
            if (trimmed.len > 0) {
                try deps.append(allocator, try allocator.dupe(u8, trimmed));
            }
        }
    }

    return TechTreeNode{
        .id = try allocator.dupe(u8, id),
        .name = try allocator.dupe(u8, name),
        .status = .available,
        .branch = try allocator.dupe(u8, branch),
        .complexity = 1.0,
        .impact = 1.0,
        .dependencies = try deps.toOwnedSlice(allocator),
        .description = try allocator.dupe(u8, metadata),
    };
}

fn cleanupNodeList(allocator: Allocator, nodes: []TechTreeNode) void {
    for (nodes) |*n| n.deinit(allocator);
    allocator.free(nodes);
}

// ============================================================================
// Success History Parser
// ============================================================================

pub fn parseSuccessHistory(allocator: Allocator, content: []const u8) ![]SuccessPattern {
    var patterns = try std.ArrayList(SuccessPattern).initCapacity(allocator, 0);
    errdefer {
        for (patterns.items) |*p| p.deinit(allocator);
        patterns.deinit(allocator);
    }

    var lines = std.mem.splitScalar(u8, content, '\n');
    var current_commit: ?[]const u8 = null;
    var current_desc = try std.ArrayList(u8).initCapacity(allocator, 0);
    var current_tags = try std.ArrayList([]const u8).initCapacity(allocator, 0);

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");

        // Commit SHA pattern: ## SHA or ### SHA
        if (std.mem.startsWith(u8, trimmed, "##") and !std.mem.startsWith(u8, trimmed, "###")) {
            // Save previous pattern
            if (current_commit) |sha| {
                const description = try current_desc.toOwnedSlice();
                const tags = try current_tags.toOwnedSlice();
                try patterns.append(SuccessPattern{
                    .commit_sha = sha,
                    .description = description,
                    .tags = tags,
                    .codeSnippet = null,
                });
                current_commit = null;
                current_desc.clearAndFree();
                current_tags = try std.ArrayList([]const u8).initCapacity(allocator, 0);
            }

            // Extract new SHA
            const sha_start = if (std.mem.indexOf(u8, trimmed, "#")) |idx|
                if (idx + 2 < trimmed.len) idx + 2 else trimmed.len
            else
                trimmed.len;
            const potential_sha = std.mem.trim(u8, trimmed[sha_start..], " \t\r#");
            if (potential_sha.len > 0) {
                current_commit = try allocator.dupe(u8, potential_sha);
            }
        } else if (current_commit != null) {
            try current_desc.appendSlice(line);
            try current_desc.append('\n');
        }
    }

    // Save last pattern
    if (current_commit) |sha| {
        const description = try current_desc.toOwnedSlice();
        const tags = try current_tags.toOwnedSlice();
        try patterns.append(SuccessPattern{
            .commit_sha = sha,
            .description = description,
            .tags = tags,
            .codeSnippet = null,
        });
    }

    return try patterns.toOwnedSlice();
}

// ============================================================================
// Regression Patterns Parser
// ============================================================================

pub fn parseRegressionPatterns(allocator: Allocator, content: []const u8) ![]RegressionPattern {
    var patterns = try std.ArrayList(RegressionPattern).initCapacity(allocator, 0);
    errdefer {
        for (patterns.items) |*p| p.deinit(allocator);
        patterns.deinit(allocator);
    }

    var lines = std.mem.splitScalar(u8, content, '\n');
    var current_pattern: ?*RegressionPattern = null;
    var current_field: enum { none, name, description, cause, solution, commits } = .none;
    var field_content = try std.ArrayList(u8).initCapacity(allocator, 0);

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");

        // Pattern header: ## Pattern Name
        if (std.mem.startsWith(u8, trimmed, "##") and !std.mem.startsWith(u8, trimmed, "###")) {
            // Save previous pattern
            if (current_pattern) |p| {
                switch (current_field) {
                    .description => p.description = try field_content.toOwnedSlice(allocator),
                    .cause => p.root_cause = try field_content.toOwnedSlice(allocator),
                    .solution => p.solution = try field_content.toOwnedSlice(allocator),
                    else => {},
                }
                field_content.clearAndFree();
                field_content = try std.ArrayList(u8).initCapacity(allocator, 0);
            }

            const name_start = std.mem.indexOf(u8, trimmed, "#") orelse 0;
            const name = std.mem.trim(u8, trimmed[name_start + 2 ..], " \t\r#");
            const pattern = RegressionPattern{
                .pattern_name = try allocator.dupe(u8, name),
                .description = &.{},
                .root_cause = &.{},
                .solution = &.{},
                .related_commits = &.{},
            };
            try patterns.append(pattern);
            current_pattern = &patterns.items[patterns.items.len - 1];
            current_field = .none;
        }
        // Field headers
        else if (std.mem.indexOf(u8, trimmed, "Description") != null or
            std.mem.indexOf(u8, trimmed, "Описание") != null) {
            if (current_pattern) |p| {
                switch (current_field) {
                    .description => p.description = try field_content.toOwnedSlice(allocator),
                    .cause => p.root_cause = try field_content.toOwnedSlice(allocator),
                    .solution => p.solution = try field_content.toOwnedSlice(allocator),
                    else => {},
                }
                field_content.clearAndFree();
                field_content = try std.ArrayList(u8).initCapacity(allocator, 0);
            }
            current_field = .description;
        }
        // Root cause
        else if (std.mem.indexOf(u8, trimmed, "Root Cause") != null or
            std.mem.indexOf(u8, trimmed, "Причина") != null) {
            if (current_pattern) |p| {
                switch (current_field) {
                    .description => p.description = try field_content.toOwnedSlice(allocator),
                    .cause => p.root_cause = try field_content.toOwnedSlice(allocator),
                    .solution => p.solution = try field_content.toOwnedSlice(allocator),
                    else => {},
                }
                field_content.clearAndFree();
                field_content = try std.ArrayList(u8).initCapacity(allocator, 0);
            }
            current_field = .cause;
        }
        // Solution
        else if (std.mem.indexOf(u8, trimmed, "Solution") != null or
            std.mem.indexOf(u8, trimmed, "Решение") != null) {
            if (current_pattern) |p| {
                switch (current_field) {
                    .description => p.description = try field_content.toOwnedSlice(allocator),
                    .cause => p.root_cause = try field_content.toOwnedSlice(allocator),
                    .solution => p.solution = try field_content.toOwnedSlice(allocator),
                    else => {},
                }
                field_content.clearAndFree();
                field_content = try std.ArrayList(u8).initCapacity(allocator, 0);
            }
            current_field = .solution;
        }
        // Content
        else if (current_pattern != null and current_field != .none) {
            try field_content.appendSlice(line);
            try field_content.append('\n');
        }
    }

    // Save last field
    if (current_pattern) |p| {
        const content_slice = try field_content.toOwnedSlice();
        switch (current_field) {
            .description => p.description = content_slice,
            .cause => p.root_cause = content_slice,
            .solution => p.solution = content_slice,
            else => allocator.free(content_slice),
        }
    }

    return try patterns.toOwnedSlice();
}

// ============================================================================
// Tests
// ============================================================================

test "parseFixPlan: basic task parsing" {
    const content =
        \\# Test Plan
        \\
        \\## Acceptance Criteria
        \\- [ ] First criterion
        \\- [x] Second criterion
        \\
        \\## Tasks
        \\- [ ] Task one description
        \\  - [ ] Subtask 1.1
        \\  - [x] Subtask 1.2
        \\- [x] Task two description
    ;

    const allocator = std.testing.allocator;
    const tasks = try parseFixPlan(allocator, content);
    defer {
        for (tasks) |*t| t.deinit(allocator);
        allocator.free(tasks);
    }

    try std.testing.expectEqual(@as(usize, 2), tasks.len);
    try std.testing.expect(!tasks[0].checked);
    try std.testing.expect(tasks[1].checked);
    try std.testing.expectEqual(@as(usize, 2), tasks[0].subtasks.len);
}

test "parseTechTree: basic table parsing" {
    const content =
        \\## In Progress
        \\| ID | Name | Branch | Progress |
        \\|----|------|--------|----------|
        \\| TASK-1 | Task One | main | 50% |
        \\
        \\## Available
        \\| ID | Name | Branch | Gain |
        \\|----|------|--------|------|
        \\| TASK-2 | Task Two | feature | High |
    ;

    const allocator = std.testing.allocator;
    const result = try parseTechTree(allocator, content);
    defer {
        for (result.in_progress) |*n| n.deinit(allocator);
        allocator.free(result.in_progress);
        for (result.available) |*n| n.deinit(allocator);
        allocator.free(result.available);
        for (result.completed) |*n| n.deinit(allocator);
        allocator.free(result.completed);
        for (result.locked) |*n| n.deinit(allocator);
        allocator.free(result.locked);
    }

    try std.testing.expectEqual(@as(usize, 1), result.in_progress.len);
    try std.testing.expectEqual(@as(usize, 1), result.available.len);
    try std.testing.expectEqualStrings("TASK-1", result.in_progress[0].id);
    try std.testing.expectEqualStrings("Task One", result.in_progress[0].name);
}
