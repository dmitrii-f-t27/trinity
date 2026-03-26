//! Zenodo V16: Enhanced LaTeX Table Generation
//!
//! Advanced table generation following:
//! - booktabs package (professional scientific tables)
//! - ICLR/NeurIPS/MLSys formatting standards
//! - Significance markers (*, **, ***)
//! - Rowspan/colspan support

const std = @import("std");

/// Table cell content type
pub const CellType = enum {
    plain,
    number,
    significance,
    emoji,
};

/// Cell alignment
pub const Alignment = enum {
    left,
    center,
    right,

    pub fn toLatex(self: Alignment) []const u8 {
        return switch (self) {
            .left => "l",
            .center => "c",
            .right => "r",
        };
    }
};

/// Table cell with optional attributes
pub const TableCell = struct {
    content: []const u8,
    alignment: Alignment = .left,
    cell_type: CellType = .plain,
    row_span: u32 = 1,
    col_span: u32 = 1,
    color: ?[]const u8 = null,
    bold: bool = false,

    pub fn formatAsLatex(self: *const TableCell, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 64);
        defer result.deinit(allocator);

        // Color wrapping if specified
        if (self.color) |color| {
            try result.appendSlice(allocator, "\\textcolor{");
            try result.appendSlice(allocator, color);
            try result.appendSlice(allocator, "}{");
        }

        // Bold wrapping
        if (self.bold) {
            try result.appendSlice(allocator, "\\textbf{");
        }

        try result.appendSlice(allocator, self.content);

        // Close bold
        if (self.bold) {
            try result.appendSlice(allocator, "}");
        }

        // Close color
        if (self.color) |_| {
            try result.appendSlice(allocator, "}");
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Table row with cells
pub const TableRow = struct {
    cells: []const TableCell,
    is_header: bool = false,
    is_footer: bool = false,

    pub fn formatAsLatex(self: *const TableRow, allocator: std.mem.Allocator, alignments: []const Alignment) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 256);
        defer result.deinit(allocator);

        for (self.cells, 0..) |cell, i| {
            // Rowspan/colspan markers
            if (cell.row_span > 1) {
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "\\multirow{{{d}}}{{*}}{{", .{cell.row_span}));
            }
            if (cell.col_span > 1) {
                const col_align = alignments[i].toLatex();
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "\\multicolumn{{{d}}}{{{s}}}{{", .{ cell.col_span, col_align }));
            }

            // Cell content
            try result.appendSlice(allocator, try cell.formatAsLatex(allocator));

            // Close multirow
            if (cell.row_span > 1) {
                try result.appendSlice(allocator, "}");
            }

            // Close multicolumn
            if (cell.col_span > 1) {
                try result.appendSlice(allocator, "}");
            }

            // Separator
            if (i < self.cells.len - 1) {
                try result.appendSlice(allocator, " & ");
            }
        }

        try result.appendSlice(allocator, " \\\\\n");
        return result.toOwnedSlice(allocator);
    }
};

/// Complete LaTeX table with booktabs styling
pub const LaTeXTable = struct {
    caption: []const u8,
    label: ?[]const u8 = null,
    columns: []const Alignment,
    rows: []const TableRow,
    booktabs: bool = true,
    top_rule: bool = true,
    bottom_rule: bool = true,
    mid_rules: bool = true,
    significance_level: f64 = 0.05,
    footnotes: []const []const u8 = &.{},

    pub fn formatAsLatex(self: *const LaTeXTable, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 1024);
        defer result.deinit(allocator);

        // Table environment
        try result.appendSlice(allocator, "\\begin{table}[htbp]\n");
        try result.appendSlice(allocator, "\\centering\n");

        // Caption
        try result.appendSlice(allocator, "\\caption{");
        try result.appendSlice(allocator, self.caption);
        try result.appendSlice(allocator, "}\n");

        // Label
        if (self.label) |lbl| {
            try result.appendSlice(allocator, "\\label{");
            try result.appendSlice(allocator, lbl);
            try result.appendSlice(allocator, "}\n");
        }

        // Tabular environment
        try result.appendSlice(allocator, "\\begin{tabular}{");

        // Column specifications
        for (self.columns, 0..) |col, i| {
            if (self.booktabs) {
                try result.appendSlice(allocator, "@{");
                try result.appendSlice(allocator, col.toLatex());
                try result.appendSlice(allocator, "}l");
            } else {
                try result.appendSlice(allocator, col.toLatex());
            }

            if (i < self.columns.len - 1) {
                try result.appendSlice(allocator, " ");
            }
        }
        try result.appendSlice(allocator, "}\n");

        // Top rule
        if (self.booktabs and self.top_rule) {
            try result.appendSlice(allocator, "\\toprule\n");
        }

        // Rows
        for (self.rows, 0..) |row, i| {
            const row_latex = try row.formatAsLatex(allocator, self.columns);
            defer allocator.free(row_latex);
            try result.appendSlice(allocator, row_latex);

            // Mid rule (after header, before footer)
            if (self.mid_rules and self.booktabs) {
                if (row.is_header and i < self.rows.len - 1 and !self.rows[i + 1].is_footer) {
                    try result.appendSlice(allocator, "\\midrule\n");
                } else if (i < self.rows.len - 1 and !row.is_footer and !self.rows[i + 1].is_header) {
                    try result.appendSlice(allocator, "\\midrule\n");
                }
            }
        }

        // Bottom rule
        if (self.booktabs and self.bottom_rule) {
            try result.appendSlice(allocator, "\\bottomrule\n");
        }

        // End tabular
        try result.appendSlice(allocator, "\\end{tabular}\n");

        // Footnotes
        if (self.footnotes.len > 0) {
            try result.appendSlice(allocator, "\\vspace{1em}\n");
            try result.appendSlice(allocator, "\\small\n");
            try result.appendSlice(allocator, "\\begin{tabular}{@{}l}\n");
            for (self.footnotes, 0..) |note, i| {
                try result.appendSlice(allocator, note);
                if (i < self.footnotes.len - 1) {
                    try result.appendSlice(allocator, "\\\\\n");
                }
            }
            try result.appendSlice(allocator, "\n\\end{tabular}\n");
        }

        // End table
        try result.appendSlice(allocator, "\\end{table}\n");

        return result.toOwnedSlice(allocator);
    }

    pub fn formatAsMarkdown(self: *const LaTeXTable, allocator: std.mem.Allocator) ![]u8 {
        var result = try std.ArrayList(u8).initCapacity(allocator, 512);
        defer result.deinit(allocator);

        // Caption
        try result.appendSlice(allocator, "### ");
        try result.appendSlice(allocator, self.caption);
        try result.appendSlice(allocator, "\n\n");

        // Header row
        if (self.rows.len > 0) {
            const header = self.rows[0];
            try result.appendSlice(allocator, "| ");
            for (header.cells) |cell| {
                try result.appendSlice(allocator, cell.content);
                try result.appendSlice(allocator, " | ");
            }
            try result.appendSlice(allocator, "\n");
        }

        // Separator
        try result.appendSlice(allocator, "|");
        for (0..self.columns.len) |_| {
            try result.appendSlice(allocator, "---|");
        }
        try result.appendSlice(allocator, "\n");

        // Data rows
        for (self.rows) |row| {
            if (row.is_header) continue;

            try result.appendSlice(allocator, "| ");
            for (row.cells) |cell| {
                try result.appendSlice(allocator, cell.content);
                try result.appendSlice(allocator, " | ");
            }
            try result.appendSlice(allocator, "\n");
        }

        // Footnotes
        if (self.footnotes.len > 0) {
            try result.appendSlice(allocator, "\n**Notes**:\n");
            for (self.footnotes, 0..) |note, i| {
                try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{d}. {s}\n", .{ i + 1, note }));
            }
        }

        return result.toOwnedSlice(allocator);
    }

    /// Generate comparison table with statistical significance
    pub fn createComparison(allocator: std.mem.Allocator, caption: []const u8, methods: []const []const u8, metrics: []const []const u8, values: []const []const f64, significances: ?[]const ?[]const []const u8, higher_is_better: []const bool) !LaTeXTable {
        var rows = try std.ArrayList(TableRow).initCapacity(allocator, methods.len + 1);
        defer rows.deinit(allocator);

        // Header row
        var header_cells = try std.ArrayList(TableCell).initCapacity(allocator, metrics.len + 1);
        defer header_cells.deinit(allocator);

        try header_cells.append(allocator, .{ .content = "Method", .is_header = true });
        for (metrics) |metric| {
            try header_cells.append(allocator, .{ .content = metric, .alignment = .right });
        }

        try rows.append(allocator, .{
            .cells = try header_cells.toOwnedSlice(allocator),
            .is_header = true,
        });

        // Data rows
        for (methods, 0..) |method, method_idx| {
            var cells = try std.ArrayList(TableCell).initCapacity(allocator, metrics.len + 1);
            defer cells.deinit(allocator);

            try cells.append(allocator, .{
                .content = method,
                .bold = higher_is_better[0],
            });

            for (metrics, 0..) |_, metric_idx| {
                const value = values[method_idx][metric_idx];
                const sig = if (significances) |sigs| sigs[method_idx][metric_idx] else null;
                var content = try std.fmt.allocPrint(allocator, "{d:.3}", .{value});

                if (sig) |s| {
                    const combined = try std.fmt.allocPrint(allocator, "{s}{s}", .{ content, s });
                    allocator.free(content);
                    content = combined;
                }

                try cells.append(allocator, .{
                    .content = content,
                    .alignment = .right,
                    .cell_type = .number,
                });
            }

            try rows.append(allocator, .{
                .cells = try cells.toOwnedSlice(allocator),
                .is_footer = method_idx == methods.len - 1,
            });
        }

        var alignments = try std.ArrayList(Alignment).initCapacity(allocator, metrics.len + 1);
        defer alignments.deinit(allocator);

        try alignments.append(allocator, .left);
        for (metrics) |_| {
            try alignments.append(allocator, .right);
        }

        return .{
            .caption = caption,
            .columns = try alignments.toOwnedSlice(allocator),
            .rows = try rows.toOwnedSlice(allocator),
            .footnotes = &.{ "\\(1) Best result in bold.", "* $p < 0.05$, ** $p < 0.01$, *** $p < 0.001$" },
        };
    }
};

// ═════════════════════════════════════════════════════════════════════════
// TESTS
// ═════════════════════════════════════════════════════════════════════════

test "Alignment toLatex" {
    try std.testing.expectEqual("l", Alignment.left.toLatex());
    try std.testing.expectEqual("c", Alignment.center.toLatex());
    try std.testing.expectEqual("r", Alignment.right.toLatex());
}

test "TableCell formatAsLatex basic" {
    const cell = TableCell{
        .content = "Test",
    };

    const latex = try cell.formatAsLatex(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "Test") != null);
}

test "TableCell formatAsLatex with bold" {
    const cell = TableCell{
        .content = "Bold Text",
        .bold = true,
    };

    const latex = try cell.formatAsLatex(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "\\textbf{") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "Bold Text") != null);
}

test "LaTeXTable simple formatAsLatex" {
    const header_row = TableRow{
        .cells = &.{ .{ .content = "Model" }, .{ .content = "Accuracy" } },
        .is_header = true,
    };

    const data_row = TableRow{
        .cells = &.{ .{ .content = "Ours" }, .{ .content = "95.0", .alignment = .right } },
    };

    const table = LaTeXTable{
        .caption = "Performance Comparison",
        .columns = &.{ .left, .right },
        .rows = &.{ header_row, data_row },
    };

    const latex = try table.formatAsLatex(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "\\begin{table}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\caption{Performance Comparison}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\begin{tabular}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\toprule") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "Ours") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "95.0") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\end{table}") != null);
}

test "LaTeXTable formatAsMarkdown" {
    const header_row = TableRow{
        .cells = &.{ .{ .content = "Model" }, .{ .content = "Accuracy" } },
        .is_header = true,
    };

    const data_row = TableRow{
        .cells = &.{ .{ .content = "Ours" }, .{ .content = "95.0" } },
    };

    const table = LaTeXTable{
        .caption = "Performance",
        .columns = &.{ .left, .right },
        .rows = &.{ header_row, data_row },
    };

    const md = try table.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "### Performance") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "| Model | Accuracy |") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "| Ours | 95.0 |") != null);
}
