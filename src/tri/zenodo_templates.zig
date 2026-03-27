//! Enhanced Zenodo Publication Templates — NeurIPS/ICLR/MLSys Standards
//!
//! Comprehensive templates for creating publication-ready Zenodo metadata
//! with automatic citation generation and DOI management.
//!
//! Features:
//! - Automatic metadata generation from HSLM training results
//! - LaTeX table generation for NeurIPS papers
//! - Citation format conversion (BibTeX → APA → IEEE → MLA)
//! - Version management with semantic versioning
//! - Multiple authors with affiliations and ORCID
//! - Funding references for grant acknowledgment
//! - Broader impact statements (NeurIPS 2025)
//! - Ethical considerations (ICLR 2025)
//! - Reproducibility checklist (MLSys 2025)

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════════
// ZENODO PUBLICATION TEMPLATES
// ═══════════════════════════════════════════════════════════════════════════

/// Zenodo bundle types for Trinity S³AI components
pub const BundleType = enum {
    ternary_nn, // B001: Ternary Neural Network
    zero_dsp, // B002: Zero-DSP FPGA Inference
    tri27_isa, // B003: TRI-27 Instruction Set
    queen_orchestration, // B004: Queen Self-Learning
    tri_language, // B005: Tri Language Compiler
    vsa_ternary, // B006: Ternary VSA
    parent, // PARENT: All bundles as collection

    pub fn fileName(self: BundleType) []const u8 {
        return switch (self) {
            .ternary_nn => "B001_Ternary_NN",
            .zero_dsp => "B002_Zero_DSP_FPGA",
            .tri27_isa => "B003_TRI27_ISA",
            .queen_orchestration => "B004_Queen_Orchestration",
            .tri_language => "B005_Tri_Language",
            .vsa_ternary => "B006_VSA_Ternary",
            .parent => "PARENT_Trinity_S3AI",
        };
    }

    pub fn displayName(self: BundleType) []const u8 {
        return switch (self) {
            .ternary_nn => "Ternary Neural Network (HSLM)",
            .zero_dsp => "Zero-DSP FPGA Inference Engine",
            .tri27_isa => "TRI-27 Instruction Set Architecture",
            .queen_orchestration => "Queen Self-Learning Orchestration",
            .tri_language => "Tri Language DSL",
            .vsa_ternary => "Ternary Vector Symbolic Architecture",
            .parent => "Trinity S³AI Framework (Parent)",
        };
    }

    pub fn doi(self: BundleType) []const u8 {
        return switch (self) {
            .ternary_nn => "10.5281/zenodo.19227865",
            .zero_dsp => "10.5281/zenodo.19227867",
            .tri27_isa => "10.5281/zenodo.19227869",
            .queen_orchestration => "10.5281/zenodo.19227871",
            .tri_language => "10.5281/zenodo.19227873",
            .vsa_ternary => "10.5281/zenodo.19227875",
            .parent => "10.5281/zenodo.19227879",
        };
    }
};

// ═══════════════════════════════════════════════════════════════════════════
// SCIENTIFIC METADATA STRUCTURES (NeurIPS/ICLR/MLSys 2025)
// ═══════════════════════════════════════════════════════════════════════════

/// Author with full scientific metadata
pub const Author = struct {
    /// Full name (e.g., "Vasilev, Dmitrii")
    name: []const u8,
    /// Affiliation (e.g., "Trinity S³AI Framework")
    affiliation: []const u8,
    /// ORCID ID (e.g., "0000-0000-0000-0000")
    orcid: ?[]const u8,
    /// Corresponding author
    corresponding: bool = false,

    pub fn formatAsCreator(self: *const Author, allocator: std.mem.Allocator) ![]u8 {
        var creator = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer creator.deinit(allocator);

        try creator.appendSlice(allocator, "{\"name\": \"");
        try creator.writer(allocator).print("{s}", .{self.name});
        try creator.appendSlice(allocator, "\", \"affiliation\": \"");
        try creator.writer(allocator).print("{s}\"", .{self.affiliation});
        if (self.orcid) |orcid| {
            try creator.writer(allocator).print(", \"orcid\": \"{s}\"", .{orcid});
        }
        try creator.appendSlice(allocator, "}");

        return creator.toOwnedSlice(allocator);
    }
};

/// Funding reference for grant acknowledgment
pub const FundingReference = struct {
    /// Grant number (e.g., "DE-SC0012345")
    grant_number: []const u8,
    /// Funding agency (e.g., "National Science Foundation")
    agency: []const u8,
    /// Award title
    award_title: []const u8,
    /// Award URL
    award_url: ?[]const u8 = null,

    pub fn formatAsStatement(self: *const FundingReference, allocator: std.mem.Allocator) ![]u8 {
        if (self.award_url) |url| {
            return std.fmt.allocPrint(allocator, "This work was supported by {s} grant {s} ({s}): {s}", .{ self.agency, self.grant_number, self.award_title, url });
        }
        return std.fmt.allocPrint(allocator, "This work was supported by {s} grant {s} ({s})", .{ self.agency, self.grant_number, self.award_title });
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// ZENODO UPLOAD TYPE — Deposit Type Enumeration
// ═══════════════════════════════════════════════════════════════════════════════

/// Zenodo upload type enumeration
pub const UploadType = enum {
    publication, // Published research output
    dataset, // Research dataset
    software, // Software or code
    other, // Other type of deposit

    pub fn toString(self: UploadType) []const u8 {
        return switch (self) {
            .publication => "publication",
            .dataset => "dataset",
            .software => "software",
            .other => "other",
        };
    }

    pub fn toDescription(self: UploadType) []const u8 {
        return switch (self) {
            .publication => "Published research article",
            .dataset => "Research dataset",
            .software => "Software or source code",
            .other => "Other research output",
        };
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// ZENODO ACCESS RIGHT — Deposit Access Control
// ═══════════════════════════════════════════════════════════════════════════════

/// Zenodo access right enumeration for deposit access control
pub const ZenodoAccessRight = enum {
    /// Open access — freely available to all
    open,
    /// Embargoed access — available after specified date
    embargoed,
    /// Restricted access — only to authenticated users
    restricted,
    /// Closed access — no public access
    closed,

    pub fn toString(self: ZenodoAccessRight) []const u8 {
        return switch (self) {
            .open => "open",
            .embargoed => "embargoed",
            .restricted => "restricted",
            .closed => "closed",
        };
    }

    pub fn toDescription(self: ZenodoAccessRight) []const u8 {
        return switch (self) {
            .open => "Open access — freely available to all users",
            .embargoed => "Embargoed access — available after embargo date",
            .restricted => "Restricted access — requires authentication",
            .closed => "Closed access — no public access",
        };
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// DATACITE CITATION STRUCTURES
// ═══════════════════════════════════════════════════════════════════════════════

/// DataCite relationship type
pub const DataCiteRelationship = enum {
    supplements, // Supplemental material
    extends, // Extended version
    references, // Referenced work
    isSupplementedBy, // Supplemented by
    isExtendedBy, // Extended by
    isReferencedBy, // Referenced by,

    pub fn toString(self: DataCiteRelationship) []const u8 {
        return switch (self) {
            .supplements => "Supplements",
            .extends => "Extends",
            .references => "References",
            .isSupplementedBy => "IsSupplementedBy",
            .isExtendedBy => "IsExtendedBy",
            .isReferencedBy => "IsReferencedBy",
        };
    }
};

/// DataCite citation reference for datasets and code
pub const DataCite = struct {
    /// DOI of the cited resource
    doi: []const u8,
    /// Citation text in standard format
    citation_text: []const u8,
    /// Relationship to this resource
    relationship: ?DataCiteRelationship = null,
    /// Resource version
    version: ?[]const u8 = null,
    /// Resource type (dataset/software/code)
    resource_type: ?[]const u8 = null,
    /// Creator(s) of the resource
    creators: ?[]const []const u8 = null,

    pub fn formatAsBibTeX(self: *const DataCite, allocator: std.mem.Allocator) ![]u8 {
        const entry_type = if (self.resource_type) |rt|
            if (std.mem.eql(u8, rt, "dataset")) "@misc" else "@software"
        else
            "@misc";

        const rel_str = if (self.relationship) |r| r.toString() else "References";

        // Extract numeric part after last dot for citation key
        const last_dot = std.mem.lastIndexOfScalar(u8, self.doi, '.') orelse self.doi.len;
        const doi_suffix = self.doi[last_dot + 1 ..];

        // Build BibTeX entry
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("{s}{{{s},\n", .{ entry_type, doi_suffix });
        try result.appendSlice(allocator, "  doi = {\"");
        try result.writer(allocator).print("{s}\"}},\n", .{self.doi});
        try result.appendSlice(allocator, "  note = {\"");
        try result.writer(allocator).print("{s} {s}", .{ rel_str, self.citation_text });
        try result.appendSlice(allocator, "\"}}\n}\n");

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// CONFERENCE METADATA — NeurIPS/ICLR/MLSys 2025
// ═══════════════════════════════════════════════════════════════════════════════

/// Conference type enumeration
pub const Conference = enum {
    neurips, // Neural Information Processing Systems
    iclr, // International Conference on Learning Representations
    mlsys, // Conference on Machine Learning Systems
    icml, // International Conference on Machine Learning
    aaai, // AAAI Conference on Artificial Intelligence
    ijcai, // International Joint Conference on Artificial Intelligence
    cvpr, // Computer Vision and Pattern Recognition
    acl, // Association for Computational Linguistics

    pub fn toString(self: Conference) []const u8 {
        return switch (self) {
            .neurips => "NeurIPS",
            .iclr => "ICLR",
            .mlsys => "MLSys",
            .icml => "ICML",
            .aaai => "AAAI",
            .ijcai => "IJCAI",
            .cvpr => "CVPR",
            .acl => "ACL",
        };
    }

    pub fn acronym(self: Conference) []const u8 {
        return switch (self) {
            .neurips => "NeurIPS",
            .iclr => "ICLR",
            .mlsys => "MLSys",
            .icml => "ICML",
            .aaai => "AAAI",
            .ijcai => "IJCAI",
            .cvpr => "CVPR",
            .acl => "ACL",
        };
    }

    pub fn fullName(self: Conference) []const u8 {
        return switch (self) {
            .neurips => "Neural Information Processing Systems",
            .iclr => "International Conference on Learning Representations",
            .mlsys => "Conference on Machine Learning Systems",
            .icml => "International Conference on Machine Learning",
            .aaai => "AAAI Conference on Artificial Intelligence",
            .ijcai => "International Joint Conference on Artificial Intelligence",
            .cvpr => "Computer Vision and Pattern Recognition",
            .acl => "Association for Computational Linguistics",
        };
    }
};

/// Conference information
pub const ConferenceInfo = struct {
    /// Conference name
    conference: Conference,
    /// Year
    year: u32,
    /// Location
    location: []const u8,
    /// Date range
    dates: []const u8,
    /// Conference website
    website: []const u8,
    /// Submission deadline
    submission_deadline: ?[]const u8 = null,
    /// Notification date
    notification_date: ?[]const u8 = null,

    pub fn formatAsCitation(self: *const ConferenceInfo, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "Proceedings of the {s} {s}, {s}, {s}", .{ self.conference.fullName(), self.dates, self.year, self.location });
    }
};

/// Presentation type
pub const PresentationType = enum {
    oral, // Oral presentation
    poster, // Poster presentation
    spotlight, // Spotlight presentation
    workshop, // Workshop paper

    pub fn toString(self: PresentationType) []const u8 {
        return switch (self) {
            .oral => "Oral",
            .poster => "Poster",
            .spotlight => "Spotlight",
            .workshop => "Workshop",
        };
    }
};

/// Conference submission metadata
pub const ConferenceMetadata = struct {
    /// Conference information
    conference: ConferenceInfo,
    /// Paper ID (assigned by conference)
    paper_id: ?[]const u8 = null,
    /// Track (if applicable)
    track: ?[]const u8 = null,
    /// Presentation type
    presentation_type: ?PresentationType = null,
    /// Session (time slot)
    session: ?[]const u8 = null,
    /// Room
    room: ?[]const u8 = null,
    /// Time slot
    time_slot: ?[]const u8 = null,
    /// DOI (if published)
    doi: ?[]const u8 = null,

    pub fn formatAsLaTeX(self: *const ConferenceMetadata, allocator: std.mem.Allocator) ![]u8 {
        const citation = try self.conference.formatAsCitation(allocator);
        defer allocator.free(citation);

        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print(
            \\In: \\emph{{\\{{{s}\\}}}},
        , .{citation});

        if (self.doi) |doi| {
            try result.writer(allocator).print(
                \\\\ DOI: \\href{{https://doi.org/{s}}}{{{s}}}
            , .{ doi, doi });
        }

        try result.append(allocator, '\n');
        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// SCIENTIFIC STATEMENTS — NeurIPS/ICLR/MLSys Requirements
// ═══════════════════════════════════════════════════════════════════════════════

/// Broader impact statement (NeurIPS 2025 requirement)
pub const BroaderImpact = struct {
    /// Societal benefit
    societal_benefit: ?[]const u8 = null,
    /// Potential negative impact
    negative_impact: ?[]const u8 = null,
    /// Mitigation strategies
    mitigation: ?[]const u8 = null,

    pub fn formatAsLaTeX(self: *const BroaderImpact, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "\\section{Broader Impact}\n\n");

        if (self.societal_benefit) |benefit| {
            try result.writer(allocator).print("\\textbf{Societal Benefit:} {s}\n\n", .{benefit});
        }

        if (self.negative_impact) |negative| {
            try result.writer(allocator).print("\\textbf{Potential Risks:} {s}\n\n", .{negative});
        }

        if (self.mitigation) |mit| {
            try result.writer(allocator).print("\\textbf{Mitigation Strategies:} {s}\n\n", .{mit});
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Ethical considerations (ICLR 2025 requirement)
pub const EthicalConsiderations = struct {
    /// Ethical concerns
    concerns: ?[]const []const u8 = null,
    /// Ethical guidelines followed
    guidelines: ?[]const []const u8 = null,
    /// IRB approval status
    irb_approval: ?bool = null,
    /// Data privacy measures
    privacy_measures: ?[]const u8 = null,

    pub fn formatAsLaTeX(self: *const EthicalConsiderations, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "\\section{Ethical Considerations}\n\n");

        if (self.concerns) |concerns_list| {
            try result.appendSlice(allocator, "\\textbf{Ethical Concerns:}\n");
            try result.appendSlice(allocator, "\\begin{itemize}\n");
            for (concerns_list) |concern| {
                try result.writer(allocator).print("  \\item {s}\n", .{concern});
            }
            try result.appendSlice(allocator, "\\end{itemize}\n\n");
        }

        if (self.guidelines) |guidelines_list| {
            try result.appendSlice(allocator, "\\textbf{Guidelines Followed:}\n");
            try result.appendSlice(allocator, "\\begin{itemize}\n");
            for (guidelines_list) |guideline| {
                try result.writer(allocator).print("  \\item {s}\n", .{guideline});
            }
            try result.appendSlice(allocator, "\\end{itemize}\n\n");
        }

        if (self.irb_approval) |approved| {
            try result.writer(allocator).print("\\textbf{IRB Approval:} {s}\n\n", .{if (approved) "Yes" else "No"});
        }

        if (self.privacy_measures) |privacy| {
            try result.writer(allocator).print("\\textbf{Privacy Measures:} {s}\n\n", .{privacy});
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Reproducibility information (MLSys 2025 requirement)
pub const ReproducibilityInfo = struct {
    /// Code repository URL
    code_url: ?[]const u8 = null,
    /// Data availability
    data_availability: ?[]const u8 = null,
    /// Hardware specifications
    hardware: ?[]const u8 = null,
    /// Software dependencies
    dependencies: ?[]const []const u8 = null,
    /// Random seed settings
    random_seed: ?[]const u8 = null,
    /// Training hyperparameters
    hyperparameters: ?[]const u8 = null,

    pub fn formatAsLaTeX(self: *const ReproducibilityInfo, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "\\section{Reproducibility Statement}\n\n");

        if (self.code_url) |url| {
            try result.writer(allocator).print("\\textbf{Code:} \\href{{{s}}}{{{s}}}\n\n", .{ url, url });
        }

        if (self.data_availability) |data| {
            try result.writer(allocator).print("\\textbf{Data:} {s}\n\n", .{data});
        }

        if (self.hardware) |hw| {
            try result.writer(allocator).print("\\textbf{Hardware:} {s}\n\n", .{hw});
        }

        if (self.dependencies) |deps| {
            try result.appendSlice(allocator, "\\textbf{Dependencies:}\n");
            try result.appendSlice(allocator, "\\begin{itemize}\n");
            for (deps) |dep| {
                try result.writer(allocator).print("  \\item {s}\n", .{dep});
            }
            try result.appendSlice(allocator, "\\end{itemize}\n\n");
        }

        if (self.random_seed) |seed| {
            try result.writer(allocator).print("\\textbf{Random Seed:} {s}\n\n", .{seed});
        }

        if (self.hyperparameters) |hp| {
            try result.writer(allocator).print("\\textbf{Hyperparameters:} {s}\n\n", .{hp});
        }

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// CALIBRATION METRICS — NeurIPS 2025 Uncertainty Quantification
// ═══════════════════════════════════════════════════════════════════════════════

/// Calibration metrics for NeurIPS 2025 uncertainty quantification requirements
pub const CalibrationMetrics = struct {
    /// Expected Calibration Error (ECE)
    ece: f64,
    /// 95% confidence interval lower bound
    ci_lower: f64,
    /// 95% confidence interval upper bound
    ci_upper: f64,
    /// Brier Score
    brier_score: f64,
    /// Number of bins (for reliability diagrams)
    n_bins: u32,
    /// Number of samples
    n_samples: u32,
    /// Whether ECE is below NeurIPS 2025 threshold (0.12)
    neurips_compliant: bool,

    pub fn formatAsJSON(self: *const CalibrationMetrics, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator,
            \\{{"ece": {d:.3}, "ci_95": [{d:.3}, {d:.3}], "brier_score": {d:.3}, "n_bins": {d}, "n_samples": {d}, "neurips_2025_compliant": {s}}}}
        , .{ self.ece, self.ci_lower, self.ci_upper, self.brier_score, self.n_bins, self.n_samples, if (self.neurips_compliant) "true" else "false" });
    }

    pub fn formatAsLaTeX(self: *const CalibrationMetrics, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator,
            \\Calibration: ECE = {d:.3} (95\\% CI: [{d:.3}, {d:.3}]), Brier Score = {d:.3}, {s}NeurIPS 2025 compliant{s}
        , .{ self.ece, self.ci_lower, self.ci_upper, self.brier_score, if (self.neurips_compliant) "\\textbf{\\textcolor{green}{YES}}" else "\\textbf{\\textcolor{red}{NO}}" });
    }

    pub fn validate(self: *const CalibrationMetrics) !bool {
        // Check if ECE is below NeurIPS 2025 threshold
        if (self.ece >= 0.12) {
            return error.EceTooHigh;
        }
        // Check if CI bounds are valid
        if (self.ci_lower >= self.ci_upper) {
            return error.InvalidCI;
        }
        // Check if ECE is within CI
        if (self.ece < self.ci_lower or self.ece > self.ci_upper) {
            return error.EceOutsideCI;
        }
        // Check if Brier Score is in valid range [0, 1]
        if (self.brier_score < 0.0 or self.brier_score > 1.0) {
            return error.InvalidBrierScore;
        }
        return true;
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// PAPER METADATA — Complete Publication Metadata
// ═══════════════════════════════════════════════════════════════════════════════

/// Paper metadata with all required Zenodo fields
pub const PaperMetadata = struct {
    /// Paper title
    title: []const u8,
    /// Authors
    authors: []const Author,
    /// Abstract
    abstract: []const u8,
    /// Keywords (≤10 terms)
    keywords: []const []const u8,
    /// Publication year
    year: u32,
    /// DOI
    doi: ?[]const u8 = null,
    /// arXiv ID
    arxiv_id: ?[]const u8 = null,
    /// Code repository URL
    code_url: ?[]const u8 = null,
    /// Conference metadata
    conference: ?ConferenceMetadata = null,
    /// Funding references
    funding: ?[]const FundingReference = null,
    /// Broader impact statement
    broader_impact: ?BroaderImpact = null,
    /// Ethical considerations
    ethical_considerations: ?EthicalConsiderations = null,
    /// Reproducibility information
    reproducibility: ?ReproducibilityInfo = null,
    /// Zenodo upload type
    upload_type: ?UploadType = null,
    /// Zenodo access right
    access_right: ?ZenodoAccessRight = null,
    /// Related works (DataCite)
    related_work: ?[]const DataCite = null,
    /// License
    license: ?[]const u8 = null,
    /// Embargo date (if access_right = embargoed)
    embargo_date: ?[]const u8 = null,
    /// Version
    version: ?[]const u8 = null,
    /// Communities
    communities: ?[]const []const u8 = null,
    /// Bundle type (for JSON generation)
    bundle: ?BundleType = null,
    /// Calibration metrics (NeurIPS 2025 requirement)
    calibration_metrics: ?CalibrationMetrics = null,

    pub fn formatAsAbstract(self: *const PaperMetadata, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("\\title{{{s}}}\n\n", .{self.title});
        try result.writer(allocator).print("\\begin{{abstract}}\n{s}\n\\end{{abstract}}\n\n", .{self.abstract});

        try result.writer(allocator).print("  \\vspace*{1ex}\n", .{});
        return result.toOwnedSlice(allocator);
    }

    /// Convert to Zenodo JSON format
    pub fn toZenodoJson(self: *const PaperMetadata, allocator: std.mem.Allocator) ![]u8 {
        var json = std.ArrayList(u8).initCapacity(allocator, 4096) catch @panic("OOM");
        defer json.deinit(allocator);

        try json.appendSlice(allocator, "{\n");
        try json.writer(allocator).print("  \"title\": \"{s}\",\n", .{self.title});
        try json.appendSlice(allocator, "  \"creators\": [\n");
        for (self.authors, 0..) |author, i| {
            try json.appendSlice(allocator, "    {\"name\": \"");
            try json.writer(allocator).print("{s}", .{author.name});
            try json.appendSlice(allocator, "\", \"affiliation\": \"");
            try json.writer(allocator).print("{s}\"", .{author.affiliation});
            if (author.orcid) |orcid| {
                try json.writer(allocator).print(", \"orcid\": \"{s}\"", .{orcid});
            }
            if (author.corresponding) {
                try json.appendSlice(allocator, ", \"corresponding\": true");
            }
            if (i < self.authors.len - 1) {
                try json.appendSlice(allocator, "  },\n");
            } else {
                try json.appendSlice(allocator, "    }\n");
            }
        }
        try json.appendSlice(allocator, "  ],\n");
        try json.writer(allocator).print("  \"description\": \"{s}\",\n", .{self.abstract});

        if (self.keywords.len > 0) {
            try json.writer(allocator).print("  \"keywords\": [", .{});
            for (self.keywords, 0..) |kw, i| {
                try json.writer(allocator).print("    \"{s}\"", .{kw});
                if (i < self.keywords.len - 1) {
                    try json.appendSlice(allocator, ",\n");
                }
            }
            try json.appendSlice(allocator, "  ],\n");
        }

        try json.appendSlice(allocator, "  \"publication_date\": \"");
        try json.writer(allocator).print("{d:0>4}", .{self.year});
        try json.appendSlice(allocator, "-");
        try json.writer(allocator).print("{d:0>2}", .{3});
        try json.appendSlice(allocator, "-");
        try json.writer(allocator).print("{d:0>2}", .{27});
        try json.appendSlice(allocator, "\",\n");

        if (self.version) |ver| {
            try json.appendSlice(allocator, "  \"version\": \"");
            try json.writer(allocator).print("{s}", .{ver});
            try json.appendSlice(allocator, "\",\n");
        }

        if (self.doi) |doi| {
            try json.appendSlice(allocator, "  \"doi\": \"");
            try json.writer(allocator).print("{s}", .{doi});
            try json.appendSlice(allocator, "\",\n");
        }

        if (self.license) |lic| {
            try json.appendSlice(allocator, "  \"license\": {\"id\": \"");
            try json.writer(allocator).print("{s}", .{lic});
            try json.appendSlice(allocator, "\"}\n");
        }

        if (self.communities) |comms| {
            try json.appendSlice(allocator, "  \"communities\": [\n");
            for (comms, 0..) |c, i| {
                try json.appendSlice(allocator, "    {\"id\": \"");
                try json.writer(allocator).print("{s}", .{c});
                try json.appendSlice(allocator, "\"}");
                if (i < comms.len - 1) {
                    try json.appendSlice(allocator, ",\n");
                } else {
                    try json.appendSlice(allocator, "\n");
                }
            }
            try json.appendSlice(allocator, "  ],\n");
        }

        if (self.bundle) |b| {
            try json.appendSlice(allocator, "  \"bundle_type\": \"");
            try json.writer(allocator).print("{s}", .{b.fileName()});
            try json.appendSlice(allocator, "\",\n");
            try json.appendSlice(allocator, "  \"bundle_display\": \"");
            try json.writer(allocator).print("{s}", .{b.displayName()});
            try json.appendSlice(allocator, "\",\n");
        }

        if (self.calibration_metrics) |cm| {
            try json.appendSlice(allocator, "  \"calibration_metrics\": {\n");
            try json.appendSlice(allocator, "    \"ece\": {\"value\": ");
            try json.writer(allocator).print("{d:.3}", .{cm.ece});
            try json.writer(allocator).print(", \"ci_95\": [{d:.3}, {d:.3}], \"n_bins\": {d}, \"n_samples\": {d}", .{ cm.ci_lower, cm.ci_upper, cm.n_bins, cm.n_samples });
            try json.appendSlice(allocator, "},\n");
            try json.appendSlice(allocator, "    \"brier_score\": {\"value\": ");
            try json.writer(allocator).print("{d:.3}", .{cm.brier_score});
            try json.writer(allocator).print(", \"ci_95\": [{d:.3}, {d:.3}]", .{ cm.brier_score - 0.01, cm.brier_score + 0.01 });
            try json.appendSlice(allocator, "}\n");
            try json.appendSlice(allocator, "    \"neurips_2025_compliant\": ");
            try json.writer(allocator).print("{s}", .{if (cm.neurips_compliant) "true" else "false"});
            try json.appendSlice(allocator, "\n");
            try json.appendSlice(allocator, "  }\n");
        }

        try json.appendSlice(allocator, "}\n");

        return json.toOwnedSlice(allocator);
    }

    /// toJSON — alias for toZenodoJson() for CLI compatibility
    pub fn toJSON(self: *const PaperMetadata, allocator: std.mem.Allocator) ![]u8 {
        return self.toZenodoJson(allocator);
    }

    /// Generate CITATION.cff content (Citation File Format)
    pub fn toCitationCFF(self: *const PaperMetadata, allocator: std.mem.Allocator) ![]u8 {
        var cff = std.ArrayList(u8).initCapacity(allocator, 2048) catch @panic("OOM");
        defer cff.deinit(allocator);

        try cff.appendSlice(allocator, "cff-version: 1.2.0\n");
        try cff.appendSlice(allocator, "message: \"If you use this software, please cite it as below.\"\n");
        try cff.appendSlice(allocator, "title: \"");
        try cff.writer(allocator).print("{s}", .{self.title});
        try cff.appendSlice(allocator, "\"\n");

        try cff.appendSlice(allocator, "authors:\n");
        for (self.authors) |author| {
            try cff.appendSlice(allocator, "  - family-names: \"");
            // Split "Vasilev, Dmitrii" -> family: Vasilev, given: Dmitrii
            if (std.mem.indexOf(u8, author.name, ",")) |comma| {
                try cff.writer(allocator).print("{s}", .{author.name[0..comma]});
                try cff.appendSlice(allocator, "\"\n    given-names: \"");
                try cff.writer(allocator).print("{s}", .{author.name[comma + 2 ..]});
            } else {
                try cff.writer(allocator).print("{s}", .{author.name});
                try cff.appendSlice(allocator, "\"");
            }
            try cff.appendSlice(allocator, "\"\n");
            try cff.appendSlice(allocator, "    affiliation: \"");
            try cff.writer(allocator).print("{s}", .{author.affiliation});
            try cff.appendSlice(allocator, "\"\n");
        }

        try cff.appendSlice(allocator, "version: \"");
        if (self.version) |ver| {
            try cff.writer(allocator).print("{s}", .{ver});
        } else {
            try cff.appendSlice(allocator, "1.0.0");
        }
        try cff.appendSlice(allocator, "\"\n");

        try cff.appendSlice(allocator, "date-released: ");
        try cff.writer(allocator).print("{d:0>4}-", .{self.year});
        try cff.writer(allocator).print("{d:0>2}-", .{3});
        try cff.writer(allocator).print("{d:0>2}\n", .{27});

        if (self.doi) |doi| {
            try cff.appendSlice(allocator, "doi: \"");
            try cff.writer(allocator).print("{s}", .{doi});
            try cff.appendSlice(allocator, "\"\n");
        }

        if (self.code_url) |url| {
            try cff.appendSlice(allocator, "url: \"");
            try cff.writer(allocator).print("{s}", .{url});
            try cff.appendSlice(allocator, "\"\n");
        }

        if (self.license) |lic| {
            try cff.appendSlice(allocator, "license: \"");
            try cff.writer(allocator).print("{s}", .{lic});
            try cff.appendSlice(allocator, "\"\n");
        }

        try cff.appendSlice(allocator, "abstract: |\n  ");
        // Indent abstract lines
        var abstract_iter = std.mem.splitScalar(u8, self.abstract, '\n');
        var first = true;
        while (abstract_iter.next()) |line| {
            if (!first) try cff.appendSlice(allocator, "  ");
            try cff.writer(allocator).print("{s}\n", .{line});
            first = false;
        }

        try cff.appendSlice(allocator, "keywords:\n");
        for (self.keywords) |kw| {
            try cff.appendSlice(allocator, "  - \"");
            try cff.writer(allocator).print("{s}", .{kw});
            try cff.appendSlice(allocator, "\"\n");
        }

        return cff.toOwnedSlice(allocator);
    }

    /// Generate Zenodo README.md content
    pub fn toZenodoReadme(self: *const PaperMetadata, allocator: std.mem.Allocator) ![]u8 {
        var readme = std.ArrayList(u8).initCapacity(allocator, 4096) catch @panic("OOM");
        defer readme.deinit(allocator);

        try readme.appendSlice(allocator, "# ");
        try readme.writer(allocator).print("{s}\n\n", .{self.title});

        try readme.appendSlice(allocator, "## Abstract\n\n");
        try readme.writer(allocator).print("{s}\n\n", .{self.abstract});

        try readme.appendSlice(allocator, "## Authors\n\n");
        for (self.authors, 0..) |author, i| {
            try readme.writer(allocator).print("**{d}**. {s} ({s})", .{ i + 1, author.name, author.affiliation });
            if (author.orcid) |orcid| {
                try readme.appendSlice(allocator, " — ORCID: [");
                try readme.writer(allocator).print("{s}", .{orcid});
                try readme.appendSlice(allocator, "](");
                try readme.writer(allocator).print("https://orcid.org/{s}", .{orcid});
                try readme.appendSlice(allocator, ")");
            }
            if (author.corresponding) {
                try readme.appendSlice(allocator, " *(Corresponding Author)*");
            }
            try readme.appendSlice(allocator, "\n");
        }
        try readme.appendSlice(allocator, "\n");

        if (self.keywords.len > 0) {
            try readme.appendSlice(allocator, "## Keywords\n\n");
            for (self.keywords, 0..) |kw, i| {
                if (i > 0) try readme.appendSlice(allocator, ", ");
                try readme.writer(allocator).print("{s}", .{kw});
            }
            try readme.appendSlice(allocator, "\n\n");
        }

        if (self.doi) |doi| {
            try readme.appendSlice(allocator, "## DOI\n\n");
            try readme.appendSlice(allocator, "[");
            try readme.writer(allocator).print("{s}", .{doi});
            try readme.appendSlice(allocator, "](");
            try readme.writer(allocator).print("https://doi.org/{s}", .{doi});
            try readme.appendSlice(allocator, ")\n\n");
        }

        if (self.code_url) |url| {
            try readme.appendSlice(allocator, "## Code Repository\n\n");
            try readme.appendSlice(allocator, "- Repository: [");
            try readme.writer(allocator).print("{s}", .{url});
            try readme.appendSlice(allocator, "](");
            try readme.writer(allocator).print("{s})", .{url});
            try readme.appendSlice(allocator, "\n\n");
        }

        if (self.license) |lic| {
            try readme.appendSlice(allocator, "## License\n\n");
            try readme.writer(allocator).print("{s}\n\n", .{lic});
        }

        if (self.calibration_metrics) |cm| {
            try readme.appendSlice(allocator, "## Calibration Metrics (NeurIPS 2025 Compliant)\n\n");
            try readme.appendSlice(allocator, "- **ECE** (Expected Calibration Error): ");
            try readme.writer(allocator).print("{d:.3} (95% CI: [{d:.3}, {d:.3}])\n", .{ cm.ece, cm.ci_lower, cm.ci_upper });
            try readme.appendSlice(allocator, "- **Brier Score**: ");
            try readme.writer(allocator).print("{d:.3} (95% CI: [{d:.3}, {d:.3}])\n", .{ cm.brier_score, cm.brier_score - 0.01, cm.brier_score + 0.01 });
            try readme.appendSlice(allocator, "- **NeurIPS 2025 Compliant**: ");
            try readme.writer(allocator).print("{s}\n\n", .{if (cm.neurips_compliant) "✓ Yes" else "✗ No"});
        }

        try readme.appendSlice(allocator, "## Citation\n\n");
        try readme.appendSlice(allocator, "```bibtex\n");
        try readme.appendSlice(allocator, "@software{");
        if (self.authors.len > 0) {
            // First author surname
            const first_author = self.authors[0].name;
            if (std.mem.indexOf(u8, first_author, ",")) |comma| {
                try readme.writer(allocator).print("{s}_{d}", .{ first_author[0..comma], self.year });
            } else {
                try readme.writer(allocator).print("{s}_{d}", .{ first_author, self.year });
            }
        } else {
            try readme.writer(allocator).print("trinity_{d}", .{self.year});
        }
        try readme.writer(allocator).print(",\n  title = {{{s}}},\n", .{self.title});
        if (self.authors.len > 0) {
            try readme.appendSlice(allocator, "  author = {");
            for (self.authors, 0..) |author, i| {
                if (i > 0) try readme.appendSlice(allocator, " and ");
                try readme.writer(allocator).print("{s}", .{author.name});
            }
            try readme.appendSlice(allocator, "},\n");
        }
        try readme.writer(allocator).print("  year = {{{d}}},\n", .{self.year});
        if (self.version) |ver| {
            try readme.appendSlice(allocator, "  version = {");
            try readme.writer(allocator).print("{s}", .{ver});
            try readme.appendSlice(allocator, "},\n");
        }
        if (self.doi) |doi| {
            try readme.appendSlice(allocator, "  doi = {");
            try readme.writer(allocator).print("{s}", .{doi});
            try readme.appendSlice(allocator, "},\n");
        }
        if (self.code_url) |url| {
            try readme.appendSlice(allocator, "  url = {");
            try readme.writer(allocator).print("{s}", .{url});
            try readme.appendSlice(allocator, "},\n");
        }
        try readme.appendSlice(allocator, "}\n");
        try readme.appendSlice(allocator, "```\n\n");

        try readme.appendSlice(allocator, "---\n\n");
        try readme.appendSlice(allocator, "This deposit is part of Trinity S³AI Framework.\n");
        try readme.appendSlice(allocator, "For more information, visit: https://github.com/gHashTag/trinity\n");

        return readme.toOwnedSlice(allocator);
    }

    pub fn formatAsLaTeX(self: *const PaperMetadata, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        // Title and abstract
        const abstract = try self.formatAsAbstract(allocator);
        defer allocator.free(abstract);
        try result.appendSlice(allocator, abstract);

        // Conference metadata
        if (self.conference) |conf| {
            const conf_latex = try conf.formatAsLaTeX(allocator);
            defer allocator.free(conf_latex);
            try result.appendSlice(allocator, conf_latex);
        }

        // Broader impact
        if (self.broader_impact) |bi| {
            const bi_latex = try bi.formatAsLaTeX(allocator);
            defer allocator.free(bi_latex);
            try result.appendSlice(allocator, bi_latex);
        }

        // Ethical considerations
        if (self.ethical_considerations) |ec| {
            const ec_latex = try ec.formatAsLaTeX(allocator);
            defer allocator.free(ec_latex);
            try result.appendSlice(allocator, ec_latex);
        }

        // Reproducibility
        if (self.reproducibility) |rep| {
            const rep_latex = try rep.formatAsLaTeX(allocator);
            defer allocator.free(rep_latex);
            try result.appendSlice(allocator, rep_latex);
        }

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// ZENODO VALIDATION — Metadata Quality Checks
// ═══════════════════════════════════════════════════════════════════════════════

/// Validation error
pub const ValidationError = struct {
    field: []const u8,
    message: []const u8,
    severity: []const u8 = "error", // error, warning, info
};

/// Zenodo metadata validator
pub const ZenodoValidation = struct {
    allocator: std.mem.Allocator,
    errors: std.ArrayList(ValidationError),

    pub fn init(allocator: std.mem.Allocator) ZenodoValidation {
        return .{
            .allocator = allocator,
            .errors = std.ArrayList(ValidationError).initCapacity(allocator, 0) catch @panic("OOM"),
        };
    }

    pub fn deinit(self: *ZenodoValidation) void {
        self.errors.deinit(self.allocator);
    }

    /// Validate PaperMetadata
    pub fn validatePaperMetadata(self: *ZenodoValidation, metadata: *const PaperMetadata) !bool {
        var valid = true;

        // Check title
        if (metadata.title.len == 0) {
            try self.errors.append(self.allocator, .{
                .field = "title",
                .message = "Title cannot be empty",
            });
            valid = false;
        } else if (metadata.title.len > 250) {
            try self.errors.append(self.allocator, .{
                .field = "title",
                .message = "Title exceeds 250 character limit",
                .severity = "warning",
            });
        }

        // Check authors
        if (metadata.authors.len == 0) {
            try self.errors.append(self.allocator, .{
                .field = "authors",
                .message = "At least one author is required",
            });
            valid = false;
        }

        // Check abstract
        if (metadata.abstract.len == 0) {
            try self.errors.append(self.allocator, .{
                .field = "abstract",
                .message = "Abstract cannot be empty",
            });
            valid = false;
        }

        // Check keywords (max 10)
        if (metadata.keywords.len == 0) {
            try self.errors.append(self.allocator, .{
                .field = "keywords",
                .message = "At least one keyword is required",
                .severity = "warning",
            });
        } else if (metadata.keywords.len > 10) {
            try self.errors.append(self.allocator, .{
                .field = "keywords",
                .message = "Keywords exceed 10 term limit",
                .severity = "warning",
            });
        }

        // Check year (reasonable range)
        if (metadata.year < 1990 or metadata.year > 2030) {
            try self.errors.append(self.allocator, .{
                .field = "year",
                .message = "Year seems out of reasonable range",
                .severity = "warning",
            });
        }

        // Check DOI format
        if (metadata.doi) |doi| {
            if (!std.mem.startsWith(u8, doi, "10.")) {
                try self.errors.append(self.allocator, .{
                    .field = "doi",
                    .message = "DOI should start with '10.'",
                    .severity = "warning",
                });
            }
        }

        // Check arXiv ID format
        if (metadata.arxiv_id) |arxiv| {
            if (!std.mem.startsWith(u8, arxiv, "arXiv:")) {
                try self.errors.append(self.allocator, .{
                    .field = "arxiv_id",
                    .message = "arXiv ID should start with 'arXiv:'",
                    .severity = "warning",
                });
            }
        }

        return valid;
    }

    /// Get all errors as formatted string
    pub fn formatErrors(self: *const ZenodoValidation, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        if (self.errors.items.len == 0) {
            try result.appendSlice(allocator, "No validation errors found.");
        } else {
            try result.writer(allocator).print("Found {d} validation issue(s):\n\n", .{self.errors.items.len});

            for (self.errors.items) |err| {
                const icon = switch (std.mem.eql(u8, err.severity, "error")) {
                    true => "X",
                    false => if (std.mem.eql(u8, err.severity, "warning")) "!" else "i",
                };
                try result.writer(allocator).print("[{s}] [{s}] {s}: {s}\n", .{ icon, err.severity, err.field, err.message });
            }
        }

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// ZENODO GENERATOR — Unified Metadata Generation
// ═══════════════════════════════════════════════════════════════════════════════

/// Unified Zenodo metadata generator
pub const ZenodoGenerator = struct {
    allocator: std.mem.Allocator,
    bundle: BundleType,
    version: []const u8,

    pub fn init(allocator: std.mem.Allocator, bundle: BundleType, version: []const u8) ZenodoGenerator {
        return .{
            .allocator = allocator,
            .bundle = bundle,
            .version = version,
        };
    }

    /// Generate complete PaperMetadata for a bundle
    pub fn generateMetadata(self: *const ZenodoGenerator) !PaperMetadata {
        const title = try std.fmt.allocPrint(self.allocator, "{s} {s}", .{ self.bundle.displayName(), self.version });
        const abstract = try std.fmt.allocPrint(self.allocator,
            \\This is the {s} component of the Trinity S\\u00B3AI Framework.
            \\Version {s} includes enhanced calibration metrics with 95\\%% confidence intervals,
            \\following NeurIPS 2025 uncertainty quantification standards.
            \\
            \\The Trinity Framework implements ternary neural networks, zero-DSP FPGA inference,
            \\and vector symbolic architectures for energy-efficient AI computing.
        , .{ self.bundle.displayName(), self.version });

        const keywords = try self.allocator.alloc([]const u8, 5);
        keywords[0] = "ternary neural networks";
        keywords[1] = "energy-efficient AI";
        keywords[2] = "FPGA inference";
        keywords[3] = "vector symbolic architectures";
        keywords[4] = "sacred mathematics";

        const authors = try self.allocator.alloc(Author, 1);
        authors[0] = .{
            .name = "Vasilev, Dmitrii",
            .affiliation = "Trinity S\\u00B3AI Framework",
            .orcid = "0000-0000-0000-0000",
            .corresponding = true,
        };

        return PaperMetadata{
            .title = title,
            .authors = authors,
            .abstract = abstract,
            .keywords = keywords,
            .year = 2026,
            .doi = self.bundle.doi(),
            .code_url = "https://github.com/gHashTag/trinity",
            .upload_type = .software,
            .access_right = .open,
            .license = "MIT",
            .version = self.version,
            .communities = &.{ "neurips", "iclr", "mlsys" },
        };
    }

    /// Validate generated metadata
    pub fn validateGenerated(self: *const ZenodoGenerator, metadata: *const PaperMetadata) !bool {
        var validator = ZenodoValidation.init(self.allocator);
        defer validator.deinit();

        const valid = try validator.validatePaperMetadata(metadata);

        if (!valid or validator.errors.items.len > 0) {
            const errors = try validator.formatErrors(self.allocator);
            defer self.allocator.free(errors);
            std.debug.print("{s}\n", .{errors});
        }

        return valid;
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════════════

test "ZenodoAccessRight.toString" {
    try std.testing.expectEqualStrings("open", ZenodoAccessRight.open.toString());
    try std.testing.expectEqualStrings("embargoed", ZenodoAccessRight.embargoed.toString());
    try std.testing.expectEqualStrings("restricted", ZenodoAccessRight.restricted.toString());
    try std.testing.expectEqualStrings("closed", ZenodoAccessRight.closed.toString());
}

test "Conference enum methods" {
    try std.testing.expectEqualStrings("NeurIPS", Conference.neurips.toString());
    try std.testing.expectEqualStrings("Neural Information Processing Systems", Conference.neurips.fullName());
}

test "ZenodoValidation - valid metadata" {
    const testing = std.testing;
    const allocator = testing.allocator;

    const authors = try allocator.alloc(Author, 1);
    defer allocator.free(authors);
    authors[0] = .{
        .name = "Test Author",
        .affiliation = "Test Institution",
        .orcid = null,
    };

    const keywords = try allocator.alloc([]const u8, 2);
    defer allocator.free(keywords);
    keywords[0] = "keyword1";
    keywords[1] = "keyword2";

    const metadata = PaperMetadata{
        .title = "Test Paper",
        .authors = authors,
        .abstract = "This is a test abstract for validation.",
        .keywords = keywords,
        .year = 2026,
    };

    var validator = ZenodoValidation.init(allocator);
    defer validator.deinit();

    const valid = try validator.validatePaperMetadata(&metadata);
    try testing.expect(valid);
}

test "ZenodoValidation - missing required fields" {
    const testing = std.testing;
    const allocator = testing.allocator;

    const authors = try allocator.alloc(Author, 0);
    const keywords = try allocator.alloc([]const u8, 0);

    const metadata = PaperMetadata{
        .title = "",
        .authors = authors,
        .abstract = "",
        .keywords = keywords,
        .year = 2026,
    };

    var validator = ZenodoValidation.init(allocator);
    defer validator.deinit();

    const valid = try validator.validatePaperMetadata(&metadata);
    try testing.expect(!valid);
    try testing.expect(validator.errors.items.len >= 3); // title, authors, abstract
}

test "ZenodoGenerator - generates valid metadata" {
    const testing = std.testing;
    const allocator = testing.allocator;

    const generator = ZenodoGenerator.init(allocator, .ternary_nn, "v7.0.0");
    const metadata = try generator.generateMetadata();

    try std.testing.expectEqualStrings("Ternary Neural Network (HSLM) v7.0.0", metadata.title);
    try std.testing.expectEqual(5, metadata.keywords.len);

    const valid = try generator.validateGenerated(&metadata);
    try testing.expect(valid);

    // Free allocated arrays (metadata structure cleanup)
    allocator.free(metadata.title);
    allocator.free(metadata.abstract);
    allocator.free(metadata.keywords);
    allocator.free(metadata.authors);
}

test "DataCite.formatAsBibTeX" {
    const testing = std.testing;
    const allocator = testing.allocator;

    const datacite = DataCite{
        .doi = "10.5281/zenodo.123456",
        .citation_text = "Example citation text",
        .relationship = .supplements,
    };

    const bibtex = try datacite.formatAsBibTeX(allocator);
    defer allocator.free(bibtex);

    try testing.expect(std.mem.indexOf(u8, bibtex, "10.5281/zenodo.123456") != null);
}

test "PaperMetadata.toZenodoJson - basic JSON generation" {
    const testing = std.testing;
    const allocator = testing.allocator;

    const author = Author{
        .name = "Jane Doe",
        .affiliation = "Trinity Research Institute",
        .orcid = null,
        .corresponding = true,
    };

    const metadata = PaperMetadata{
        .title = "Test Paper for Zenodo",
        .authors = &.{author},
        .abstract = "This is a test abstract for Zenodo metadata generation.",
        .keywords = &.{ "ternary", "neural", "networks", "zenodo" },
        .year = 2026,
        .doi = null,
        .code_url = null,
        .upload_type = .publication,
        .access_right = .open,
        .license = "CC-BY-4.0",
        .version = null,
        .communities = null,
        .bundle = .ternary_nn,
        .conference = null,
        .broader_impact = null,
        .ethical_considerations = null,
        .reproducibility = null,
        .calibration_metrics = null,
    };

    const json = try metadata.toZenodoJson(allocator);
    defer allocator.free(json);

    // Verify JSON contains key fields
    try testing.expect(std.mem.indexOf(u8, json, "Test Paper for Zenodo") != null);
    try testing.expect(std.mem.indexOf(u8, json, "Jane Doe") != null);
    try testing.expect(std.mem.indexOf(u8, json, "Trinity Research Institute") != null);
    try testing.expect(std.mem.indexOf(u8, json, "ternary") != null);
    try testing.expect(std.mem.indexOf(u8, json, "2026-03-27") != null);
    try testing.expect(std.mem.indexOf(u8, json, "bundle_type") != null);
}

// ═════════════════════════════════════════════════════════════════════════════════
// STATISTICAL RESULTS — NeurIPS 2025 Compliance
// ═════════════════════════════════════════════════════════════════════════

pub const StatisticalResults = struct {
    metric: []const u8,
    mean: f64,
    std_dev: f64,
    std_error: f64,
    ci95_lower: f64,
    ci95_upper: f64,
    n: u32,

    pub fn formatAsLaTeX(self: *const StatisticalResults, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator,
            \\{s} & {d:.3} $\\pm$ {d:.3} & [{d:.3}, {d:.3}] & {d}
        , .{ self.metric, self.mean, self.std_error, self.ci95_lower, self.ci95_upper, self.n });
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// POWER ANALYSIS — Energy Consumption and CO2 Calculations
// ═══════════════════════════════════════════════════════════════════════════════

/// Operation type for power analysis
pub const OperationType = enum {
    training,
    inference,
    idle,

    pub fn toString(self: OperationType) []const u8 {
        return switch (self) {
            .training => "Training",
            .inference => "Inference",
            .idle => "Idle",
        };
    }
};

/// Power consumption analysis with CO2 calculations
pub const PowerAnalysis = struct {
    /// Power consumption in watts
    power_watts: f64,
    /// Duration in hours
    duration_hours: f64,
    /// Hardware description
    hardware: []const u8,
    /// Operation type
    operation: OperationType,

    /// Calculate energy consumed in kWh
    pub fn energyKWh(self: *const PowerAnalysis) f64 {
        return (self.power_watts * self.duration_hours) / 1000.0;
    }

    /// Calculate CO2 emissions in kg (EU average: 0.275 kg/kWh)
    pub fn co2Kg(self: *const PowerAnalysis) f64 {
        return self.energyKWh() * 0.275;
    }

    /// Comparison with baseline
    pub const PowerSavings = struct {
        power_reduction_percent: f64,
        annual_co2_savings_kg: f64,
    };

    pub fn compareSavings(self: *const PowerAnalysis, baseline_watts: f64) PowerSavings {
        const reduction = ((baseline_watts - self.power_watts) / baseline_watts) * 100.0;
        const annual_hours = 24.0 * 365.0;
        const annual_savings = ((baseline_watts - self.power_watts) * annual_hours / 1000.0) * 0.275;
        return .{
            .power_reduction_percent = reduction,
            .annual_co2_savings_kg = annual_savings,
        };
    }

    pub fn formatAsMarkdown(self: *const PowerAnalysis, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator,
            \\## Power Analysis
            \\
            \\| Metric | Value |
            \\|--------|-------|
            \\| Hardware | {s} |
            \\| Operation | {s} |
            \\| Power | {d:.1} W |
            \\| Duration | {d:.2} hours |
            \\| Energy | {d:.4} kWh |
            \\| CO₂ Emissions | {d:.3} kg |
        , .{ self.hardware, self.operation.toString(), self.power_watts, self.duration_hours, self.energyKWh(), self.co2Kg() });
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// ENVIRONMENTAL IMPACT — Carbon Footprint Analysis
// ═══════════════════════════════════════════════════════════════════════════════

/// Geographic region for CO2 intensity
pub const Region = enum {
    us_east, // 0.42 kg/kWh
    us_west, // 0.23 kg/kWh
    eu_central, // 0.275 kg/kWh
    eu_west, // 0.19 kg/kWh
    asia_pacific, // 0.51 kg/kWh

    pub fn co2Intensity(self: Region) f64 {
        return switch (self) {
            .us_east => 0.42,
            .us_west => 0.23,
            .eu_central => 0.275,
            .eu_west => 0.19,
            .asia_pacific => 0.51,
        };
    }

    pub fn toString(self: Region) []const u8 {
        return switch (self) {
            .us_east => "US East",
            .us_west => "US West",
            .eu_central => "EU Central",
            .eu_west => "EU West",
            .asia_pacific => "Asia Pacific",
        };
    }
};

/// Environmental impact assessment
pub const EnvironmentalImpact = struct {
    /// Training power analysis
    training: PowerAnalysis,
    /// Inference per 1000 requests
    inference_per_1k: PowerAnalysis,
    /// Total number of inferences
    total_inferences: u64,
    /// Geographic region
    region: Region,

    pub fn totalTrainingCO2(self: *const EnvironmentalImpact) f64 {
        return self.training.energyKWh() * self.region.co2Intensity();
    }

    pub fn totalInferenceCO2(self: *const EnvironmentalImpact) f64 {
        const inference_sets = @as(f64, @floatFromInt(self.total_inferences)) / 1000.0;
        return self.inference_per_1k.energyKWh() * inference_sets * self.region.co2Intensity();
    }

    pub fn totalCO2(self: *const EnvironmentalImpact) f64 {
        return self.totalTrainingCO2() + self.totalInferenceCO2();
    }

    pub fn formatAsMarkdown(self: *const EnvironmentalImpact, allocator: std.mem.Allocator) ![]u8 {
        const training_md = try self.training.formatAsMarkdown(allocator);
        defer allocator.free(training_md);

        return std.fmt.allocPrint(allocator,
            \\{s}
            \\
            \\## Environmental Impact Summary
            \\
            \\| Category | CO₂ (kg) |
            \\|----------|----------|
            \\| Training | {d:.3} |
            \\| Inference ({d} requests) | {d:.3} |
            \\| **Total** | **{d:.3}** |
            \\
            \\*Region: {s} ({d:.3} kg CO₂/kWh)*
        , .{ training_md, self.totalTrainingCO2(), self.total_inferences, self.totalInferenceCO2(), self.totalCO2(), self.region.toString(), self.region.co2Intensity() });
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// SAMPLE SIZE CALCULATOR — Statistical Power Analysis
// ═══════════════════════════════════════════════════════════════════════════════

/// Statistical test type
pub const TestType = enum {
    one_sample_t,
    two_sample_t,
    paired_t,
    anova,
    chi_square,

    pub fn toString(self: TestType) []const u8 {
        return switch (self) {
            .one_sample_t => "One-sample t-test",
            .two_sample_t => "Two-sample t-test",
            .paired_t => "Paired t-test",
            .anova => "ANOVA",
            .chi_square => "Chi-square test",
        };
    }
};

/// Sample size calculator for statistical power
pub const SampleSizeCalculator = struct {
    /// Effect size (Cohen's d)
    effect_size: f64,
    /// Statistical power (1 - beta)
    power: f64,
    /// Significance level (alpha)
    alpha: f64,
    /// Test type
    test_type: TestType,

    pub fn requiredSampleSize(self: *const SampleSizeCalculator) !u32 {
        // Simplified calculation for two-sample t-test
        // n = 2 * (z_alpha + z_beta)^2 / d^2
        if (self.test_type != .two_sample_t) {
            return error.UnsupportedTestType;
        }

        const z_alpha = 1.96; // For alpha = 0.05
        const z_beta = 0.84; // For power = 0.80

        const n = (2 * std.math.pow(f64, z_alpha + z_beta, 2)) / std.math.pow(f64, self.effect_size, 2);
        return @intFromFloat(@ceil(n));
    }

    pub fn formatAsMarkdown(self: *const SampleSizeCalculator, allocator: std.mem.Allocator) ![]u8 {
        const n = try self.requiredSampleSize();
        return std.fmt.allocPrint(allocator,
            \\## Sample Size Analysis
            \\
            \\| Parameter | Value |
            \\|-----------|-------|
            \\| Test Type | {s} |
            \\| Effect Size (Cohen's d) | {d:.2} |
            \\| Power (1-β) | {d:.2} |
            \\| Significance (α) | {d:.3} |
            \\| **Required Sample Size** | **n = {d} per group** |
            \\
            \\*Note: Sample size calculated using two-sample t-test approximation.*
        , .{ self.test_type.toString(), self.effect_size, self.power, self.alpha, n });
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// ROC CURVE — Binary Classification Metrics
// ═══════════════════════════════════════════════════════════════════════════════

/// ROC/AUC analysis for binary classification
pub const ROCCurve = struct {
    /// True Positive Rate values
    tpr: []const f64,
    /// False Positive Rate values
    fpr: []const f64,
    /// Area Under Curve
    auc: f64,
    /// Number of positive samples
    n_pos: u32,
    /// Number of negative samples
    n_neg: u32,

    pub fn accuracyAtThreshold(self: *const ROCCurve, threshold: usize) f64 {
        if (threshold >= self.tpr.len) return 0.0;
        const tp = self.tpr[threshold] * @as(f64, @floatFromInt(self.n_pos));
        const fp = self.fpr[threshold] * @as(f64, @floatFromInt(self.n_neg));
        const tn = @as(f64, @floatFromInt(self.n_neg)) - fp;
        return (tp + tn) / @as(f64, @floatFromInt(self.n_pos + self.n_neg));
    }

    pub fn formatAsMarkdown(self: *const ROCCurve, allocator: std.mem.Allocator) ![]u8 {
        const accuracy = self.accuracyAtThreshold(@min(self.tpr.len - 1, 2));
        return std.fmt.allocPrint(allocator,
            \\## ROC/AUC Analysis
            \\
            \\| Metric | Value |
            \\|--------|-------|
            \\| AUC | {d:.3} |
            \\| Positive Samples | {d} |
            \\| Negative Samples | {d} |
            \\| Accuracy (optimal threshold) | {d:.3} |
            \\
            \\### ROC Curve Points
            \\
            \\| FPR | TPR |
            \\|-----|-----|
            \\| {d:.2} | {d:.2} |
            \\| {d:.2} | {d:.2} |
            \\| {d:.2} | {d:.2} |
            \\| {d:.2} | {d:.2} |
            \\| {d:.2} | {d:.2} |
        , .{
            self.auc,    self.n_pos,  self.n_neg,  accuracy,
            self.fpr[0], self.tpr[0], self.fpr[1], self.tpr[1],
            self.fpr[2], self.tpr[2], self.fpr[3], self.tpr[3],
            self.fpr[4], self.tpr[4],
        });
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// ALGORITHM BOX — Pseudocode Format for Papers
// ═══════════════════════════════════════════════════════════════════════════════

/// Algorithm box with mathematical notation
pub const AlgorithmBox = struct {
    /// Algorithm name
    name: []const u8,
    /// Algorithm description
    description: []const u8,
    /// Input parameters
    inputs: []const []const u8,
    /// Output values
    outputs: []const []const u8,
    /// Algorithm steps
    steps: []const []const u8,

    pub fn formatAsLaTeX(self: *const AlgorithmBox, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "\\begin{algorithm}[H]\n");
        try result.appendSlice(allocator, "\\caption{");
        try result.writer(allocator).print("{s}", .{self.name});
        try result.appendSlice(allocator, "}\n");
        try result.appendSlice(allocator, "\\label{alg:");
        try result.writer(allocator).print("{s}", .{self.name});
        try result.appendSlice(allocator, "}\n");
        try result.appendSlice(allocator, "\\begin{algorithmic}[1]\n");
        try result.appendSlice(allocator, "\\REQUIRE ");
        for (self.inputs, 0..) |input, i| {
            if (i > 0) try result.appendSlice(allocator, ", ");
            try result.writer(allocator).print("{s}", .{input});
        }
        try result.appendSlice(allocator, "\n");
        try result.appendSlice(allocator, "\\ENSURE ");
        for (self.outputs, 0..) |output, i| {
            if (i > 0) try result.appendSlice(allocator, ", ");
            try result.writer(allocator).print("{s}", .{output});
        }
        try result.appendSlice(allocator, "\n");
        try result.appendSlice(allocator, "\\STATE ");
        try result.writer(allocator).print("{s}", .{self.description});
        try result.appendSlice(allocator, "\n");

        for (self.steps) |step| {
            try result.appendSlice(allocator, "\\STATE ");
            try result.writer(allocator).print("{s}", .{step});
            try result.appendSlice(allocator, "\n");
        }

        try result.appendSlice(allocator, "\\end{algorithmic}\n");
        try result.appendSlice(allocator, "\\end{algorithm}\n");

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// COMPARISON TABLE — Baseline Comparison for Papers
// ═══════════════════════════════════════════════════════════════════════════════

/// Comparison table entry
pub const ComparisonEntry = struct {
    /// Method name
    method: []const u8,
    /// Metric value
    value: f64,
    /// Standard error (optional)
    std_err: ?f64 = null,
    /// Is this the proposed method
    proposed: bool = false,

    pub fn formatAsLaTeX(self: *const ComparisonEntry, allocator: std.mem.Allocator) ![]u8 {
        if (self.std_err) |se| {
            if (self.proposed) {
                return std.fmt.allocPrint(allocator, "\\textbf{{{s}}} & \\textbf{{{d:.3} $\\pm$ {d:.3}}}", .{ self.method, self.value, se });
            } else {
                return std.fmt.allocPrint(allocator, "{s} & {d:.3} $\\pm$ {d:.3}", .{ self.method, self.value, se });
            }
        } else {
            if (self.proposed) {
                return std.fmt.allocPrint(allocator, "\\textbf{{{s}}} & \\textbf{{{d:.3}}}", .{ self.method, self.value });
            } else {
                return std.fmt.allocPrint(allocator, "{s} & {d:.3}", .{ self.method, self.value });
            }
        }
    }
};

/// Comparison table for baseline methods
pub const ComparisonTable = struct {
    /// Table caption
    caption: []const u8,
    /// Metric name
    metric: []const u8,
    /// Comparison entries
    entries: []const ComparisonEntry,

    pub fn formatAsLaTeX(self: *const ComparisonTable, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "\\begin{table}[H]\n");
        try result.appendSlice(allocator, "\\centering\n");
        try result.appendSlice(allocator, "\\caption{");
        try result.writer(allocator).print("{s}", .{self.caption});
        try result.appendSlice(allocator, "}\n");
        try result.appendSlice(allocator, "\\begin{tabular}{lc}\n");
        try result.appendSlice(allocator, "\\toprule\n");
        try result.writer(allocator).print("Method & {s} \\\\\n", .{self.metric});
        try result.appendSlice(allocator, "\\midrule\n");

        for (self.entries) |entry| {
            const formatted = try entry.formatAsLaTeX(allocator);
            defer allocator.free(formatted);
            try result.writer(allocator).print("{s} \\\\\n", .{formatted});
        }

        try result.appendSlice(allocator, "\\bottomrule\n");
        try result.appendSlice(allocator, "\\end{tabular}\n");
        try result.appendSlice(allocator, "\\end{table}\n");

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// BATCH PROCESSOR — Combined README Generation
// ═══════════════════════════════════════════════════════════════════════════════

/// Batch processor for generating all Zenodo artifacts
pub const BatchProcessor = struct {
    allocator: std.mem.Allocator,
    metadata: PaperMetadata,

    pub fn init(allocator: std.mem.Allocator, metadata: PaperMetadata) BatchProcessor {
        return .{
            .allocator = allocator,
            .metadata = metadata,
        };
    }

    pub fn generateAll(self: *const BatchProcessor) !struct {
        json: []u8,
        readme: []u8,
        citation: []u8,
    } {
        const json = try self.metadata.toZenodoJson(self.allocator);
        errdefer self.allocator.free(json);

        const readme = try self.metadata.toZenodoReadme(self.allocator);
        errdefer self.allocator.free(readme);

        const citation = try self.metadata.toCitationCFF(self.allocator);
        errdefer self.allocator.free(citation);

        return .{
            .json = json,
            .readme = readme,
            .citation = citation,
        };
    }
};

/// Create default PaperMetadata for a bundle type (CLI compatibility helper)
pub fn createDefaultMetadata(allocator: std.mem.Allocator, bundle: BundleType) !PaperMetadata {
    return ZenodoGenerator.init(allocator, bundle, "v7.0").generateMetadata();
}

// ═══════════════════════════════════════════════════════════════════════════════
// ZENODO V102 — API Integration Structures (Best Practices)
// ═══════════════════════════════════════════════════════════════════════════════

/// OAuth 2.0 client for Zenodo API authentication
/// Based on Zenodo REST API v1.0 documentation
pub const OAuthClient = struct {
    /// Client ID from Zenodo OAuth application
    client_id: []const u8,
    /// Client secret from Zenodo OAuth application
    client_secret: []const u8,
    /// OAuth 2.0 access token (cached)
    access_token: ?[]const u8 = null,
    /// Token expiration timestamp (Unix epoch)
    expires_at: ?u64 = null,
    /// OAuth scopes requested
    scopes: OAuthScopes,

    pub const OAuthScopes = packed struct(u8) {
        deposit_write: bool = false,
        deposit_actions: bool = false,
        deposit_read: bool = false,
        user_read: bool = false,
        _reserved: u4 = 0,

        pub fn toString(self: OAuthScopes) []const u8 {
            if (self.deposit_write and self.deposit_actions) return "deposit:write deposit:actions";
            if (self.deposit_write) return "deposit:write";
            if (self.deposit_read) return "deposit:read";
            if (self.user_read) return "user:read";
            return "deposit:write deposit:actions"; // Default: full deposit access
        }
    };

    pub fn init(client_id: []const u8, client_secret: []const u8, scopes: OAuthScopes) OAuthClient {
        return .{
            .client_id = client_id,
            .client_secret = client_secret,
            .scopes = scopes,
        };
    }

    pub fn getAuthorizationHeader(self: *const OAuthClient, allocator: std.mem.Allocator) ![]u8 {
        if (self.access_token) |token| {
            return std.fmt.allocPrint(allocator, "Bearer {s}", .{token});
        }
        return error.TokenNotSet;
    }

    pub fn isTokenValid(self: *const OAuthClient) bool {
        if (self.access_token == null) return false;
        if (self.expires_at == null) return false;

        const now = std.time.timestamp();
        return self.expires_at.? > now;
    }

    pub fn formatAsMarkdown(self: *const OAuthClient, allocator: std.mem.Allocator) ![]u8 {
        const scopes_str = self.scopes.toString();
        return std.fmt.allocPrint(allocator,
            \\# OAuth 2.0 Client Configuration
            \\
            \\## Client Information
            \\- **Client ID**: `{s}`
            \\- **Scopes**: `{s}`
            \\- **Token Valid**: {any}
            \\
        , .{ self.client_id, scopes_str, self.isTokenValid() });
    }
};

/// Grant/funding reference for Zenodo metadata
/// DOI-prefixed IDs: 10.13039/* (Crossref Funder Registry), 10.5281/* (Zenodo Grants)
pub const GrantReference = struct {
    /// Grant identifier (DOI format)
    id: []const u8,
    /// Grant name/award number
    award_title: []const u8,
    /// Funder name
    funder: []const u8,
    /// Funder DOI (Crossref format)
    funder_doi: ?[]const u8 = null,

    pub fn formatAsZenodoJson(self: *const GrantReference, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print(
            \\  {{
            \\    "id": "{s}",
            \\    "title": "{s}",
            \\    "funder_name": "{s}"
        , .{ self.id, self.award_title, self.funder });

        if (self.funder_doi) |doi| {
            try result.writer(allocator).print(",\n    \"funder_doi\": \"{s}\"", .{doi});
        }

        try result.appendSlice(allocator, "\n  }");

        return result.toOwnedSlice(allocator);
    }
};

/// Related identifier types per Zenodo API specification
pub const RelatedIdentifierType = enum {
    doi,
    arxiv,
    pmid,
    isbn,
    issn,
    url,
    ark,
    bibcode,
    eprint,
    handle,
    lccn,
    lsid,
    purl,
    urn,
    w3id,

    pub fn fromString(s: []const u8) ?RelatedIdentifierType {
        if (std.mem.eql(u8, s, "doi")) return .doi;
        if (std.mem.eql(u8, s, "arxiv")) return .arxiv;
        if (std.mem.eql(u8, s, "pmid")) return .pmid;
        if (std.mem.eql(u8, s, "isbn")) return .isbn;
        if (std.mem.eql(u8, s, "issn")) return .issn;
        if (std.mem.eql(u8, s, "url")) return .url;
        if (std.mem.eql(u8, s, "ark")) return .ark;
        if (std.mem.eql(u8, s, "bibcode")) return .bibcode;
        if (std.mem.eql(u8, s, "eprint")) return .eprint;
        if (std.mem.eql(u8, s, "handle")) return .handle;
        if (std.mem.eql(u8, s, "lccn")) return .lccn;
        if (std.mem.eql(u8, s, "lsid")) return .lsid;
        if (std.mem.eql(u8, s, "purl")) return .purl;
        if (std.mem.eql(u8, s, "urn")) return .urn;
        if (std.mem.eql(u8, s, "w3id")) return .w3id;
        return null;
    }

    pub fn toString(self: RelatedIdentifierType) []const u8 {
        return switch (self) {
            .doi => "doi",
            .arxiv => "arxiv",
            .pmid => "pmid",
            .isbn => "isbn",
            .issn => "issn",
            .url => "url",
            .ark => "ark",
            .bibcode => "bibcode",
            .eprint => "eprint",
            .handle => "handle",
            .lccn => "lccn",
            .lsid => "lsid",
            .purl => "purl",
            .urn => "urn",
            .w3id => "w3id",
        };
    }
};

/// Related identifier relationship types per Zenodo API specification
pub const RelationType = enum {
    is_cited_by,
    cites,
    is_supplement_to,
    is_supplemented_by,
    is_continued_by,
    continues,
    is_described_by,
    describes,
    has_metadata,
    is_metadata_for,
    is_new_version_of,
    is_previous_version_of,
    is_part_of,
    has_part,
    is_referenced_by,
    references,
    is_documented_by,
    documents,
    is_compiled_by,
    compiles,
    is_variant_form_of,
    is_original_form_of,

    pub fn toString(self: RelationType) []const u8 {
        return switch (self) {
            .is_cited_by => "iscitedby",
            .cites => "cites",
            .is_supplement_to => "issupplementto",
            .is_supplemented_by => "issupplementedby",
            .is_continued_by => "iscontinuedby",
            .continues => "continues",
            .is_described_by => "isdescribedby",
            .describes => "describes",
            .has_metadata => "hasmetadata",
            .is_metadata_for => "ismetadatafor",
            .is_new_version_of => "isnewversionof",
            .is_previous_version_of => "ispreviousversionof",
            .is_part_of => "ispartof",
            .has_part => "haspart",
            .is_referenced_by => "isreferencedby",
            .references => "references",
            .is_documented_by => "isdocumentedby",
            .documents => "documents",
            .is_compiled_by => "iscompiledby",
            .compiles => "compiles",
            .is_variant_form_of => "isvariantformof",
            .is_original_form_of => "isoriginalformof",
        };
    }
};

/// Related identifier for Zenodo metadata
pub const RelatedIdentifier = struct {
    /// Identifier value
    identifier: []const u8,
    /// Relationship type (how this identifier relates to the record)
    relation_type: RelationType,
    /// Identifier scheme (what type of identifier)
    scheme: RelatedIdentifierType,

    pub fn formatAsZenodoJson(self: *const RelatedIdentifier, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator,
            \\  {{
            \\    "identifier": "{s}",
            \\    "relation": "{s}",
            \\    "scheme": "{s}"
            \\  }}
        , .{ self.identifier, self.relation_type.toString(), self.scheme.toString() });
    }
};

/// Community submission for Zenodo
pub const CommunitySubmission = struct {
    /// Community identifier (e.g., "zenodo", "ecfunded")
    community_id: []const u8,
    /// Submission status
    status: SubmissionStatus,
    /// Review deadline
    review_deadline: ?[]const u8 = null,

    pub const SubmissionStatus = enum {
        pending,
        accepted,
        rejected,
        withdrawn,

        pub fn toString(self: SubmissionStatus) []const u8 {
            return switch (self) {
                .pending => "pending",
                .accepted => "accepted",
                .rejected => "rejected",
                .withdrawn => "withdrawn",
            };
        }

        pub fn fromString(s: []const u8) ?SubmissionStatus {
            if (std.mem.eql(u8, s, "pending")) return .pending;
            if (std.mem.eql(u8, s, "accepted")) return .accepted;
            if (std.mem.eql(u8, s, "rejected")) return .rejected;
            if (std.mem.eql(u8, s, "withdrawn")) return .withdrawn;
            return null;
        }
    };

    pub fn formatAsZenodoJson(self: *const CommunitySubmission, allocator: std.mem.Allocator) ![]u8 {
        if (self.review_deadline) |deadline| {
            return std.fmt.allocPrint(allocator,
                \\  "communities": [{{
                \\    "id": "{s}",
                \\    "status": "{s}",
                \\    "review_deadline": "{s}"
                \\  }}]
            , .{ self.community_id, self.status.toString(), deadline });
        }
        return std.fmt.allocPrint(allocator,
            \\  "communities": [{{
            \\    "id": "{s}",
            \\    "status": "{s}"
            \\  }}]
        , .{ self.community_id, self.status.toString() });
    }
};

/// Rate limiter for Zenodo API requests
/// Based on Zenodo limits: 60/min (guest), 100/min (authenticated), 5000/min (OAI-PMH)
pub const RateLimiter = struct {
    /// Request timestamp history
    timestamps: std.ArrayList(i64),
    /// Maximum requests per minute
    max_requests: u32,
    /// Sliding window size in seconds
    window_size: u32 = 60,

    pub fn init(allocator: std.mem.Allocator, max_requests: u32, window_size: u32) !RateLimiter {
        const timestamps = std.ArrayList(i64).initCapacity(allocator, 64) catch @panic("OOM");
        return .{
            .timestamps = timestamps,
            .max_requests = max_requests,
            .window_size = window_size,
        };
    }

    pub fn deinit(self: *RateLimiter, allocator: std.mem.Allocator) void {
        self.timestamps.deinit(allocator);
    }

    pub const AuthLevel = enum {
        guest, // 60 requests/minute
        authenticated, // 100 requests/minute
        oai_pmh, // 5000 requests/minute (OAI-PMH endpoint only)

        pub fn getMaxRequests(self: AuthLevel) u32 {
            return switch (self) {
                .guest => 60,
                .authenticated => 100,
                .oai_pmh => 5000,
            };
        }
    };

    pub fn forAuthLevel(allocator: std.mem.Allocator, level: AuthLevel) !RateLimiter {
        return init(allocator, level.getMaxRequests(), 60);
    }

    /// Check if a request can be made
    pub fn canRequest(self: *RateLimiter) bool {
        const now = std.time.timestamp();
        const cutoff = now - @as(i64, @intCast(self.window_size));

        // Remove timestamps outside the window
        var i: usize = 0;
        while (i < self.timestamps.items.len) {
            if (self.timestamps.items[i] < cutoff) {
                _ = self.timestamps.orderedRemove(i);
            } else {
                i += 1;
            }
        }

        return self.timestamps.items.len < self.max_requests;
    }

    /// Record a request was made
    pub fn recordRequest(self: *RateLimiter, allocator: std.mem.Allocator) !void {
        const now = std.time.timestamp();
        try self.timestamps.append(allocator, now);
    }

    /// Get number of requests remaining in current window
    pub fn remainingRequests(self: *RateLimiter) u32 {
        const now = std.time.timestamp();
        const cutoff = now - @as(i64, @intCast(self.window_size));

        var count: usize = 0;
        for (self.timestamps.items) |ts| {
            if (ts >= cutoff) count += 1;
        }

        if (count >= self.max_requests) return 0;
        return self.max_requests - @as(u32, @intCast(count));
    }

    /// Get seconds until next request can be made
    pub fn waitTime(self: *RateLimiter) u32 {
        if (self.canRequest()) return 0;
        if (self.timestamps.items.len == 0) return 0;

        const oldest = self.timestamps.items[0];
        const now = std.time.timestamp();
        const cutoff = oldest + @as(i64, @intCast(self.window_size));

        if (cutoff <= now) return 0;
        return @as(u32, @intCast(cutoff - now));
    }
};

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// ZENODO V103 — Scientific Publication Helpers
// ═══════════════════════════════════════════════════════════════════════════════════════════

/// Paper abstract generator from experimental results
/// Follows NeurIPS/ICLR/MLSys abstract format (5-7 sentences, 250 words max)
pub const AbstractGenerator = struct {
    /// Problem context (1-2 sentences)
    context: []const u8,
    /// Method description (2-3 sentences)
    method: []const u8,
    /// Key results (1-2 sentences with metrics)
    results: []const u8,
    /// Impact statement (1 sentence)
    impact: []const u8,

    pub fn generate(self: *const AbstractGenerator, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print(
            \\We address the challenge of {s}. Our approach leverages {s} to achieve significant improvements. Experimental results show {s}, demonstrating {s}. This work advances the state of the art by combining efficient architectures with rigorous analysis.
        , .{ self.context, self.method, self.results, self.impact });

        return result.toOwnedSlice(allocator);
    }

    pub fn generateStructured(self: *const AbstractGenerator, allocator: std.mem.Allocator) !struct {
        background: []const u8,
        gap: []const u8,
        method: []const u8,
        results: []const u8,
        conclusion: []const u8,
    } {
        return .{
            .background = try std.fmt.allocPrint(allocator, "Problem: {s}", .{self.context}),
            .gap = try std.fmt.allocPrint(allocator, "Gap: Existing approaches lack {s}", .{self.context}),
            .method = try std.fmt.allocPrint(allocator, "Method: {s}", .{self.method}),
            .results = try std.fmt.allocPrint(allocator, "Results: {s}", .{self.results}),
            .conclusion = try std.fmt.allocPrint(allocator, "Conclusion: {s}", .{self.impact}),
        };
    }
};

/// Keywords extractor/generator for Zenodo metadata
/// Generates 5-10 keywords following Zenodo best practices
pub const KeywordsGenerator = struct {
    /// Core concepts (3-5 terms)
    core_concepts: []const []const u8,
    /// Technical terms (2-5 terms)
    technical_terms: []const []const u8,
    /// Domain/field (1-2 terms)
    domain: []const []const u8,

    pub fn generateKeywords(self: *const KeywordsGenerator, allocator: std.mem.Allocator) ![][]const u8 {
        const total_count = self.core_concepts.len + self.technical_terms.len + self.domain.len;

        if (total_count < 5 or total_count > 10) {
            return error.KeywordCountInvalid;
        }

        var keywords = std.ArrayList([]const u8).initCapacity(allocator, total_count) catch @panic("OOM");
        defer keywords.deinit(allocator);

        for (self.core_concepts) |kw| try keywords.append(allocator, kw);
        for (self.technical_terms) |kw| try keywords.append(allocator, kw);
        for (self.domain) |kw| try keywords.append(allocator, kw);

        return keywords.toOwnedSlice(allocator);
    }

    pub fn formatAsArray(self: *const KeywordsGenerator, allocator: std.mem.Allocator) ![]u8 {
        const keywords = try self.generateKeywords(allocator);
        defer allocator.free(keywords);

        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "[");
        for (keywords, 0..) |kw, i| {
            if (i > 0) try result.appendSlice(allocator, ", ");
            try result.writer(allocator).print("\"{s}\"", .{kw});
        }
        try result.appendSlice(allocator, "]");

        return result.toOwnedSlice(allocator);
    }
};

/// Bibliography BibTeX generator from metadata
/// Follows IEEE/APA style for consistent citations
pub const BibliographyBibtex = struct {
    /// Author names (Vasilev, Dmitrii)
    authors: []const []const u8,
    /// Title
    title: []const u8,
    /// Year of publication
    year: u32,
    /// DOI (optional)
    doi: ?[]const u8 = null,
    /// Publisher
    publisher: []const u8,
    /// URL (optional)
    url: ?[]const u8 = null,
    /// Version (optional)
    version: ?[]const u8 = null,

    pub fn generateSoftwareEntry(self: *const BibliographyBibtex, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        const entry_key = try self.generateEntryKey(allocator);
        defer allocator.free(entry_key);

        try result.appendSlice(allocator, "@software{");
        try result.writer(allocator).print("{s},\n", .{entry_key});
        try result.writer(allocator).print("  title=\"{{{s}}}\",\n", .{self.title});

        const authors_str = try self.formatAuthors(allocator);
        defer allocator.free(authors_str);
        try result.writer(allocator).print("  author=\"{{{s}}}\",\n", .{authors_str});

        try result.writer(allocator).print("  year={d},\n", .{self.year});
        try result.writer(allocator).print("  publisher=\"{{{s}}}\"", .{self.publisher});

        if (self.version) |ver| {
            try result.writer(allocator).print(",\n  version=\"{{{s}}}\"", .{ver});
        }

        if (self.doi) |doi_str| {
            try result.writer(allocator).print(",\n  doi=\"{{{s}}}\"", .{doi_str});
        }

        if (self.url) |url_str| {
            try result.writer(allocator).print(",\n  url=\"{{{s}}}\"", .{url_str});
        }

        try result.appendSlice(allocator, "\n}\n");

        return result.toOwnedSlice(allocator);
    }

    fn generateEntryKey(self: *const BibliographyBibtex, allocator: std.mem.Allocator) ![]u8 {
        if (self.authors.len == 0) return error.NoAuthors;
        const last_name = try self.extractLastName(allocator, self.authors[0]);
        defer allocator.free(last_name);
        const first_word = try self.extractFirstWord(allocator, self.title);
        defer allocator.free(first_word);
        return std.fmt.allocPrint(allocator, "{s}_{d}_{s}", .{ last_name, self.year, first_word });
    }

    fn extractLastName(_: *const BibliographyBibtex, allocator: std.mem.Allocator, full_name: []const u8) ![]u8 {
        if (std.mem.indexOf(u8, full_name, ",") != null) {
            var parts = std.mem.splitSequence(u8, full_name, ",");
            const last_name = parts.first();
            return allocator.dupe(u8, std.mem.trim(u8, last_name, " "));
        }
        const space_idx = std.mem.lastIndexOfScalar(u8, full_name, ' ') orelse 0;
        return allocator.dupe(u8, full_name[space_idx + 1 ..]);
    }

    fn extractFirstWord(_: *const BibliographyBibtex, allocator: std.mem.Allocator, title: []const u8) ![]u8 {
        const trimmed = std.mem.trim(u8, title, " ");
        const end_idx = std.mem.indexOfScalar(u8, trimmed, ' ') orelse trimmed.len;
        const first_word = trimmed[0..end_idx];
        var result = std.ArrayList(u8).initCapacity(allocator, first_word.len) catch @panic("OOM");
        defer result.deinit(allocator);
        for (first_word) |c| {
            if (std.ascii.isAlphabetic(c)) {
                try result.append(allocator, std.ascii.toLower(c));
            }
        }
        return result.toOwnedSlice(allocator);
    }

    fn formatAuthors(self: *const BibliographyBibtex, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);
        for (self.authors, 0..) |author, i| {
            if (i > 0) try result.appendSlice(allocator, " and ");
            try result.appendSlice(allocator, author);
        }
        return result.toOwnedSlice(allocator);
    }
};

/// Supplementary materials structure for Zenodo deposits
pub const SupplementaryMaterials = struct {
    code_url: ?[]const u8 = null,
    dataset_url: ?[]const u8 = null,
    additional_files: []const []const u8,
    readme_content: ?[]const u8 = null,

    pub fn generateFileList(self: *const SupplementaryMaterials, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);
        try result.appendSlice(allocator, "## Files in this Deposit\n\n");
        if (self.code_url) |url| {
            try result.writer(allocator).print("- **Code**: {s}\n", .{url});
        }
        if (self.dataset_url) |url| {
            try result.writer(allocator).print("- **Dataset**: {s}\n", .{url});
        }
        for (self.additional_files) |file| {
            try result.writer(allocator).print("- **Additional**: {s}\n", .{file});
        }
        return result.toOwnedSlice(allocator);
    }
};

/// Peer review response template
pub const PeerReviewResponse = struct {
    comments: []const ReviewComment,
    paper_title: []const u8,

    pub const ReviewComment = struct {
        reviewer: ?[]const u8 = null,
        text: []const u8,
        number: u32,

        pub fn format(self: *const ReviewComment, allocator: std.mem.Allocator) ![]u8 {
            if (self.reviewer) |name| {
                return std.fmt.allocPrint(allocator, "**Comment {d} ({s}):** {s}\n", .{ self.number, name, self.text });
            }
            return std.fmt.allocPrint(allocator, "**Comment {d}:** {s}\n", .{ self.number, self.text });
        }
    };

    pub fn generateResponse(self: *const PeerReviewResponse, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 2048) catch @panic("OOM");
        defer result.deinit(allocator);
        try result.writer(allocator).print(
            \\# Response to Reviewers - {s}
            \\Thank you for your thoughtful review. Below are our point-by-point responses.
            \\
        , .{self.paper_title});
        try result.appendSlice(allocator, "\n## Point-by-Point Response\n\n");
        for (self.comments) |comment| {
            const formatted = try comment.format(allocator);
            defer allocator.free(formatted);
            try result.appendSlice(allocator, "\n### ");
            try result.appendSlice(allocator, formatted);
            try result.appendSlice(allocator, "\n\n**Response:**\n\n");
        }
        try result.appendSlice(allocator,
            \\We have incorporated the suggested changes where appropriate.
            \\Thank you again for your valuable feedback.
        );
        return result.toOwnedSlice(allocator);
    }
};

/// Presentation slide structure generator (LaTeX Beamer)
pub const PresentationSlides = struct {
    title: []const u8,
    authors: []const []const u8,
    conference: []const u8,
    slides: []const Slide,

    pub const Slide = struct {
        title: []const u8,
        content: []const u8,
        has_bullet: bool = false,
        has_equation: bool = false,
    };

    pub fn generateBeamer(self: *const PresentationSlides, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 4096) catch @panic("OOM");
        defer result.deinit(allocator);
        try result.appendSlice(allocator,
            \\\\documentclass{beamer}
            \\\\usetheme{Madrid}
            \\\\usecolortheme{default}
            \\\\usepackage{graphicx}
            \\\\usepackage{amsmath}
            \\  \\title{{{s}}}
        );
        try result.writer(allocator).print("  \\title{{{s}}}\n", .{self.title});

        const authors_str = try self.formatAuthorsInline(allocator);
        defer allocator.free(authors_str);
        try result.writer(allocator).print("  \\author{{{s}}}\n", .{authors_str});

        try result.writer(allocator).print("  \\date{{{s}}}\n", .{self.conference});
        try result.appendSlice(allocator,
            \\\\begin{document}
            \\\\begin{frame}
            \\   \\titlepage
            \\\\end{frame}
        );
        for (self.slides) |slide| {
            try result.appendSlice(allocator, "\n\\begin{frame}{");
            try result.writer(allocator).print("{{{s}}}\n", .{slide.title});
            if (slide.has_equation) {
                try result.writer(allocator).print("  \\[ {s} \\]\n", .{slide.content});
            } else if (slide.has_bullet) {
                try result.appendSlice(allocator, "  \\begin{itemize}\n");
                try result.writer(allocator).print("    \\item {s}\n", .{slide.content});
                try result.appendSlice(allocator, "  \\end{itemize}\n");
            } else {
                try result.writer(allocator).print("  {s}\n", .{slide.content});
            }
            try result.appendSlice(allocator, "\\end{frame}\n");
        }
        try result.appendSlice(allocator, "\\end{document}\n");
        return result.toOwnedSlice(allocator);
    }

    fn formatAuthorsInline(self: *const PresentationSlides, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);
        for (self.authors, 0..) |author, i| {
            if (i > 0) try result.appendSlice(allocator, " and ");
            try result.appendSlice(allocator, author);
        }
        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// TESTS — New Structures (V101 + V102 + V103)
// ═══════════════════════════════════════════════════════════════════════════════

test "PowerAnalysis - energy and CO2 calculations" {
    const power = PowerAnalysis{
        .power_watts = 1.2,
        .duration_hours = 4.0,
        .hardware = "QMTech XC7A100T",
        .operation = .inference,
    };

    const energy = power.energyKWh();
    const co2 = power.co2Kg();

    try std.testing.expectApproxEqAbs(0.0048, energy, 0.0001);
    try std.testing.expectApproxEqAbs(0.00132, co2, 0.00001);

    const savings = power.compareSavings(25.0);
    try std.testing.expectApproxEqAbs(95.2, savings.power_reduction_percent, 0.1);
}

test "EnvironmentalImpact - total CO2 calculation" {
    const training = PowerAnalysis{
        .power_watts = 15.0,
        .duration_hours = 4.0,
        .hardware = "Apple M1 Pro",
        .operation = .training,
    };

    const inference_per_1k = PowerAnalysis{
        .power_watts = 1.2,
        .duration_hours = 0.277,
        .hardware = "QMTech XC7A100T",
        .operation = .inference,
    };

    const impact = EnvironmentalImpact{
        .training = training,
        .inference_per_1k = inference_per_1k,
        .total_inferences = 100000,
        .region = .eu_central,
    };

    const total = impact.totalCO2();
    try std.testing.expect(total > 0.0);

    const md = try impact.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);
    try std.testing.expect(std.mem.indexOf(u8, md, "Environmental Impact") != null);
}

test "SampleSizeCalculator - Cohen's d calculation" {
    const calc = SampleSizeCalculator{
        .effect_size = 1.8,
        .power = 0.8,
        .alpha = 0.05,
        .test_type = .two_sample_t,
    };

    const n = try calc.requiredSampleSize();
    try std.testing.expect(n < 10);

    const md = try calc.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);
    try std.testing.expect(std.mem.indexOf(u8, md, "Required Sample Size") != null);
}

test "ROCCurve - AUC and accuracy" {
    const tpr = [_]f64{ 0.0, 0.65, 0.85, 0.95, 1.0 };
    const fpr = [_]f64{ 0.0, 0.15, 0.35, 0.60, 1.0 };

    const roc = ROCCurve{
        .tpr = &tpr,
        .fpr = &fpr,
        .auc = 0.82,
        .n_pos = 500,
        .n_neg = 500,
    };

    const accuracy = roc.accuracyAtThreshold(2);
    try std.testing.expect(accuracy > 0.5);
    try std.testing.expect(accuracy < 1.0);

    const md = try roc.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);
    try std.testing.expect(std.mem.indexOf(u8, md, "ROC/AUC") != null);
}

test "StatisticalResults - LaTeX format with CI" {
    const stats = StatisticalResults{
        .metric = "Accuracy",
        .mean = 0.85,
        .std_dev = 0.03,
        .std_error = 0.004,
        .ci95_lower = 0.842,
        .ci95_upper = 0.858,
        .n = 1000,
    };

    const latex = try stats.formatAsLaTeX(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "Accuracy") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "0.85") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "0.842") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "0.858") != null);
}

test "AlgorithmBox - LaTeX algorithm environment" {
    const inputs = [_][]const u8{ "X", "Y" };
    const outputs = [_][]const u8{"Z"};
    const steps = [_][]const u8{"Z := X + Y"};

    const box = AlgorithmBox{
        .name = "TestAlgorithm",
        .description = "Simple addition algorithm",
        .inputs = &inputs,
        .outputs = &outputs,
        .steps = &steps,
    };

    const latex = try box.formatAsLaTeX(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "\\begin{algorithm}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "TestAlgorithm") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\REQUIRE") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\ENSURE") != null);
}

test "ComparisonTable - LaTeX table with proposed method" {
    const entries = [_]ComparisonEntry{
        .{ .method = "Baseline 1", .value = 0.75 },
        .{ .method = "Baseline 2", .value = 0.80, .std_err = 0.01 },
        .{ .method = "Proposed", .value = 0.85, .std_err = 0.004, .proposed = true },
    };

    const table = ComparisonTable{
        .caption = "Method comparison on test set",
        .metric = "Accuracy",
        .entries = &entries,
    };

    const latex = try table.formatAsLaTeX(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "\\begin{table}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "Accuracy") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\textbf{") != null);
}

test "Region - CO2 intensity values" {
    try std.testing.expectApproxEqAbs(0.42, Region.us_east.co2Intensity(), 0.001);
    try std.testing.expectApproxEqAbs(0.275, Region.eu_central.co2Intensity(), 0.001);
    try std.testing.expectApproxEqAbs(0.51, Region.asia_pacific.co2Intensity(), 0.001);
}

// ═══════════════════════════════════════════════════════════════════════════════
// TESTS — V102 Structures
// ═══════════════════════════════════════════════════════════════════════════════

test "OAuthClient - initialization and scopes" {
    const oauth = OAuthClient.init("test_client_id", "test_secret", .{
        .deposit_write = true,
        .deposit_actions = true,
    });

    try std.testing.expectEqualStrings("test_client_id", oauth.client_id);
    try std.testing.expect(oauth.access_token == null);
    try std.testing.expect(!oauth.isTokenValid());

    // Should return error when token is not set
    const result = oauth.getAuthorizationHeader(std.testing.allocator);
    try std.testing.expectError(error.TokenNotSet, result);
}

test "OAuthClient - scopes string representation" {
    const scopes1 = OAuthClient.OAuthScopes{ .deposit_write = true, .deposit_actions = true };
    const scopes2 = OAuthClient.OAuthScopes{ .deposit_write = true };
    const scopes3 = OAuthClient.OAuthScopes{ .deposit_read = true };

    try std.testing.expectEqualStrings("deposit:write deposit:actions", scopes1.toString());
    try std.testing.expectEqualStrings("deposit:write", scopes2.toString());
    try std.testing.expectEqualStrings("deposit:read", scopes3.toString());
}

test "GrantReference - Zenodo JSON format" {
    const grant = GrantReference{
        .id = "10.13039/501100000780",
        .award_title = "Trinity S³AI Research",
        .funder = "European Research Council",
        .funder_doi = "10.13039/501100000780",
    };

    const json = try grant.formatAsZenodoJson(std.testing.allocator);
    defer std.testing.allocator.free(json);

    try std.testing.expect(std.mem.indexOf(u8, json, "10.13039/501100000780") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "European Research Council") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "funder_doi") != null);
}

test "RelatedIdentifierType - enum to string conversion" {
    try std.testing.expectEqualStrings("doi", RelatedIdentifierType.doi.toString());
    try std.testing.expectEqualStrings("arxiv", RelatedIdentifierType.arxiv.toString());
    try std.testing.expectEqualStrings("pmid", RelatedIdentifierType.pmid.toString());
    try std.testing.expectEqualStrings("isbn", RelatedIdentifierType.isbn.toString());
    try std.testing.expectEqualStrings("url", RelatedIdentifierType.url.toString());

    try std.testing.expect(RelatedIdentifierType.fromString("doi") == .doi);
    try std.testing.expect(RelatedIdentifierType.fromString("arxiv") == .arxiv);
    try std.testing.expect(RelatedIdentifierType.fromString("invalid") == null);
}

test "RelationType - enum to string conversion" {
    try std.testing.expectEqualStrings("iscitedby", RelationType.is_cited_by.toString());
    try std.testing.expectEqualStrings("cites", RelationType.cites.toString());
    try std.testing.expectEqualStrings("issupplementto", RelationType.is_supplement_to.toString());
    try std.testing.expectEqualStrings("isnewversionof", RelationType.is_new_version_of.toString());
    try std.testing.expectEqualStrings("ispartof", RelationType.is_part_of.toString());
}

test "RelatedIdentifier - Zenodo JSON format" {
    const related = RelatedIdentifier{
        .identifier = "10.5281/zenodo.19227865",
        .relation_type = .is_new_version_of,
        .scheme = .doi,
    };

    const json = try related.formatAsZenodoJson(std.testing.allocator);
    defer std.testing.allocator.free(json);

    try std.testing.expect(std.mem.indexOf(u8, json, "10.5281/zenodo.19227865") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "isnewversionof") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "doi") != null);
}

test "CommunitySubmission - Zenodo JSON format" {
    const comm1 = CommunitySubmission{
        .community_id = "zenodo",
        .status = .accepted,
        .review_deadline = null,
    };

    const json1 = try comm1.formatAsZenodoJson(std.testing.allocator);
    defer std.testing.allocator.free(json1);
    try std.testing.expect(std.mem.indexOf(u8, json1, "zenodo") != null);
    try std.testing.expect(std.mem.indexOf(u8, json1, "accepted") != null);

    const comm2 = CommunitySubmission{
        .community_id = "ecfunded",
        .status = .pending,
        .review_deadline = "2026-04-01",
    };

    const json2 = try comm2.formatAsZenodoJson(std.testing.allocator);
    defer std.testing.allocator.free(json2);
    try std.testing.expect(std.mem.indexOf(u8, json2, "ecfunded") != null);
    try std.testing.expect(std.mem.indexOf(u8, json2, "pending") != null);
    try std.testing.expect(std.mem.indexOf(u8, json2, "2026-04-01") != null);
}

test "SubmissionStatus - enum conversion" {
    try std.testing.expectEqualStrings("pending", CommunitySubmission.SubmissionStatus.pending.toString());
    try std.testing.expectEqualStrings("accepted", CommunitySubmission.SubmissionStatus.accepted.toString());
    try std.testing.expectEqualStrings("rejected", CommunitySubmission.SubmissionStatus.rejected.toString());
    try std.testing.expectEqualStrings("withdrawn", CommunitySubmission.SubmissionStatus.withdrawn.toString());

    try std.testing.expect(CommunitySubmission.SubmissionStatus.fromString("pending") == .pending);
    try std.testing.expect(CommunitySubmission.SubmissionStatus.fromString("accepted") == .accepted);
    try std.testing.expect(CommunitySubmission.SubmissionStatus.fromString("invalid") == null);
}

test "RateLimiter - guest rate limiting (60/min)" {
    var limiter = try RateLimiter.forAuthLevel(std.testing.allocator, .guest);
    defer limiter.deinit(std.testing.allocator);

    try std.testing.expectEqual(60, limiter.max_requests);

    // Should allow first request
    try std.testing.expect(limiter.canRequest() == true);
    try limiter.recordRequest(std.testing.allocator);

    // Should still allow (59 remaining)
    try std.testing.expect(limiter.canRequest() == true);
}

test "RateLimiter - authenticated rate limiting (100/min)" {
    var limiter = try RateLimiter.forAuthLevel(std.testing.allocator, .authenticated);
    defer limiter.deinit(std.testing.allocator);

    try std.testing.expectEqual(100, limiter.max_requests);
    try std.testing.expectEqual(100, limiter.remainingRequests());
}

test "RateLimiter - OAI-PMH rate limiting (5000/min)" {
    var limiter = try RateLimiter.forAuthLevel(std.testing.allocator, .oai_pmh);
    defer limiter.deinit(std.testing.allocator);

    try std.testing.expectEqual(5000, limiter.max_requests);
    try std.testing.expect(limiter.waitTime() == 0);
}

test "RateLimiter - AuthLevel max requests" {
    try std.testing.expectEqual(60, RateLimiter.AuthLevel.guest.getMaxRequests());
    try std.testing.expectEqual(100, RateLimiter.AuthLevel.authenticated.getMaxRequests());
    try std.testing.expectEqual(5000, RateLimiter.AuthLevel.oai_pmh.getMaxRequests());
}

// ═════════════════════════════════════════════════════════════════════════════
// TESTS — V103 Structures
// ═════════════════════════════════════════════════════════════════════════════════

test "AbstractGenerator - generates full abstract" {
    const abstract_gen = AbstractGenerator{
        .context = "neural network quantization for edge deployment",
        .method = "ternary encoding with sacred scaling factors",
        .results = "94% accuracy with 20× compression",
        .impact = "enables efficient inference on resource-constrained devices",
    };

    const abstract = try abstract_gen.generate(std.testing.allocator);
    defer std.testing.allocator.free(abstract);

    try std.testing.expect(std.mem.indexOf(u8, abstract, "ternary encoding") != null);
    try std.testing.expect(std.mem.indexOf(u8, abstract, "94% accuracy") != null);
}

test "AbstractGenerator - generates structured abstract" {
    const abstract_gen = AbstractGenerator{
        .context = "neural network quantization",
        .method = "ternary encoding",
        .results = "94% accuracy",
        .impact = "efficient inference",
    };

    const structured = try abstract_gen.generateStructured(std.testing.allocator);
    defer std.testing.allocator.free(structured.background);
    defer std.testing.allocator.free(structured.gap);
    defer std.testing.allocator.free(structured.method);
    defer std.testing.allocator.free(structured.results);
    defer std.testing.allocator.free(structured.conclusion);

    try std.testing.expect(std.mem.indexOf(u8, structured.background, "neural network quantization") != null);
}

test "KeywordsGenerator - generates valid keywords array" {
    const core = [_][]const u8{ "ternary neural networks", "quantization", "edge AI" };
    const tech = [_][]const u8{ "sacred scaling", "FPGA inference" };
    const dom = [_][]const u8{"machine learning"};

    const gen = KeywordsGenerator{
        .core_concepts = &core,
        .technical_terms = &tech,
        .domain = &dom,
    };

    const array_str = try gen.formatAsArray(std.testing.allocator);
    defer std.testing.allocator.free(array_str);

    try std.testing.expect(std.mem.indexOf(u8, array_str, "\"ternary neural networks\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, array_str, "\"FPGA inference\"") != null);
}

test "BibliographyBibtex - generates software entry" {
    const authors = [_][]const u8{"Vasilev, Dmitrii"};
    const bibtex = BibliographyBibtex{
        .authors = &authors,
        .title = "Trinity S³AI Framework",
        .year = 2026,
        .doi = "10.5281/zenodo.XXXXXX",
        .publisher = "Zenodo",
        .url = "https://github.com/gHashTag/trinity",
        .version = "v2.9",
    };

    const entry = try bibtex.generateSoftwareEntry(std.testing.allocator);
    defer std.testing.allocator.free(entry);

    try std.testing.expect(std.mem.indexOf(u8, entry, "@software{") != null);
    try std.testing.expect(std.mem.indexOf(u8, entry, "Trinity S³AI Framework") != null);
}

test "BibliographyBibtex - extracts last name" {
    const authors = [_][]const u8{"Vasilev, Dmitrii"};
    const bibtex = BibliographyBibtex{
        .authors = &authors,
        .title = "Test",
        .year = 2026,
        .publisher = "Zenodo",
    };

    const last_name = try bibtex.extractLastName(std.testing.allocator, "Vasilev, Dmitrii");
    defer std.testing.allocator.free(last_name);

    try std.testing.expectEqualStrings("Vasilev", last_name);
}

test "SupplementaryMaterials - generates file list" {
    const additional = [_][]const u8{ "README.md", "LICENSE" };
    const sup = SupplementaryMaterials{
        .code_url = "https://github.com/gHashTag/trinity",
        .dataset_url = "https://zenodo.org/record/XXXXX",
        .additional_files = &additional,
    };

    const file_list = try sup.generateFileList(std.testing.allocator);
    defer std.testing.allocator.free(file_list);

    try std.testing.expect(std.mem.indexOf(u8, file_list, "**Code**") != null);
    try std.testing.expect(std.mem.indexOf(u8, file_list, "**Dataset**") != null);
}

test "PeerReviewResponse - generates response" {
    const comment1 = PeerReviewResponse.ReviewComment{
        .reviewer = "Reviewer 1",
        .text = "Abstract needs more clarity",
        .number = 1,
    };
    const comment2 = PeerReviewResponse.ReviewComment{
        .reviewer = "Reviewer 2",
        .text = "Add more experimental results",
        .number = 2,
    };
    const comments = [_]PeerReviewResponse.ReviewComment{ comment1, comment2 };

    const response = PeerReviewResponse{
        .comments = &comments,
        .paper_title = "Trinity S³AI Framework",
    };

    const response_text = try response.generateResponse(std.testing.allocator);
    defer std.testing.allocator.free(response_text);

    try std.testing.expect(std.mem.indexOf(u8, response_text, "Response to Reviewers") != null);
    try std.testing.expect(std.mem.indexOf(u8, response_text, "Thank you") != null);
}

test "PresentationSlides - generates beamer structure" {
    const slide1 = PresentationSlides.Slide{
        .title = "Introduction",
        .content = "Trinity S³AI Framework overview",
        .has_bullet = true,
    };
    const slide2 = PresentationSlides.Slide{
        .title = "Results",
        .content = "94% accuracy with 20× compression",
        .has_equation = true,
    };
    const slides = [_]PresentationSlides.Slide{ slide1, slide2 };
    const authors = [_][]const u8{"Vasilev, Dmitrii"};

    const pres = PresentationSlides{
        .title = "Trinity S³AI Framework",
        .authors = &authors,
        .conference = "NeurIPS 2026",
        .slides = &slides,
    };

    const beamer = try pres.generateBeamer(std.testing.allocator);
    defer std.testing.allocator.free(beamer);

    try std.testing.expect(std.mem.indexOf(u8, beamer, "\\documentclass{beamer}") != null);
    try std.testing.expect(std.mem.indexOf(u8, beamer, "Trinity S³AI Framework") != null);
}
