//! Zenodo V16: DOI Manager — Automatic DOI Versioning
//!
//! DOI (Digital Object Identifier) management following:
//! - Zenodo DOI patterns (concept DOI, version DOI)
//! - DataCite DOI standards
//! - FAIR findability principles
//! - Versioning best practices for research artifacts

const std = @import("std");

/// DOI validation result
pub const DOIValidation = struct {
    is_valid: bool,
    error_message: ?[]const u8 = null,
};

/// DOI record with metadata
pub const DOIRecord = struct {
    /// Full DOI string (e.g., "10.5281/zenodo.19227879")
    doi: []const u8,
    /// Concept ID (numeric part before version)
    concept_id: u32,
    /// Version number (0 = concept DOI)
    version: u32,
    /// Resource type
    resource_type: []const u8,
    /// Creation date (ISO 8601)
    created_at: ?[]const u8 = null,
    /// Latest version flag
    is_latest: bool = false,
    /// Deprecated flag
    is_deprecated: bool = false,

    /// Parse full DOI string into components
    pub fn parse(doi: []const u8) !DOIRecord {
        // Expected format: "10.5281/zenodo.19227879" or "10.5281/zenodo.19227879.v2"
        const prefix = "10.5281/zenodo.";

        if (!std.mem.startsWith(u8, doi, prefix)) {
            return error.InvalidDOIPrefix;
        }

        const after_prefix = doi[prefix.len..];

        // Check for version suffix
        var version: u32 = 0;
        var number_str = after_prefix;
        const v_pos = std.mem.indexOf(u8, after_prefix, ".v");

        if (v_pos) |v_index| {
            // Has version suffix
            version = try std.fmt.parseInt(u32, after_prefix[v_index + 2 ..], 10);
            number_str = after_prefix[0..v_index];
        }

        const concept_id = try std.fmt.parseInt(u32, number_str, 10);

        return .{
            .doi = doi,
            .concept_id = concept_id,
            .version = version,
            .resource_type = "dataset",
        };
    }

    /// Get URL to resolve DOI
    pub fn resolveURL(self: *const DOIRecord, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "https://doi.org/{s}", .{self.doi});
    }

    /// Get Zenodo record URL
    pub fn zenodoURL(self: *const DOIRecord, allocator: std.mem.Allocator) ![]u8 {
        if (self.version == 0) {
            return std.fmt.allocPrint(allocator, "https://zenodo.org/record/{d}", .{self.concept_id});
        } else {
            return std.fmt.allocPrint(allocator, "https://zenodo.org/record/{d}?version={d}", .{.{ self.concept_id, self.version }});
        }
    }
};

/// DOI Manager for automatic versioning
pub const DOIManager = struct {
    /// Zenodo API base URL
    zenodo_api_url: []const u8 = "https://zenodo.org/api/",
    /// Base resolver URL
    resolver_url: []const u8 = "https://doi.org/",
    /// DOI prefix
    doi_prefix: []const u8 = "10.5281/zenodo.",

    /// Storage for DOI records
    records: std.StringHashMap(DOIRecord),

    /// Next available concept ID
    next_concept_id: u32 = 19227880, // Start after existing bundles

    pub fn init(allocator: std.mem.Allocator) DOIManager {
        return .{
            .records = std.StringHashMap(DOIRecord).init(allocator),
        };
    }

    pub fn deinit(self: *DOIManager, allocator: std.mem.Allocator) void {
        var iter = self.records.iterator();
        while (iter.next()) |entry| {
            allocator.free(entry.value_ptr.doi);
            if (entry.value_ptr.created_at) |date| {
                allocator.free(date);
            }
        }
        self.records.deinit();
    }

    /// Validate DOI format
    pub fn validateDOI(self: *const DOIManager, doi: []const u8) DOIValidation {
        // Check prefix
        if (!std.mem.startsWith(u8, doi, self.doi_prefix)) {
            return .{ .is_valid = false, .error_message = "Invalid DOI prefix (must be 10.5281/zenodo.)" };
        }

        // Check for numeric suffix
        const after_prefix = doi[self.doi_prefix.len..];
        var number_str = after_prefix;

        const v_pos = std.mem.indexOf(u8, after_prefix, ".v");
        if (v_pos) |v_index| {
            number_str = after_prefix[0..v_index];

            // Validate version number
            const version_str = after_prefix[v_index + 2 ..];
            if (version_str.len == 0) {
                return .{ .is_valid = false, .error_message = "Version number missing after .v" };
            }

            for (version_str) |c| {
                if (c < '0' or c > '9') {
                    return .{ .is_valid = false, .error_message = "Invalid version number (must be numeric)" };
                }
            }
        }

        // Validate concept ID is numeric
        if (number_str.len == 0) {
            return .{ .is_valid = false, .error_message = "Concept ID missing" };
        }

        for (number_str) |c| {
            if (c < '0' or c > '9') {
                return .{ .is_valid = false, .error_message = "Invalid concept ID (must be numeric)" };
            }
        }

        return .{ .is_valid = true };
    }

    /// Generate concept DOI (no version suffix)
    pub fn generateConceptDOI(self: *DOIManager, allocator: std.mem.Allocator) ![]u8 {
        const doi = try std.fmt.allocPrint(allocator, "{s}{d}", .{ self.doi_prefix, self.next_concept_id });
        return try self.storeDOIClone(allocator, doi, self.next_concept_id, 0);
    }

    /// Generate version DOI with version number
    pub fn generateVersionDOI(self: *DOIManager, allocator: std.mem.Allocator, concept_id: u32, version: u32) ![]u8 {
        const doi = try std.fmt.allocPrint(allocator, "{s}{d}.v{d}", .{ self.doi_prefix, concept_id, version });
        return try self.storeDOIClone(allocator, doi, concept_id, version);
    }

    /// Store DOI record with memory allocation
    fn storeDOIClone(self: *DOIManager, allocator: std.mem.Allocator, doi: []const u8, concept_id: u32, version: u32) ![]u8 {
        // Extract version from doi
        var ver: u32 = version;
        const v_pos = std.mem.indexOf(u8, doi, ".v");
        if (v_pos) |_| {
            const version_str = doi[v_pos.? + 2 ..];
            ver = try std.fmt.parseInt(u32, version_str, 10);
        }

        // Clone DOI for storage
        const doi_clone = try allocator.dupe(u8, doi);

        try self.records.put(doi_clone, .{
            .doi = doi_clone,
            .concept_id = concept_id,
            .version = ver,
            .resource_type = "dataset",
            .created_at = null,
            .is_latest = true,
            .is_deprecated = false,
        });

        return doi_clone;
    }

    /// Get DOI record by full DOI string
    pub fn getRecord(self: *const DOIManager, doi: []const u8) ?*const DOIRecord {
        return self.records.get(doi);
    }

    /// Get all versions of a concept
    pub fn getVersions(self: *const DOIManager, concept_id: u32, allocator: std.mem.Allocator) ![]const DOIRecord {
        var results = try std.ArrayList(*const DOIRecord).initCapacity(allocator, 4);
        defer results.deinit(allocator);

        var iter = self.records.iterator();
        while (iter.next()) |entry| {
            if (entry.value_ptr.concept_id == concept_id) {
                try results.append(allocator, entry.value_ptr);
            }
        }

        return try results.toOwnedSlice(allocator);
    }

    /// Get latest version DOI for a concept
    pub fn getLatestVersion(self: *const DOIManager, concept_id: u32) ?*const DOIRecord {
        var latest: ?*const DOIRecord = null;

        var iter = self.records.iterator();
        while (iter.next()) |entry| {
            if (entry.value_ptr.concept_id == concept_id) {
                if (latest == null or entry.value_ptr.version > latest.?.version) {
                    latest = entry.value_ptr;
                }
            }
        }

        return latest;
    }

    /// Create citation string in BibTeX format
    pub fn formatBibTeX(self: *const DOIManager, allocator: std.mem.Allocator, doi: []const u8, metadata: struct {
        authors: []const u8,
        title: []const u8,
        year: []const u8,
        version: []const u8,
    }) ![]u8 {
        const entry = try self.records.get(doi) orelse return error.DOINotFound;
        const resolved = try entry.resolveURL(allocator);
        defer allocator.free(resolved);

        var result = try std.ArrayList(u8).initCapacity(allocator, 256);
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "@misc{");
        try result.appendSlice(allocator, try std.fmt.allocPrint(allocator, "{s}", .{std.crypto.hash.slice(u8, doi, 0, 8)}));
        try result.appendSlice(allocator, ",\n  author = {");
        try result.appendSlice(allocator, metadata.authors);
        try result.appendSlice(allocator, "},\n");
        try result.appendSlice(allocator, "  title = {");
        try result.appendSlice(allocator, metadata.title);
        try result.appendSlice(allocator, "},\n");
        try result.appendSlice(allocator, "  year = {");
        try result.appendSlice(allocator, metadata.year);
        try result.appendSlice(allocator, "},\n");
        if (metadata.version.len > 0) {
            try result.appendSlice(allocator, "  version = {");
            try result.appendSlice(allocator, metadata.version);
            try result.appendSlice(allocator, "},\n");
        }
        try result.appendSlice(allocator, "  doi = {");
        try result.appendSlice(allocator, doi);
        try result.appendSlice(allocator, "},\n");
        try result.appendSlice(allocator, "  url = {");
        try result.appendSlice(allocator, resolved);
        try result.appendSlice(allocator, "}\n");
        try result.appendSlice(allocator, "}\n");

        return result.toOwnedSlice(allocator);
    }

    /// Increment concept ID for next DOI
    pub fn incrementConceptId(self: *DOIManager) void {
        self.next_concept_id += 1;
    }
};

// ═════════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════

test "DOIRecord parse" {
    const record = try DOIRecord.parse("10.5281/zenodo.19227879");
    try std.testing.expectEqual(@as(u32, 19227879), record.concept_id);
    try std.testing.expectEqual(@as(u32, 0), record.version);
    try std.testing.expectEqual("10.5281/zenodo.19227879", record.doi);
}

test "DOIRecord parse with version" {
    const record = try DOIRecord.parse("10.5281/zenodo.19227879.v3");
    try std.testing.expectEqual(@as(u32, 19227879), record.concept_id);
    try std.testing.expectEqual(@as(u32, 3), record.version);
}

test "DOIRecord parse invalid" {
    const result = DOIRecord.parse("invalid.doi");
    try std.testing.expectError(error.InvalidDOIPrefix, result);
}

test "DOIRecord resolveURL" {
    const record = DOIRecord{
        .doi = "10.5281/zenodo.19227879",
        .concept_id = 19227879,
        .version = 0,
        .resource_type = "dataset",
    };

    const url = try record.resolveURL(std.testing.allocator);
    defer std.testing.allocator.free(url);

    try std.testing.expect(std.mem.indexOf(u8, url, "https://doi.org/") != null);
    try std.testing.expect(std.mem.indexOf(u8, url, "10.5281/zenodo.19227879") != null);
}

test "DOIManager validateDOI valid" {
    var manager = DOIManager.init(std.testing.allocator);
    defer manager.deinit(std.testing.allocator);

    const result = manager.validateDOI("10.5281/zenodo.19227879");
    try std.testing.expect(result.is_valid);
}

test "DOIManager validateDOI invalid prefix" {
    var manager = DOIManager.init(std.testing.allocator);
    defer manager.deinit(std.testing.allocator);

    const result = manager.validateDOI("10.1234/zenodo.19227879");
    try std.testing.expect(!result.is_valid);
}

test "DOIManager generateConceptDOI" {
    var manager = DOIManager.init(std.testing.allocator);
    defer manager.deinit(std.testing.allocator);

    const doi = try manager.generateConceptDOI(std.testing.allocator);
    defer std.testing.allocator.free(doi);

    try std.testing.expect(std.mem.startsWith(u8, doi, "10.5281/zenodo."));
    try std.testing.expectEqual(@as(u32, 19227880), manager.next_concept_id);
}

test "DOIManager generateVersionDOI" {
    var manager = DOIManager.init(std.testing.allocator);
    defer manager.deinit(std.testing.allocator);

    const doi = try manager.generateVersionDOI(std.testing.allocator, 19227879, 2);
    defer std.testing.allocator.free(doi);

    try std.testing.expect(std.mem.indexOf(u8, doi, ".v2") != null);
    try std.testing.expect(std.mem.startsWith(u8, doi, "10.5281/zenodo.19227879"));
}
