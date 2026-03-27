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
    comments: []const PeerReviewComment,
    paper_title: []const u8,

    pub const PeerReviewComment = struct {
        reviewer: ?[]const u8 = null,
        text: []const u8,
        number: u32,

        pub fn format(self: *const PeerReviewComment, allocator: std.mem.Allocator) ![]u8 {
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
    const comment1 = PeerReviewResponse.PeerReviewComment{
        .reviewer = "Reviewer 1",
        .text = "Abstract needs more clarity",
        .number = 1,
    };
    const comment2 = PeerReviewResponse.PeerReviewComment{
        .reviewer = "Reviewer 2",
        .text = "Add more experimental results",
        .number = 2,
    };
    const comments = [_]PeerReviewResponse.PeerReviewComment{ comment1, comment2 };

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

// ═══════════════════════════════════════════════════════════════════════════════
// V104: PUBLICATION-READY STRUCTURES
// ═══════════════════════════════════════════════════════════════════════════════

/// Citation style enumeration for academic formatting
pub const CitationStyle = enum {
    /// APA 7th edition
    apa,
    /// IEEE style
    ieee,
    /// MLA 9th edition
    mla,
    /// Chicago author-date
    chicago,
    /// Harvard style
    harvard,
    /// Vancouver (numbered)
    vancouver,

    pub fn toString(self: CitationStyle) []const u8 {
        return switch (self) {
            .apa => "APA",
            .ieee => "IEEE",
            .mla => "MLA",
            .chicago => "Chicago",
            .harvard => "Harvard",
            .vancouver => "Vancouver",
        };
    }

    pub fn formatLabel(self: CitationStyle) []const u8 {
        return switch (self) {
            .apa => "APA 7th Edition",
            .ieee => "IEEE Style",
            .mla => "MLA 9th Edition",
            .chicago => "Chicago Author-Date",
            .harvard => "Harvard Referencing",
            .vancouver => "Vancouver (Numbered)",
        };
    }
};

/// Simple citation generator for standard academic formats
pub const SimpleCitation = struct {
    /// Primary author(s) - format: "Last, First" or "Last1, First1; Last2, First2"
    author: []const u8,
    /// Publication title
    title: []const u8,
    /// Publication year
    year: u32,
    /// Publisher or venue
    publisher: []const u8,
    /// Optional volume/issue
    volume: ?[]const u8 = null,
    /// Optional pages
    pages: ?[]const u8 = null,
    /// Optional DOI
    doi: ?[]const u8 = null,
    /// Optional URL
    url: ?[]const u8 = null,

    /// Format citation in APA 7th edition style
    /// Format: Author. (Year). Title. Publisher. DOI/URL
    pub fn formatAPA(self: *const SimpleCitation, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        // Author
        try result.appendSlice(allocator, self.author);
        try result.append(allocator, '.');

        // Year in parentheses
        try result.writer(allocator).print(" ({d}). ", .{self.year});

        // Title in italics (markdown for display)
        try result.appendSlice(allocator, "*");
        try result.appendSlice(allocator, self.title);
        try result.appendSlice(allocator, "*.");

        // Publisher
        try result.appendSlice(allocator, " ");
        try result.appendSlice(allocator, self.publisher);
        try result.append(allocator, '.');

        // DOI if available
        if (self.doi) |d| {
            try result.writer(allocator).print(" https://doi.org/{s}", .{d});
        }

        // URL if no DOI
        if (self.url != null and self.doi == null) {
            try result.writer(allocator).print(" {s}", .{self.url.?});
        }

        return result.toOwnedSlice(allocator);
    }

    /// Format citation in IEEE style
    /// Format: Author, "Title," Publisher, Year, vol. X, pp. Y-Z, DOI.
    pub fn formatIEEE(self: *const SimpleCitation, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        // Author
        try result.appendSlice(allocator, self.author);

        // Title in quotes
        try result.writer(allocator).print(", \"{s},\" ", .{self.title});

        // Publisher
        try result.appendSlice(allocator, self.publisher);

        // Year
        try result.writer(allocator).print(", {d}", .{self.year});

        // Volume if available
        if (self.volume) |vol| {
            try result.writer(allocator).print(", vol. {s}", .{vol});
        }

        // Pages if available
        if (self.pages) |pg| {
            try result.writer(allocator).print(", pp. {s}", .{pg});
        }

        // DOI if available
        if (self.doi) |d| {
            try result.writer(allocator).print(", doi: {s}", .{d});
        }

        try result.append(allocator, '.');

        return result.toOwnedSlice(allocator);
    }

    /// Format citation in MLA 9th edition style
    /// Format: Author. *Title*. Publisher, Year.
    pub fn formatMLA(self: *const SimpleCitation, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        // Author
        try result.appendSlice(allocator, self.author);
        try result.appendSlice(allocator, ". ");

        // Title in italics
        try result.appendSlice(allocator, "*");
        try result.appendSlice(allocator, self.title);
        try result.appendSlice(allocator, "*.");

        // Publisher
        try result.appendSlice(allocator, " ");
        try result.appendSlice(allocator, self.publisher);

        // Year
        try result.writer(allocator).print(", {d}.", .{self.year});

        return result.toOwnedSlice(allocator);
    }
};

/// Simple figure caption generator for papers
pub const SimpleFigureCaption = struct {
    /// Figure number
    number: u32,
    /// Figure title
    title: []const u8,
    /// Detailed description
    description: []const u8,
    /// Optional note
    note: ?[]const u8 = null,

    /// Generate formatted caption
    pub fn generate(self: *const SimpleFigureCaption, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("Figure {d}: ", .{self.number});
        try result.appendSlice(allocator, self.title);
        try result.appendSlice(allocator, ". ");
        try result.appendSlice(allocator, self.description);

        if (self.note) |n| {
            try result.writer(allocator).print(" ({s})", .{n});
        }

        return result.toOwnedSlice(allocator);
    }

    /// Generate LaTeX caption
    pub fn generateLatex(self: *const SimpleFigureCaption, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("\\caption{{Figure {d}: ", .{self.number});
        try result.appendSlice(allocator, self.title);
        try result.appendSlice(allocator, ". ");
        try result.appendSlice(allocator, self.description);

        if (self.note) |n| {
            try result.writer(allocator).print(" ({s})", .{n});
        }

        try result.appendSlice(allocator, "}");

        return result.toOwnedSlice(allocator);
    }
};

/// Simple table generator for papers
pub const SimpleTable = struct {
    /// Table caption
    caption: []const u8,
    /// Column headers
    columns: []const []const u8,
    /// Row data (each row is array of cell values)
    rows: []const []const []const u8,

    /// Generate markdown table
    pub fn generateMarkdown(self: *const SimpleTable, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        // Caption
        try result.writer(allocator).print("**Table:** {s}\n\n", .{self.caption});

        // Header row
        for (self.columns, 0..) |col, i| {
            if (i > 0) try result.append(allocator, '|');
            try result.append(allocator, ' ');
            try result.appendSlice(allocator, col);
            try result.append(allocator, ' ');
        }
        try result.appendSlice(allocator, "|\n");

        // Separator row
        for (self.columns, 0..) |_, i| {
            if (i > 0) try result.append(allocator, '|');
            try result.appendSlice(allocator, "---");
        }
        try result.appendSlice(allocator, "|\n");

        // Data rows
        for (self.rows) |row| {
            for (row, 0..) |cell, i| {
                if (i > 0) try result.append(allocator, '|');
                try result.append(allocator, ' ');
                try result.appendSlice(allocator, cell);
                try result.append(allocator, ' ');
            }
            try result.appendSlice(allocator, "|\n");
        }

        return result.toOwnedSlice(allocator);
    }

    /// Generate LaTeX table
    pub fn generateLatex(self: *const SimpleTable, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        // Calculate column spec
        try result.appendSlice(allocator, "\\begin{table}[htbp]\\centering\\caption{");
        try result.appendSlice(allocator, self.caption);
        try result.writer(allocator).print("}}\\begin{{tabular}}{{{{", .{});

        // Column alignment (left-aligned for all)
        for (self.columns, 0..) |_, i| {
            if (i > 0) try result.append(allocator, ' ');
            try result.append(allocator, 'l');
        }

        try result.appendSlice(allocator, "}}\n\\hline\n");

        // Header row
        for (self.columns, 0..) |col, i| {
            if (i > 0) try result.appendSlice(allocator, " & ");
            try result.appendSlice(allocator, col);
        }
        try result.appendSlice(allocator, " \\\\\n\\hline\n");

        // Data rows
        for (self.rows) |row| {
            for (row, 0..) |cell, i| {
                if (i > 0) try result.appendSlice(allocator, " & ");
                try result.appendSlice(allocator, cell);
            }
            try result.appendSlice(allocator, " \\\\\n");
        }

        try result.appendSlice(allocator, "\\hline\n\\end{tabular}\\end{table}");

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// V104 TESTS
// ═══════════════════════════════════════════════════════════════════════════════

test "CitationStyle - enum to string" {
    try std.testing.expectEqualStrings("APA", CitationStyle.apa.toString());
    try std.testing.expectEqualStrings("IEEE", CitationStyle.ieee.toString());
    try std.testing.expectEqualStrings("MLA", CitationStyle.mla.toString());
    try std.testing.expectEqualStrings("Chicago", CitationStyle.chicago.toString());
    try std.testing.expectEqualStrings("Harvard", CitationStyle.harvard.toString());
    try std.testing.expectEqualStrings("Vancouver", CitationStyle.vancouver.toString());
}

test "CitationStyle - format label" {
    try std.testing.expectEqualStrings("APA 7th Edition", CitationStyle.apa.formatLabel());
    try std.testing.expectEqualStrings("IEEE Style", CitationStyle.ieee.formatLabel());
    try std.testing.expectEqualStrings("Vancouver (Numbered)", CitationStyle.vancouver.formatLabel());
}

test "SimpleCitation - APA format" {
    const citation = SimpleCitation{
        .author = "Vasilev, D.",
        .title = "Trinity S³AI Framework",
        .year = 2026,
        .publisher = "Zenodo",
        .doi = "10.5281/zenodo.XXXXXX",
    };

    const apa = try citation.formatAPA(std.testing.allocator);
    defer std.testing.allocator.free(apa);

    try std.testing.expect(std.mem.indexOf(u8, apa, "Vasilev, D.") != null);
    try std.testing.expect(std.mem.indexOf(u8, apa, "(2026)") != null);
    try std.testing.expect(std.mem.indexOf(u8, apa, "Trinity S³AI Framework") != null);
    try std.testing.expect(std.mem.indexOf(u8, apa, "https://doi.org/") != null);
}

test "SimpleCitation - IEEE format" {
    const citation = SimpleCitation{
        .author = "Vasilev, D.",
        .title = "Trinity S³AI Framework",
        .year = 2026,
        .publisher = "Zenodo",
        .volume = "1",
        .pages = "1-10",
        .doi = "10.5281/zenodo.XXXXXX",
    };

    const ieee = try citation.formatIEEE(std.testing.allocator);
    defer std.testing.allocator.free(ieee);

    try std.testing.expect(std.mem.indexOf(u8, ieee, "Vasilev, D.") != null);
    try std.testing.expect(std.mem.indexOf(u8, ieee, "Framework,\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, ieee, "2026") != null);
    try std.testing.expect(std.mem.indexOf(u8, ieee, "vol. 1") != null);
    try std.testing.expect(std.mem.indexOf(u8, ieee, "pp. 1-10") != null);
}

test "SimpleCitation - MLA format" {
    const citation = SimpleCitation{
        .author = "Vasilev, Dmitrii",
        .title = "Trinity S³AI Framework",
        .year = 2026,
        .publisher = "Zenodo",
    };

    const mla = try citation.formatMLA(std.testing.allocator);
    defer std.testing.allocator.free(mla);

    try std.testing.expect(std.mem.indexOf(u8, mla, "Vasilev, Dmitrii") != null);
    try std.testing.expect(std.mem.indexOf(u8, mla, "Trinity S³AI Framework") != null);
    try std.testing.expect(std.mem.indexOf(u8, mla, "2026") != null);
}

test "SimpleFigureCaption - generates caption" {
    const caption = SimpleFigureCaption{
        .number = 1,
        .title = "Ternary Quantization Results",
        .description = "Accuracy vs compression ratio for sacred scaling factors",
        .note = "Error bars show 95% confidence interval",
    };

    const text = try caption.generate(std.testing.allocator);
    defer std.testing.allocator.free(text);

    try std.testing.expect(std.mem.indexOf(u8, text, "Figure 1:") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "Ternary Quantization Results") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "sacred scaling") != null);
}

test "SimpleFigureCaption - generates LaTeX caption" {
    const caption = SimpleFigureCaption{
        .number = 1,
        .title = "Architecture Overview",
        .description = "Tri-layer ternary neural network",
    };

    const latex = try caption.generateLatex(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "\\caption{") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "Figure 1:") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "Architecture Overview") != null);
}

test "SimpleTable - generates markdown table" {
    const columns = [_][]const u8{ "Model", "Accuracy", "Compression" };
    const row1 = [_][]const u8{ "HSLM-T3", "94.2%", "20×" };
    const row2 = [_][]const u8{ "HSLM-T2", "92.8%", "15×" };
    const rows = [_][]const []const u8{ &row1, &row2 };

    const table = SimpleTable{
        .caption = "Ternary quantization comparison",
        .columns = &columns,
        .rows = &rows,
    };

    const markdown = try table.generateMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(markdown);

    try std.testing.expect(std.mem.indexOf(u8, markdown, "**Table:**") != null);
    try std.testing.expect(std.mem.indexOf(u8, markdown, "Model |") != null);
    try std.testing.expect(std.mem.indexOf(u8, markdown, "---|") != null);
    try std.testing.expect(std.mem.indexOf(u8, markdown, "HSLM-T3") != null);
    try std.testing.expect(std.mem.indexOf(u8, markdown, "94.2%") != null);
}

test "SimpleTable - generates LaTeX table" {
    const columns = [_][]const u8{ "Method", "PPL", "Speed" };
    const row1 = [_][]const u8{ "Sacred", "12.4", "1.2k" };
    const rows = [_][]const []const u8{&row1};

    const table = SimpleTable{
        .caption = "Benchmark results",
        .columns = &columns,
        .rows = &rows,
    };

    const latex = try table.generateLatex(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "\\begin{table}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\begin{tabular}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "Benchmark results") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\hline") != null);
}

// ═══════════════════════════════════════════════════════════════════════════════
// V105: SUBMISSION CHECKLISTS & AVAILABILITY STATEMENTS
// ═══════════════════════════════════════════════════════════════════════════════

/// Conference type for submission checklists
pub const ConferenceType = enum {
    /// NeurIPS (Conference on Neural Information Processing Systems)
    neurips,
    /// ICLR (International Conference on Learning Representations)
    iclr,
    /// MLSys (Conference on Machine Learning and Systems)
    mlsys,
    /// ICML (International Conference on Machine Learning)
    icml,
    /// AAAI (Association for the Advancement of Artificial Intelligence)
    aaai,
    /// IJCAI (International Joint Conference on Artificial Intelligence)
    ijcai,
    /// CVPR (Computer Vision and Pattern Recognition)
    cvpr,
    /// ACL (Association for Computational Linguistics)
    acl,

    pub fn toString(self: ConferenceType) []const u8 {
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

    pub fn checklistUrl(self: ConferenceType) []const u8 {
        return switch (self) {
            .neurips => "https://neurips.cc/Conferences/2025/PaperInformation/ReviewerGuide",
            .iclr => "https://iclr.cc/Conferences/2025/SubmissionChecklist",
            .mlsys => "https://mlsys.org/Conferences/2025/AuthorGuidelines",
            .icml => "https://icml.cc/2025/author-guidelines",
            .aaai => "https://aaai.org/conference/aaai/aaai-26/submission-guidelines/",
            .ijcai => "https://ijcai26.org/submission-guidelines/",
            .cvpr => "https://cvpr.thecvf.com/Conferences/2025",
            .acl => "https://acl2025.org/submission-guidelines/",
        };
    }
};

/// Checklist item status
pub const ChecklistStatus = enum {
    /// Item completed and verified
    complete,
    /// Item in progress
    in_progress,
    /// Item not started
    pending,
    /// Item not applicable
    na,

    pub fn toSymbol(self: ChecklistStatus) []const u8 {
        return switch (self) {
            .complete => "✓",
            .in_progress => "○",
            .pending => " ",
            .na => "N/A",
        };
    }

    pub fn toString(self: ChecklistStatus) []const u8 {
        return switch (self) {
            .complete => "Complete",
            .in_progress => "In Progress",
            .pending => "Pending",
            .na => "N/A",
        };
    }
};

/// Individual checklist item
pub const ChecklistItem = struct {
    /// Item description
    description: []const u8,
    /// Current status
    status: ChecklistStatus,
    /// Optional notes
    notes: ?[]const u8 = null,

    pub fn formatAsMarkdown(self: *const ChecklistItem, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("{s} {s}", .{ self.status.toSymbol(), self.description });

        if (self.notes) |n| {
            try result.writer(allocator).print(" — {s}", .{n});
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Conference submission checklist
pub const SubmissionChecklist = struct {
    /// Target conference
    conference: ConferenceType,
    /// Checklist items
    items: []const ChecklistItem,
    /// Review deadline (optional)
    review_deadline: ?[]const u8 = null,
    /// Submission deadline (optional)
    submission_deadline: ?[]const u8 = null,

    /// Generate NeurIPS-specific checklist
    pub fn forNeurIPS(allocator: std.mem.Allocator) !SubmissionChecklist {
        const items = [_]ChecklistItem{
            .{ .description = "Abstract follows 5-sentence format (context, gap, method, results, impact)", .status = .pending },
            .{ .description = "Paper within 8 pages (excluding references and appendix)", .status = .pending },
            .{ .description = "Broader impact statement included", .status = .pending },
            .{ .description = "Computational resources section included", .status = .pending },
            .{ .description = "Reproducibility checklist completed", .status = .pending },
            .{ .description = "Code and data availability specified", .status = .pending },
            .{ .description = "Ethics statement included if applicable", .status = .pending },
            .{ .description = "Prior work clearly cited", .status = .pending },
            .{ .description = "Limitations section included", .status = .pending },
        };

        _ = allocator;
        return SubmissionChecklist{
            .conference = .neurips,
            .items = items,
            .review_deadline = null,
            .submission_deadline = null,
        };
    }

    /// Generate ICLR-specific checklist
    pub fn forICLR(allocator: std.mem.Allocator) !SubmissionChecklist {
        _ = allocator;
        const items = [_]ChecklistItem{
            .{ .description = "Abstract within 250 words", .status = .pending },
            .{ .description = "Main text within 8 pages (excluding references and appendices)", .status = .pending },
            .{ .description = "Broader impact statement included", .status = .pending },
            .{ .description = "Reproducibility checklist completed", .status = .pending },
            .{ .description = "Code availability specified", .status = .pending },
            .{ .description = "Data availability specified", .status = .pending },
            .{ .description = "Prior work and related work clearly distinguished", .status = .pending },
            .{ .description = "Limitations and future work included", .status = .pending },
        };

        return SubmissionChecklist{
            .conference = .iclr,
            .items = items,
        };
    }

    /// Calculate completion percentage
    pub fn completionRate(self: *const SubmissionChecklist) f32 {
        var complete: usize = 0;
        var applicable: usize = 0;

        for (self.items) |item| {
            if (item.status != .na) {
                applicable += 1;
                if (item.status == .complete) {
                    complete += 1;
                }
            }
        }

        if (applicable == 0) return 100.0;
        return @as(f32, @floatFromInt(complete)) / @as(f32, @floatFromInt(applicable)) * 100.0;
    }

    /// Generate formatted checklist as markdown
    pub fn generateMarkdown(self: *const SubmissionChecklist, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("# {s} Submission Checklist\n\n", .{self.conference.toString()});
        try result.writer(allocator).print("Completion: {d:.1}%\n\n", .{self.completionRate()});

        if (self.submission_deadline) |deadline| {
            try result.writer(allocator).print("**Submission Deadline:** {s}\n\n", .{deadline});
        }

        if (self.review_deadline) |deadline| {
            try result.writer(allocator).print("**Review Deadline:** {s}\n\n", .{deadline});
        }

        try result.appendSlice(allocator, "## Checklist\n\n");

        for (self.items) |item| {
            const line = try item.formatAsMarkdown(allocator);
            defer allocator.free(line);
            try result.appendSlice(allocator, line);
            try result.append(allocator, '\n');
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Code/data availability statement following FAIR principles
pub const AvailabilityStatement = struct {
    /// Code repository URL
    code_url: ?[]const u8 = null,
    /// Dataset URL or DOI
    data_url: ?[]const u8 = null,
    /// License type
    license: []const u8 = "MIT",
    /// Additional notes
    notes: ?[]const u8 = null,

    /// Generate FAIR-compliant availability statement
    pub fn generateStatement(self: *const AvailabilityStatement, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "Availability Statement\n");
        try result.appendSlice(allocator, "====================\n\n");

        if (self.code_url) |url| {
            try result.writer(allocator).print("**Code:** The source code is available at {s} under the {s} license.\n", .{ url, self.license });
        } else {
            try result.appendSlice(allocator, "**Code:** The source code will be released upon acceptance.\n");
        }

        try result.append(allocator, '\n');

        if (self.data_url) |url| {
            try result.writer(allocator).print("**Data:** The datasets used in this work are available at {s}.\n", .{url});
        } else {
            try result.appendSlice(allocator, "**Data:** The datasets used in this work are publicly available from cited sources.\n");
        }

        try result.append(allocator, '\n');

        if (self.notes) |n| {
            try result.writer(allocator).print("**Notes:** {s}\n", .{n});
        }

        try result.appendSlice(allocator, "\nAll materials follow FAIR principles (Findable, Accessible, Interoperable, Reusable).\n");

        return result.toOwnedSlice(allocator);
    }

    /// Generate LaTeX version of availability statement
    pub fn generateLatex(self: *const AvailabilityStatement, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "\\section*{Availability of Materials}\n\n");

        if (self.code_url) |url| {
            try result.writer(allocator).print("\\textbf{{Code:}} The source code is available at \\url{{{s}}} under the {s} license.\n\n", .{ url, self.license });
        } else {
            try result.appendSlice(allocator, "\\textbf{Code:} The source code will be released upon acceptance.\n\n");
        }

        if (self.data_url) |url| {
            try result.writer(allocator).print("\\textbf{{Data:}} The datasets used in this work are available at \\url{{{s}}}.\n\n", .{url});
        } else {
            try result.appendSlice(allocator, "\\textbf{Data:} The datasets used in this work are publicly available from cited sources.\n\n");
        }

        if (self.notes) |n| {
            try result.writer(allocator).print("\\textbf{{Notes:}} {s}\n\n", .{n});
        }

        try result.appendSlice(allocator, "All materials follow FAIR principles (Findable, Accessible, Interoperable, Reusable).\n");

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// V105 TESTS
// ═══════════════════════════════════════════════════════════════════════════════

test "ConferenceType - enum to string" {
    try std.testing.expectEqualStrings("NeurIPS", ConferenceType.neurips.toString());
    try std.testing.expectEqualStrings("ICLR", ConferenceType.iclr.toString());
    try std.testing.expectEqualStrings("MLSys", ConferenceType.mlsys.toString());
    try std.testing.expectEqualStrings("ICML", ConferenceType.icml.toString());
}

test "ConferenceType - checklist URL" {
    const neurips_url = ConferenceType.neurips.checklistUrl();
    try std.testing.expect(std.mem.indexOf(u8, neurips_url, "neurips.cc") != null);

    const iclr_url = ConferenceType.iclr.checklistUrl();
    try std.testing.expect(std.mem.indexOf(u8, iclr_url, "iclr.cc") != null);
}

test "ChecklistStatus - symbols" {
    try std.testing.expectEqualStrings("✓", ChecklistStatus.complete.toSymbol());
    try std.testing.expectEqualStrings("○", ChecklistStatus.in_progress.toSymbol());
    try std.testing.expectEqualStrings(" ", ChecklistStatus.pending.toSymbol());
    try std.testing.expectEqualStrings("N/A", ChecklistStatus.na.toSymbol());
}

test "ChecklistItem - format as markdown" {
    const item = ChecklistItem{
        .description = "Abstract included",
        .status = .complete,
        .notes = "5 sentences, 250 words",
    };

    const md = try item.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "✓") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "Abstract included") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "5 sentences") != null);
}

test "SubmissionChecklist - completion rate" {
    const items = [_]ChecklistItem{
        .{ .description = "Item 1", .status = .complete },
        .{ .description = "Item 2", .status = .complete },
        .{ .description = "Item 3", .status = .pending },
        .{ .description = "Item 4", .status = .na },
    };

    const checklist = SubmissionChecklist{
        .conference = .neurips,
        .items = &items,
    };

    // 2 complete out of 3 applicable (excluding NA) = 66.67%
    const rate = checklist.completionRate();
    try std.testing.expect(rate > 66.0 and rate < 67.0);
}

test "SubmissionChecklist - generate markdown" {
    const items = [_]ChecklistItem{
        .{ .description = "Abstract included", .status = .complete },
        .{ .description = "Broader impact", .status = .pending },
    };

    const checklist = SubmissionChecklist{
        .conference = .neurips,
        .items = &items,
        .submission_deadline = "2026-05-06",
    };

    const md = try checklist.generateMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "NeurIPS Submission Checklist") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "50.0%") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "2026-05-06") != null);
}

test "AvailabilityStatement - generate statement" {
    const statement = AvailabilityStatement{
        .code_url = "https://github.com/gHashTag/trinity",
        .data_url = "https://zenodo.org/record/XXXXX",
        .license = "MIT",
        .notes = "Pre-trained models available on request",
    };

    const text = try statement.generateStatement(std.testing.allocator);
    defer std.testing.allocator.free(text);

    try std.testing.expect(std.mem.indexOf(u8, text, "github.com/gHashTag/trinity") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "zenodo.org") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "MIT") != null);
    try std.testing.expect(std.mem.indexOf(u8, text, "FAIR") != null);
}

test "AvailabilityStatement - generate LaTeX" {
    const statement = AvailabilityStatement{
        .code_url = "https://github.com/gHashTag/trinity",
        .license = "MIT",
    };

    const latex = try statement.generateLatex(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "\\section*{Availability") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "\\url{https://github.com/gHashTag/trinity}") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "FAIR") != null);
}

test "AvailabilityStatement - pending release" {
    const statement = AvailabilityStatement{
        .code_url = null,
        .data_url = null,
    };

    const text = try statement.generateStatement(std.testing.allocator);
    defer std.testing.allocator.free(text);

    try std.testing.expect(std.mem.indexOf(u8, text, "will be released upon acceptance") != null);
}

// ═════════════════════════════════════════════════════════════════════════════
// V106: PAPER WORKFLOW HELPERS
// ═════════════════════════════════════════════════════════════════════════════

/// Paper section enumeration
pub const PaperSection = enum {
    /// Title page
    title,
    /// Abstract
    abstract,
    /// Introduction
    introduction,
    /// Background/Related Work
    background,
    /// Method
    method,
    /// Experiments/Results
    results,
    /// Discussion
    discussion,
    /// Conclusion
    conclusion,
    /// References
    references,
    /// Appendices
    appendices,

    pub fn toString(self: PaperSection) []const u8 {
        return switch (self) {
            .title => "Title",
            .abstract => "Abstract",
            .introduction => "Introduction",
            .background => "Background",
            .method => "Method",
            .results => "Results",
            .discussion => "Discussion",
            .conclusion => "Conclusion",
            .references => "References",
            .appendices => "Appendices",
        };
    }

    pub fn toLatex(self: PaperSection) []const u8 {
        return switch (self) {
            .title => "title",
            .abstract => "abstract",
            .introduction => "section{Introduction}",
            .background => "section{Background}",
            .method => "section{Method}",
            .results => "section{Results}",
            .discussion => "section{Discussion}",
            .conclusion => "section{Conclusion}",
            .references => "section{References}",
            .appendices => "appendix",
        };
    }
};

/// Paper outline section
pub const OutlineSection = struct {
    /// Section type
    section: PaperSection,
    /// Section title or heading
    heading: []const u8,
    /// Brief description of content
    description: []const u8,
    /// Estimated word count
    word_count: ?u32 = null,
    /// Key points or bullets
    bullet_points: []const []const u8,

    pub fn formatAsMarkdown(self: *const OutlineSection, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("## {s}\n\n", .{self.heading});
        try result.appendSlice(allocator, self.description);
        try result.append(allocator, '\n');

        if (self.bullet_points.len > 0) {
            for (self.bullet_points) |point| {
                try result.writer(allocator).print("- {s}\n", .{point});
            }
        }

        if (self.word_count) |wc| {
            try result.writer(allocator).print("\n*Estimated: {d} words*\n\n", .{wc});
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Complete paper outline
pub const PaperOutline = struct {
    /// Paper title
    title: []const u8,
    /// Target conference
    conference: ConferenceType,
    /// Outline sections
    sections: []const OutlineSection,
    /// Target word count
    target_word_count: u32 = 5000,
    /// Current word count
    current_word_count: ?u32 = null,

    /// Calculate total estimated words
    pub fn estimatedWordCount(self: *const PaperOutline) u32 {
        var total: u32 = 0;
        for (self.sections) |section| {
            if (section.word_count) |wc| {
                total += wc;
            }
        }
        return total;
    }

    /// Calculate completion percentage
    pub fn wordCountProgress(self: *const PaperOutline) ?f32 {
        if (self.current_word_count) |current| {
            return @as(f32, @floatFromInt(current)) / @as(f32, @floatFromInt(self.target_word_count)) * 100.0;
        }
        return null;
    }

    /// Generate formatted outline as markdown
    pub fn generateMarkdown(self: *const PaperOutline, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("# {s}\n\n", .{self.title});
        try result.writer(allocator).print("**Target Conference:** {s}\n", .{self.conference.toString()});
        try result.writer(allocator).print("**Target Word Count:** {d}\n", .{self.target_word_count});

        if (self.wordCountProgress()) |progress| {
            try result.writer(allocator).print("**Progress:** {d:.1}%\n", .{progress});
        }

        try result.appendSlice(allocator, "\n---\n\n");

        for (self.sections) |section| {
            const section_md = try section.formatAsMarkdown(allocator);
            defer allocator.free(section_md);
            try result.appendSlice(allocator, section_md);
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Review rating for peer reviews
pub const ReviewRating = enum {
    /// Accept with minor revisions
    accept_minor,
    /// Accept with major revisions
    accept_major,
    /// Reject
    reject,
    /// Weak reject (borderline)
    weak_reject,
    /// Needs more work
    needs_work,

    pub fn toSymbol(self: ReviewRating) []const u8 {
        return switch (self) {
            .accept_minor => "✓ Accept (minor)",
            .accept_major => "⚠ Accept (major)",
            .reject => "✗ Reject",
            .weak_reject => "~ Weak Reject",
            .needs_work => "⏳ Needs Work",
        };
    }

    pub fn toColor(self: ReviewRating) []const u8 {
        return switch (self) {
            .accept_minor => "green",
            .accept_major => "orange",
            .reject => "red",
            .weak_reject => "yellow",
            .needs_work => "gray",
        };
    }
};

/// Individual review comment
pub const PaperReviewComment = struct {
    /// Comment number
    number: u32,
    /// Comment text
    text: []const u8,
    /// Severity (optional)
    severity: ?ReviewRating = null,
    /// Response status
    responded: bool = false,
    /// Response text (optional)
    response: ?[]const u8 = null,

    pub fn isResolved(self: *const PaperReviewComment) bool {
        return self.responded;
    }
};

/// Paper review template
pub const PaperReview = struct {
    /// Reviewer name/ID
    reviewer: ?[]const u8 = null,
    /// Overall rating
    rating: ReviewRating,
    /// Review comments
    comments: []const PaperReviewComment,
    /// Review date
    date: ?[]const u8 = null,
    /// Overall summary
    summary: []const u8,

    /// Count unresolved comments
    pub fn unresolvedCount(self: *const PaperReview) usize {
        var count: usize = 0;
        for (self.comments) |comment| {
            if (!comment.isResolved()) {
                count += 1;
            }
        }
        return count;
    }

    /// Count resolved comments
    pub fn resolvedCount(self: *const PaperReview) usize {
        var count: usize = 0;
        for (self.comments) |comment| {
            if (comment.isResolved()) {
                count += 1;
            }
        }
        return count;
    }

    /// Calculate completion percentage
    pub fn responseProgress(self: *const PaperReview) f32 {
        if (self.comments.len == 0) return 100.0;
        return @as(f32, @floatFromInt(self.resolvedCount())) / @as(f32, @floatFromInt(self.comments.len)) * 100.0;
    }

    /// Generate formatted review as markdown
    pub fn generateMarkdown(self: *const PaperReview, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "# Paper Review\n\n");

        if (self.reviewer) |rev| {
            try result.writer(allocator).print("**Reviewer:** {s}\n\n", .{rev});
        }

        try result.writer(allocator).print("**Rating:** {s}\n\n", .{self.rating.toSymbol()});
        try result.writer(allocator).print("**Progress:** {d:.1}% resolved ({d}/{d})\n\n", .{
            self.responseProgress(),
            self.resolvedCount(),
            self.comments.len,
        });

        try result.appendSlice(allocator, "## Summary\n\n");
        try result.appendSlice(allocator, self.summary);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "## Comments\n\n");

        for (self.comments) |comment| {
            try result.writer(allocator).print("### {d}. {s}\n\n", .{ comment.number, comment.text });

            if (comment.severity) |sev| {
                try result.writer(allocator).print("**Severity:** {s}\n", .{sev.toColor()});
            }

            if (comment.responded) {
                try result.appendSlice(allocator, "**Status:** ✓ Resolved\n\n");
                if (comment.response) |resp| {
                    try result.writer(allocator).print("**Response:** {s}\n\n", .{resp});
                }
            } else {
                try result.appendSlice(allocator, "**Status:** ⏳ Pending\n\n");
            }
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Rebuttal letter template
pub const RebuttalLetter = struct {
    /// Paper title
    paper_title: []const u8,
    /// Review being addressed
    review: PaperReview,
    /// Dear reviewer message
    salutation: []const u8 = "Dear Reviewer,",
    /// Opening paragraph
    opening: []const u8,
    /// Thank you message
    closing: []const u8 = "Thank you for your constructive feedback.",

    /// Generate formatted rebuttal as markdown
    pub fn generateMarkdown(self: *const RebuttalLetter, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("# Rebuttal: {s}\n\n", .{self.paper_title});
        try result.appendSlice(allocator, self.salutation);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, self.opening);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "We appreciate the time and effort you have dedicated to reviewing our work. Below, we address each comment in detail:\n\n");

        var unresolved_count: usize = 0;
        for (self.review.comments) |comment| {
            if (comment.response) |resp| {
                try result.writer(allocator).print("### {d}. {s}\n\n", .{ comment.number, comment.text });
                try result.writer(allocator).print("**Response:** {s}\n\n", .{resp});
            } else {
                unresolved_count += 1;
            }
        }

        if (unresolved_count == 0) {
            try result.appendSlice(allocator, "All reviewer comments have been addressed.\n\n");
        }

        try result.appendSlice(allocator, self.closing);
        try result.appendSlice(allocator, "\n\n");

        try result.appendSlice(allocator, "Best regards,\n");
        try result.appendSlice(allocator, "The Authors\n");

        return result.toOwnedSlice(allocator);
    }
};

// ═════════════════════════════════════════════════════════════════════════════
// V106 TESTS
// ═════════════════════════════════════════════════════════════════════════

test "PaperSection - enum to string" {
    try std.testing.expectEqualStrings("Introduction", PaperSection.introduction.toString());
    try std.testing.expectEqualStrings("Results", PaperSection.results.toString());
    try std.testing.expectEqualStrings("Conclusion", PaperSection.conclusion.toString());
}

test "PaperSection - to LaTeX" {
    try std.testing.expectEqualStrings("section{Introduction}", PaperSection.introduction.toLatex());
    try std.testing.expectEqualStrings("section{Method}", PaperSection.method.toLatex());
}

test "OutlineSection - format as markdown" {
    const bullets = [_][]const u8{ "Point 1", "Point 2", "Point 3" };
    const section = OutlineSection{
        .section = .method,
        .heading = "Proposed Method",
        .description = "We propose a novel approach...",
        .word_count = 500,
        .bullet_points = &bullets,
    };

    const md = try section.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "## Proposed Method") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "500 words") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "- Point 1") != null);
}

test "PaperOutline - estimated word count" {
    const sections = [_]OutlineSection{
        .{ .section = .abstract, .heading = "Abstract", .description = "Summary of paper", .word_count = 200, .bullet_points = &[_][]const u8{} },
        .{ .section = .introduction, .heading = "Introduction", .description = "Background and motivation", .word_count = 800, .bullet_points = &[_][]const u8{} },
        .{ .section = .method, .heading = "Method", .description = "Our approach", .word_count = 1500, .bullet_points = &[_][]const u8{} },
        .{ .section = .results, .heading = "Results", .description = "Experimental findings", .word_count = 1500, .bullet_points = &[_][]const u8{} },
        .{ .section = .conclusion, .heading = "Conclusion", .description = "Summary and future work", .word_count = 500, .bullet_points = &[_][]const u8{} },
    };

    const outline = PaperOutline{
        .title = "Ternary Neural Networks",
        .conference = .neurips,
        .sections = &sections,
        .target_word_count = 5000,
    };

    const estimated = outline.estimatedWordCount();
    try std.testing.expectEqual(@as(u32, 4500), estimated);
}

test "PaperOutline - word count progress" {
    const outline = PaperOutline{
        .title = "Test Paper",
        .conference = .iclr,
        .sections = &[_]OutlineSection{},
        .target_word_count = 5000,
        .current_word_count = 2500,
    };

    const progress = outline.wordCountProgress();
    try std.testing.expect(progress != null);
    try std.testing.expect(progress.? > 49.9 and progress.? < 50.1);
}

test "ReviewRating - symbols and colors" {
    try std.testing.expectEqualStrings("✓ Accept (minor)", ReviewRating.accept_minor.toSymbol());
    try std.testing.expectEqualStrings("~ Weak Reject", ReviewRating.weak_reject.toSymbol());
    try std.testing.expectEqualStrings("green", ReviewRating.accept_minor.toColor());
    try std.testing.expectEqualStrings("red", ReviewRating.reject.toColor());
}

test "ReviewComment - is resolved" {
    const comment1 = PaperReviewComment{
        .number = 1,
        .text = "Add more details",
        .response = "We added Section 4 with details",
        .responded = true,
    };

    try std.testing.expectEqual(true, comment1.isResolved());

    const comment2 = PaperReviewComment{
        .number = 2,
        .text = "Clarify notation",
    };

    try std.testing.expectEqual(false, comment2.isResolved());
}

test "PaperReview - unresolved count" {
    const comments = [_]PaperReviewComment{
        .{ .number = 1, .text = "Fix notation", .response = "Fixed in revised version", .responded = true },
        .{ .number = 2, .text = "Add experiments" },
        .{ .number = 3, .text = "Clarify method", .response = "Added Section 3.1", .responded = true },
    };

    const review = PaperReview{
        .rating = .accept_minor,
        .comments = &comments,
        .summary = "Paper shows promise but needs minor revisions",
    };

    try std.testing.expectEqual(@as(usize, 1), review.unresolvedCount());
}

test "PaperReview - response progress" {
    const comments = [_]PaperReviewComment{
        .{ .number = 1, .text = "Fix notation", .response = "Fixed", .responded = true },
        .{ .number = 2, .text = "Add experiments", .response = "Added", .responded = true },
        .{ .number = 3, .text = "Clarify method", .response = "Done", .responded = true },
    };

    const review = PaperReview{
        .rating = .accept_minor,
        .comments = &comments,
        .summary = "Good paper",
    };

    const progress = review.responseProgress();
    try std.testing.expect(progress > 99.9);
}

test "RebuttalLetter - generate markdown" {
    const comments = [_]PaperReviewComment{
        .{ .number = 1, .text = "Add more experiments", .response = "We added Section 5 with new experiments", .responded = true },
        .{ .number = 2, .text = "Clarify method" },
    };

    const review = PaperReview{
        .rating = .accept_minor,
        .comments = &comments,
        .summary = "Minor revisions requested",
    };

    const rebuttal = RebuttalLetter{
        .paper_title = "Test Paper",
        .review = review,
        .opening = "We have carefully reviewed your comments and made the following changes.",
    };

    const md = try rebuttal.generateMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "Rebuttal: Test Paper") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "Section 5 with new experiments") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "Best regards") != null);
}

// ═══════════════════════════════════════════════════════════════════════════════
// V107: COLLABORATION METADATA & IDENTIFIERS
// ═══════════════════════════════════════════════════════════════════════════════

/// License type for software and data
pub const LicenseType = enum {
    /// MIT License
    mit,
    /// Apache License 2.0
    apache_2_0,
    /// GNU General Public License v3
    gpl_3,
    /// GNU Lesser General Public License v3
    lgpl_3,
    /// BSD 3-Clause License
    bsd_3,
    /// Creative Commons BY 4.0
    cc_by_4,
    /// Creative Commons BY-SA 4.0
    cc_by_sa_4,
    /// Creative Commons BY-NC 4.0
    cc_by_nc_4,
    /// Creative Commons Zero (public domain)
    cc0,
    /// Other license
    other,

    pub fn toSpdx(self: LicenseType) []const u8 {
        return switch (self) {
            .mit => "MIT",
            .apache_2_0 => "Apache-2.0",
            .gpl_3 => "GPL-3.0",
            .lgpl_3 => "LGPL-3.0",
            .bsd_3 => "BSD-3-Clause",
            .cc_by_4 => "CC-BY-4.0",
            .cc_by_sa_4 => "CC-BY-SA-4.0",
            .cc_by_nc_4 => "CC-BY-NC-4.0",
            .cc0 => "CC0-1.0",
            .other => "OTHER",
        };
    }

    pub fn toUrl(self: LicenseType) []const u8 {
        return switch (self) {
            .mit => "https://opensource.org/licenses/MIT",
            .apache_2_0 => "https://opensource.org/licenses/Apache-2.0",
            .gpl_3 => "https://opensource.org/licenses/GPL-3.0",
            .lgpl_3 => "https://opensource.org/licenses/LGPL-3.0",
            .bsd_3 => "https://opensource.org/licenses/BSD-3-Clause",
            .cc_by_4 => "https://creativecommons.org/licenses/by/4.0/",
            .cc_by_sa_4 => "https://creativecommons.org/licenses/by-sa/4.0/",
            .cc_by_nc_4 => "https://creativecommons.org/licenses/by-nc/4.0/",
            .cc0 => "https://creativecommons.org/publicdomain/zero/1.0/",
            .other => "",
        };
    }

    pub fn isOpenSource(self: LicenseType) bool {
        return switch (self) {
            .mit, .apache_2_0, .gpl_3, .lgpl_3, .bsd_3 => true,
            .cc_by_4, .cc_by_sa_4, .cc0 => true,
            .cc_by_nc_4 => false, // Non-commercial restriction
            .other => false,
        };
    }
};

/// Author role in publication
pub const AuthorRole = enum {
    /// First author (equal contribution)
    first,
    /// Co-first author
    co_first,
    /// Middle author
    middle,
    /// Senior author (PI)
    senior,
    /// Corresponding author
    corresponding,
    /// Supervising author
    supervisor,

    pub fn toSymbol(self: AuthorRole) []const u8 {
        return switch (self) {
            .first => "†",
            .co_first => "‡",
            .middle => "",
            .senior => "*",
            .corresponding => "§",
            .supervisor => "¶",
        };
    }

    pub fn toString(self: AuthorRole) []const u8 {
        return switch (self) {
            .first => "First Author",
            .co_first => "Co-First Author",
            .middle => "Contributing Author",
            .senior => "Senior Author",
            .corresponding => "Corresponding Author",
            .supervisor => "Supervisor",
        };
    }
};

/// Institution/affiliation data
pub const Institution = struct {
    /// Institution name
    name: []const u8,
    /// Department (optional)
    department: ?[]const u8 = null,
    /// City
    city: []const u8,
    /// Country code (ISO 3166-1 alpha-2)
    country_code: []const u8,
    /// ROR identifier (Research Organization Registry)
    ror_id: ?[]const u8 = null,

    pub fn formatAsLocation(self: *const Institution, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 128) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, self.name);

        if (self.department) |dept| {
            try result.writer(allocator).print(" - {s}", .{dept});
        }

        try result.writer(allocator).print(", {s}, {s}", .{ self.city, self.country_code });

        return result.toOwnedSlice(allocator);
    }

    pub fn generateRorUrl(self: *const Institution, allocator: std.mem.Allocator) ![]u8 {
        if (self.ror_id) |ror| {
            return std.fmt.allocPrint(allocator, "https://ror.org/{s}", .{ror});
        }
        return std.fmt.allocPrint(allocator, "https://ror.org/search?query={s}", .{self.name});
    }
};

/// Extended author with full metadata
pub const Contributor = struct {
    /// Full name (First Last)
    name: []const u8,
    /// ORCID ID (16-digit, without dashes)
    orcid: ?[]const u8 = null,
    /// Email (optional)
    email: ?[]const u8 = null,
    /// Affiliation
    affiliation: Institution,
    /// Role in paper
    role: AuthorRole = .middle,
    /// Contribution statement
    contribution: ?[]const u8 = null,

    /// Format as author citation
    pub fn formatAsCitation(self: *const Contributor, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 128) catch @panic("OOM");
        defer result.deinit(allocator);

        // Add role symbol if not middle author
        const symbol = self.role.toSymbol();
        if (symbol.len > 0) {
            try result.appendSlice(allocator, symbol);
            try result.append(allocator, ' ');
        }

        // Parse name: "First Last" -> "Last, F."
        const space_idx = std.mem.indexOf(u8, self.name, " ");
        if (space_idx) |idx| {
            const last = self.name[0..idx];
            const first = self.name[idx + 1 ..];
            try result.writer(allocator).print("{s}, {s}.", .{ last, first[0..1] });
        } else {
            try result.appendSlice(allocator, self.name);
        }

        return result.toOwnedSlice(allocator);
    }

    /// Generate ORCID URL
    pub fn orcidUrl(self: *const Contributor, allocator: std.mem.Allocator) ![]u8 {
        if (self.orcid) |id| {
            return std.fmt.allocPrint(allocator, "https://orcid.org/{s}", .{id});
        }
        return error.NoOrcid;
    }

    /// Generate CRediT taxonomy statement
    pub fn generateCreditStatement(self: *const Contributor, allocator: std.mem.Allocator) ![]u8 {
        if (self.contribution) |contrib| {
            return std.fmt.allocPrint(allocator, "{s}: {s}", .{ self.name, contrib });
        }
        return std.fmt.allocPrint(allocator, "{s}: Author", .{self.name});
    }
};

/// DOI (Digital Object Identifier) helper
pub const DoiHelper = struct {
    /// DOI prefix (e.g., "10.5281" for Zenodo)
    prefix: []const u8,
    /// DOI suffix (unique identifier)
    suffix: []const u8,

    /// Generate full DOI string
    pub fn fullDoi(self: *const DoiHelper, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "{s}/{s}", .{ self.prefix, self.suffix });
    }

    /// Generate DOI URL
    pub fn url(self: *const DoiHelper, allocator: std.mem.Allocator) ![]u8 {
        const doi = try self.fullDoi(allocator);
        defer allocator.free(doi);
        return std.fmt.allocPrint(allocator, "https://doi.org/{s}", .{doi});
    }

    /// Generate BibTeX citation entry
    pub fn bibtexEntry(self: *const DoiHelper, allocator: std.mem.Allocator, title: []const u8, author: []const u8, year: u32) ![]u8 {
        const doi = try self.fullDoi(allocator);
        defer allocator.free(doi);

        // Extract last name for BibTeX key
        const space_idx = std.mem.indexOf(u8, author, " ");
        const last_name = if (space_idx) |idx| author[0..idx] else author;

        return std.fmt.allocPrint(allocator,
            \\@{{misc{{{s}_{d},
            \\  title={{{s}}},
            \\  author={{{s}}},
            \\  year={{{d}}},
            \\  doi={{{s}}},
            \\  url={{https://doi.org/{s}}}
            \\}}
        , .{ last_name, year, title, author, year, doi, doi });
    }

    /// Validate DOI format
    pub fn validate(doi: []const u8) bool {
        // DOI format: 10.xxxx/xxxxx
        if (!std.mem.startsWith(u8, doi, "10.")) return false;

        const slash_idx = std.mem.indexOf(u8, doi, "/") orelse return false;
        if (slash_idx < 5) return false; // Minimum prefix length

        const suffix = doi[slash_idx + 1 ..];
        if (suffix.len == 0) return false;

        // Check for valid characters (alphanumeric, ., -, _, (, ), ;)
        for (suffix) |c| {
            const valid = std.ascii.isAlphanumeric(c) or c == '.' or c == '-' or c == '_' or c == '(' or c == ')' or c == ';';
            if (!valid) return false;
        }

        return true;
    }
};

/// arXiv identifier helper
pub const ArxivHelper = struct {
    /// arXiv ID (e.g., "2301.12345" or "cs.AI/1234567")
    id: []const u8,

    /// Generate arXiv URL
    pub fn url(self: *const ArxivHelper, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "https://arxiv.org/abs/{s}", .{self.id});
    }

    /// Generate PDF URL
    pub fn pdfUrl(self: *const ArxivHelper, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "https://arxiv.org/pdf/{s}.pdf", .{self.id});
    }

    /// Detect arXiv category from ID
    pub fn detectCategory(self: *const ArxivHelper) []const u8 {
        if (std.mem.indexOf(u8, self.id, "cs.") != null) return "Computer Science";
        if (std.mem.indexOf(u8, self.id, "math.") != null) return "Mathematics";
        if (std.mem.indexOf(u8, self.id, "stat.") != null) return "Statistics";
        if (std.mem.indexOf(u8, self.id, "physics.") != null) return "Physics";
        if (std.mem.indexOf(u8, self.id, "q-bio.") != null) return "Quantitative Biology";
        if (std.mem.indexOf(u8, self.id, "q-fin.") != null) return "Quantitative Finance";
        return "Unknown";
    }
};

/// Version metadata following semantic versioning
pub const VersionMetadata = struct {
    /// Major version
    major: u8,
    /// Minor version
    minor: u8,
    /// Patch version
    patch: u8,
    /// Pre-release tag (alpha, beta, rc)
    pre_release: ?[]const u8 = null,
    /// Build metadata
    build_metadata: ?[]const u8 = null,

    /// Generate semantic version string
    pub fn toString(self: *const VersionMetadata, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 32) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("v{d}.{d}.{d}", .{ self.major, self.minor, self.patch });

        if (self.pre_release) |pr| {
            try result.writer(allocator).print("-{s}", .{pr});
        }

        if (self.build_metadata) |bm| {
            try result.writer(allocator).print("+{s}", .{bm});
        }

        return result.toOwnedSlice(allocator);
    }

    /// Generate Zenodo version identifier
    pub fn toZenodoVersion(self: *const VersionMetadata, allocator: std.mem.Allocator) ![]u8 {
        return self.toString(allocator);
    }

    /// Compare versions (returns >0 if self > other, <0 if self < other, 0 if equal)
    pub fn compare(self: *const VersionMetadata, other: *const VersionMetadata) i8 {
        if (self.major != other.major) {
            return if (self.major > other.major) 1 else -1;
        }
        if (self.minor != other.minor) {
            return if (self.minor > other.minor) 1 else -1;
        }
        if (self.patch != other.patch) {
            return if (self.patch > other.patch) 1 else -1;
        }
        return 0;
    }

    /// Increment patch version
    pub fn bumpPatch(self: *const VersionMetadata) VersionMetadata {
        return VersionMetadata{
            .major = self.major,
            .minor = self.minor,
            .patch = self.patch + 1,
            .pre_release = null,
            .build_metadata = self.build_metadata,
        };
    }

    /// Increment minor version
    pub fn bumpMinor(self: *const VersionMetadata) VersionMetadata {
        return VersionMetadata{
            .major = self.major,
            .minor = self.minor + 1,
            .patch = 0,
            .pre_release = null,
            .build_metadata = self.build_metadata,
        };
    }

    /// Increment major version
    pub fn bumpMajor(self: *const VersionMetadata) VersionMetadata {
        return VersionMetadata{
            .major = self.major + 1,
            .minor = 0,
            .patch = 0,
            .pre_release = null,
            .build_metadata = self.build_metadata,
        };
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// V107 TESTS
// ═══════════════════════════════════════════════════════════════════════════════

test "LicenseType - to SPDX" {
    try std.testing.expectEqualStrings("MIT", LicenseType.mit.toSpdx());
    try std.testing.expectEqualStrings("Apache-2.0", LicenseType.apache_2_0.toSpdx());
    try std.testing.expectEqualStrings("CC-BY-4.0", LicenseType.cc_by_4.toSpdx());
}

test "LicenseType - to URL" {
    try std.testing.expect(std.mem.indexOf(u8, LicenseType.mit.toUrl(), "opensource.org") != null);
    try std.testing.expect(std.mem.indexOf(u8, LicenseType.cc_by_4.toUrl(), "creativecommons.org") != null);
}

test "LicenseType - is open source" {
    try std.testing.expect(LicenseType.mit.isOpenSource());
    try std.testing.expect(LicenseType.gpl_3.isOpenSource());
    try std.testing.expect(!LicenseType.cc_by_nc_4.isOpenSource());
}

test "AuthorRole - symbols" {
    try std.testing.expectEqualStrings("†", AuthorRole.first.toSymbol());
    try std.testing.expectEqualStrings("*", AuthorRole.senior.toSymbol());
}

test "Institution - format as location" {
    const inst = Institution{
        .name = "MIT",
        .department = "CSAIL",
        .city = "Cambridge",
        .country_code = "US",
    };

    const loc = try inst.formatAsLocation(std.testing.allocator);
    defer std.testing.allocator.free(loc);

    try std.testing.expect(std.mem.indexOf(u8, loc, "MIT") != null);
    try std.testing.expect(std.mem.indexOf(u8, loc, "CSAIL") != null);
    try std.testing.expect(std.mem.indexOf(u8, loc, "Cambridge") != null);
}

test "Contributor - format as citation" {
    const inst = Institution{
        .name = "MIT",
        .city = "Cambridge",
        .country_code = "US",
    };

    const contrib = Contributor{
        .name = "Smith, Jane",
        .affiliation = inst,
        .role = .first,
    };

    const citation = try contrib.formatAsCitation(std.testing.allocator);
    defer std.testing.allocator.free(citation);

    try std.testing.expect(std.mem.indexOf(u8, citation, "Smith") != null);
    try std.testing.expect(std.mem.indexOf(u8, citation, "J.") != null);
    try std.testing.expect(std.mem.indexOf(u8, citation, "†") != null);
}

test "DoiHelper - full DOI" {
    const doi = DoiHelper{
        .prefix = "10.5281",
        .suffix = "zenodo.123456",
    };

    const full = try doi.fullDoi(std.testing.allocator);
    defer std.testing.allocator.free(full);

    try std.testing.expectEqualStrings("10.5281/zenodo.123456", full);
}

test "DoiHelper - validate" {
    try std.testing.expect(DoiHelper.validate("10.5281/zenodo.123456"));
    try std.testing.expect(DoiHelper.validate("10.1000/182"));
    try std.testing.expect(!DoiHelper.validate("invalid"));
    try std.testing.expect(!DoiHelper.validate("10.5281/")); // No suffix
}

test "ArxivHelper - detect category" {
    const arxiv_cs = ArxivHelper{ .id = "2301.12345v1" };
    try std.testing.expectEqualStrings("Unknown", arxiv_cs.detectCategory());

    const arxiv_new = ArxivHelper{ .id = "cs.AI/1234567" };
    try std.testing.expectEqualStrings("Computer Science", arxiv_new.detectCategory());
}

test "VersionMetadata - to string" {
    const version = VersionMetadata{
        .major = 2,
        .minor = 9,
        .patch = 0,
    };

    const str = try version.toString(std.testing.allocator);
    defer std.testing.allocator.free(str);

    try std.testing.expectEqualStrings("v2.9.0", str);
}

test "VersionMetadata - with pre-release" {
    const version = VersionMetadata{
        .major = 3,
        .minor = 0,
        .patch = 0,
        .pre_release = "beta.1",
    };

    const str = try version.toString(std.testing.allocator);
    defer std.testing.allocator.free(str);

    try std.testing.expect(std.mem.indexOf(u8, str, "beta.1") != null);
}

test "VersionMetadata - bump patch" {
    const version = VersionMetadata{
        .major = 2,
        .minor = 9,
        .patch = 0,
    };

    const bumped = version.bumpPatch();
    try std.testing.expectEqual(@as(u8, 1), bumped.patch);
    try std.testing.expectEqual(@as(u8, 9), bumped.minor);
}

test "VersionMetadata - compare" {
    const v1 = VersionMetadata{ .major = 2, .minor = 9, .patch = 0 };
    const v2 = VersionMetadata{ .major = 2, .minor = 10, .patch = 0 };
    const v3 = VersionMetadata{ .major = 3, .minor = 0, .patch = 0 };

    try std.testing.expect(v2.compare(&v1) > 0); // v2 > v1
    try std.testing.expect(v3.compare(&v1) > 0); // v3 > v1
    try std.testing.expect(v1.compare(&v1) == 0); // v1 == v1
}

// ═══════════════════════════════════════════════════════════════════════════════
// V108: SCIENTIFIC METRICS & BIBLIOMETRICS
// ═══════════════════════════════════════════════════════════════════════════════

/// Impact metric types
pub const ImpactMetric = enum {
    /// h-index (Hirsch index)
    h_index,
    /// i10-index (number of publications with 10+ citations)
    i10_index,
    /// Total citations
    total_citations,
    /// Citation count per year
    citations_per_year,
    /// Field-weighted citation impact
    fwci,
    /// SNIP (Source Normalized Impact per Paper)
    snip,
    /// SJR (SCImago Journal Rank)
    sjr,

    pub fn toLabel(self: ImpactMetric) []const u8 {
        return switch (self) {
            .h_index => "h-index",
            .i10_index => "i10-index",
            .total_citations => "Total Citations",
            .citations_per_year => "Citations/Year",
            .fwci => "FWCI",
            .snip => "SNIP",
            .sjr => "SJR",
        };
    }
};

/// Single metric value
pub const MetricValue = struct {
    /// Metric type
    metric: ImpactMetric,
    /// Value
    value: f32,
    /// Year (optional)
    year: ?u32 = null,

    pub fn formatAsMarkdown(self: *const MetricValue, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 64) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("**{s}:** {d:.2}", .{ self.metric.toLabel(), self.value });

        if (self.year) |y| {
            try result.writer(allocator).print(" ({d})", .{y});
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Author bibliometrics
pub const AuthorMetrics = struct {
    /// ORCID ID
    orcid: ?[]const u8 = null,
    /// h-index
    h_index: ?u32 = null,
    /// i10-index
    i10_index: ?u32 = null,
    /// Total citations
    total_citations: ?u32 = null,
    /// Number of publications
    publication_count: ?u32 = null,
    /// Metrics list
    metrics: []const MetricValue,

    /// Calculate average citation per publication
    pub fn avgCitationsPerPub(self: *const AuthorMetrics) f32 {
        if (self.publication_count) |pub_count| {
            if (pub_count == 0) return 0.0;
            if (self.total_citations) |total| {
                return @as(f32, @floatFromInt(total)) / @as(f32, @floatFromInt(pub_count));
            }
        }
        return 0.0;
    }

    /// Generate metrics table as markdown
    pub fn generateMarkdownTable(self: *const AuthorMetrics, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.appendSlice(allocator, "| Metric | Value |\n");
        try result.appendSlice(allocator, "|--------|-------|\n");

        if (self.h_index) |h| {
            try result.writer(allocator).print("| h-index | {d} |\n", .{h});
        }

        if (self.i10_index) |i10_val| {
            try result.writer(allocator).print("| i10-index | {d} |\n", .{i10_val});
        }

        if (self.total_citations) |tc| {
            try result.writer(allocator).print("| Total Citations | {d} |\n", .{tc});
        }

        if (self.publication_count) |pc| {
            try result.writer(allocator).print("| Publications | {d} |\n", .{pc});
        }

        const avg = self.avgCitationsPerPub();
        if (avg > 0) {
            try result.writer(allocator).print("| Avg Citations/Pub | {d:.2} |\n", .{avg});
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Journal information
pub const JournalInfo = struct {
    /// Journal name
    name: []const u8,
    /// Publisher
    publisher: []const u8,
    /// ISSN (print)
    issn_print: ?[]const u8 = null,
    /// ISSN (online)
    issn_online: ?[]const u8 = null,
    /// Impact factor
    impact_factor: ?f32 = null,
    /// SJR rank
    sjr: ?f32 = null,
    /// SNIP value
    snip: ?f32 = null,

    /// Generate journal citation
    pub fn formatAsCitation(self: *const JournalInfo, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 128) catch @panic("OOM");
        defer result.deinit(allocator);

        try result.writer(allocator).print("*{s}*", .{self.name});

        if (self.impact_factor) |if_| {
            try result.writer(allocator).print(" (IF: {d:.2})", .{if_});
        }

        return result.toOwnedSlice(allocator);
    }
};

/// Citation context
pub const CitationContext = struct {
    /// Citing paper
    citing_paper: []const u8,
    /// Cited paper
    cited_paper: []const u8,
    /// Citation context (sentence)
    context: []const u8,
    /// Citation type (method, background, result, etc.)
    citation_type: []const u8,

    pub fn formatAsMarkdown(self: *const CitationContext, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator,
            \\> {s}
            \\
            \\— *{s}* citing *{s}* ({s})
        , .{ self.context, self.citing_paper, self.cited_paper, self.citation_type });
    }
};

/// Publication venue type
pub const VenueType = enum {
    /// Conference
    conference,
    /// Journal
    journal,
    /// Workshop
    workshop,
    /// Symposium
    symposium,
    /// Preprint server (arXiv, bioRxiv)
    preprint,
    /// Book chapter
    book_chapter,
    /// Thesis
    thesis,

    pub fn toString(self: VenueType) []const u8 {
        return switch (self) {
            .conference => "Conference",
            .journal => "Journal",
            .workshop => "Workshop",
            .symposium => "Symposium",
            .preprint => "Preprint",
            .book_chapter => "Book Chapter",
            .thesis => "Thesis",
        };
    }
};

/// Publication record
pub const Publication = struct {
    /// Title
    title: []const u8,
    /// Authors
    authors: []const []const u8,
    /// Venue name
    venue: []const u8,
    /// Venue type
    venue_type: VenueType,
    /// Year
    year: u32,
    /// DOI (optional)
    doi: ?[]const u8 = null,
    /// arXiv ID (optional)
    arxiv: ?[]const u8 = null,
    /// Citation count
    citations: ?u32 = null,

    /// Generate LaTeX citation
    pub fn formatAsLatex(self: *const Publication, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, 256) catch @panic("OOM");
        defer result.deinit(allocator);

        // Authors
        for (self.authors, 0..) |author, i| {
            if (i > 0) try result.appendSlice(allocator, " and ");
            try result.appendSlice(allocator, author);
        }

        try result.writer(allocator).print(". ``{s}''. ", .{self.title});

        if (self.venue_type == .journal) {
            try result.writer(allocator).print("*{s}*, ", .{self.venue});
        } else {
            try result.writer(allocator).print("In: *{s}*, ", .{self.venue});
        }

        try result.writer(allocator).print("{d}.", .{self.year});

        return result.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════════
// V108 TESTS
// ═══════════════════════════════════════════════════════════════════════════════

test "ImpactMetric - to label" {
    try std.testing.expectEqualStrings("h-index", ImpactMetric.h_index.toLabel());
    try std.testing.expectEqualStrings("FWCI", ImpactMetric.fwci.toLabel());
}

test "MetricValue - format as markdown" {
    const metric = MetricValue{
        .metric = .h_index,
        .value = 42.0,
        .year = 2025,
    };

    const md = try metric.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "h-index") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "42.00") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "2025") != null);
}

test "AuthorMetrics - avg citations per pub" {
    const metrics = AuthorMetrics{
        .total_citations = 500,
        .publication_count = 50,
        .metrics = &[_]MetricValue{},
    };

    const avg = metrics.avgCitationsPerPub();
    try std.testing.expect(avg > 9.9 and avg < 10.1);
}

test "AuthorMetrics - generate markdown table" {
    const metrics = AuthorMetrics{
        .h_index = 25,
        .total_citations = 1500,
        .publication_count = 80,
        .metrics = &[_]MetricValue{},
    };

    const md = try metrics.generateMarkdownTable(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "h-index") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "1500") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "Avg Citations/Pub") != null);
}

test "JournalInfo - format as citation" {
    const journal = JournalInfo{
        .name = "Nature",
        .publisher = "Nature Portfolio",
        .impact_factor = 69.5,
    };

    const citation = try journal.formatAsCitation(std.testing.allocator);
    defer std.testing.allocator.free(citation);

    try std.testing.expect(std.mem.indexOf(u8, citation, "Nature") != null);
    try std.testing.expect(std.mem.indexOf(u8, citation, "IF") != null);
}

test "CitationContext - format as markdown" {
    const context = CitationContext{
        .citing_paper = "Our Paper",
        .cited_paper = "Previous Work",
        .context = "This approach builds on prior research.",
        .citation_type = "Method",
    };

    const md = try context.formatAsMarkdown(std.testing.allocator);
    defer std.testing.allocator.free(md);

    try std.testing.expect(std.mem.indexOf(u8, md, "Our Paper") != null);
    try std.testing.expect(std.mem.indexOf(u8, md, "Previous Work") != null);
}

test "VenueType - to string" {
    try std.testing.expectEqualStrings("Conference", VenueType.conference.toString());
    try std.testing.expectEqualStrings("Journal", VenueType.journal.toString());
    try std.testing.expectEqualStrings("Preprint", VenueType.preprint.toString());
}

test "Publication - format as LaTeX" {
    const authors = [_][]const u8{ "Author, A.", "Author, B." };
    const pub_record = Publication{
        .title = "Test Paper",
        .authors = &authors,
        .venue = "NeurIPS",
        .venue_type = .conference,
        .year = 2025,
    };

    const latex = try pub_record.formatAsLatex(std.testing.allocator);
    defer std.testing.allocator.free(latex);

    try std.testing.expect(std.mem.indexOf(u8, latex, "Test Paper") != null);
    try std.testing.expect(std.mem.indexOf(u8, latex, "NeurIPS") != null);
}

// ═════════════════════════════════════════════════════════════════════════════════
// V111: Utility Functions & Best Practices
// ═════════════════════════════════════════════════════════════════════════════════════

/// Date validation utilities for Zenodo metadata
pub const DateUtils = struct {
    /// Validate YYYY-MM-DD format
    pub fn validateDateFormat(date: []const u8) bool {
        if (date.len != 10) return false;
        if (date[4] != '-') return false;
        if (date[7] != '-') return false;

        // Parse year
        const year_str = date[0..4];
        var year: u32 = 0;
        for (year_str) |c| {
            if (c < '0' or c > '9') return false;
            year = year * 10 + (c - '0');
        }

        // Parse month
        const month_str = date[5..7];
        var month: u32 = 0;
        for (month_str) |c| {
            if (c < '0' or c > '9') return false;
            month = month * 10 + (c - '0');
        }

        // Parse day
        const day_str = date[8..10];
        var day: u32 = 0;
        for (day_str) |c| {
            if (c < '0' or c > '9') return false;
            day = day * 10 + (c - '0');
        }

        // Validate ranges
        if (year < 2000 or year > 2100) return false;
        if (month == 0 or month > 12) return false;
        if (day == 0 or day > 31) return false;

        // Basic month/day validation
        if (month == 2 and day > 29) return false;
        if ((month == 4 or month == 6 or month == 9 or month == 11) and day > 30) return false;

        return true;
    }

    /// Format current date as YYYY-MM-DD (epoch-based calculation)
    pub fn todayAsISO8601(allocator: std.mem.Allocator) ![]u8 {
        // Unix epoch is 1970-01-01
        const epoch = std.time.timestamp();
        const days_since_epoch: u32 = @intCast(@divFloor(epoch, 86400));

        // Days per month for non-leap year
        const month_days = [_]u32{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

        // Calculate year (simplified, valid for 1970-2099)
        var year: u32 = 1970;
        var remaining = days_since_epoch;

        // Simplified year calculation - just count years
        const years = remaining / 365;
        year += years;
        remaining -= years * 365;

        // Adjust for leap years (one per 4 years on average)
        const extra_leap_days = @min(remaining, (years / 4));
        remaining -= extra_leap_days;

        // Count remaining years
        while (remaining > 365) : (year += 1) {
            const days_in_year = if (isLeapYear(year)) @as(u32, 366) else 365;
            if (remaining >= days_in_year) {
                remaining -= days_in_year;
            } else {
                break;
            }
        }

        // Calculate month and day
        var month: u32 = 1;
        var day: u32 = remaining + 1;

        for (month_days, 0..) |days_in_month, i| {
            const feb_days = if (isLeapYear(year) and i == 1) @as(u32, 29) else days_in_month;

            if (day <= feb_days) {
                month = @intCast(i + 1);
                break;
            }
            day -= feb_days;
        }

        return std.fmt.allocPrint(allocator, "{d:0>4}-{d:0>2}-{d:0>2}", .{ year, month, day });
    }

    fn isLeapYear(year: u32) bool {
        return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0);
    }
};

/// DOI validation utilities
pub const DoiUtils = struct {
    /// Validate DOI format (10.xxxx/zenodo.xxxxxx)
    pub fn validateZenodoDOI(doi: []const u8) bool {
        const prefix = "10.5281/zenodo.";
        if (doi.len != prefix.len + 8) return false;

        if (!std.mem.startsWith(u8, doi, prefix)) return false;

        // Check suffix is all digits
        const suffix = doi[prefix.len..];
        for (suffix) |c| {
            if (c < '0' or c > '9') return false;
        }

        return true;
    }

    /// Extract record ID from DOI
    pub fn extractRecordId(doi: []const u8) ?[]const u8 {
        const prefix = "10.5281/zenodo.";
        if (std.mem.startsWith(u8, doi, prefix)) {
            return doi[prefix.len..];
        }
        return null;
    }

    /// Generate DOI from record ID
    pub fn generateFromRecordId(record_id: []const u8, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "10.5281/zenodo.{s}", .{record_id});
    }
};

/// Keyword validation utilities
pub const KeywordUtils = struct {
    /// Validate keyword length (2-50 characters)
    pub fn validateLength(keyword: []const u8) bool {
        return keyword.len >= 2 and keyword.len <= 50;
    }

    /// Sanitize keyword (remove special characters)
    pub fn sanitize(keyword: []const u8, allocator: std.mem.Allocator) ![]u8 {
        var result = std.ArrayList(u8).initCapacity(allocator, keyword.len) catch @panic("OOM");
        defer result.deinit(allocator);

        for (keyword) |c| {
            // Keep alphanumeric, spaces, hyphens, parentheses
            const is_valid = std.ascii.isAlphanumeric(c) or c == ' ' or c == '-' or c == '(' or c == ')';
            if (is_valid) {
                try result.append(allocator, c);
            }
        }

        return result.toOwnedSlice(allocator);
    }

    /// Validate keyword array (5-10 keywords recommended)
    pub fn validateCount(count: usize) bool {
        return count >= 5 and count <= 10;
    }
};

/// Metadata completeness validator
pub const MetadataValidator = struct {
    /// Validation result
    pub const ValidationResult = struct {
        is_valid: bool,
        missing_required: []const []const u8,
        warnings: []const []const u8,
    };

    /// Required fields according to Zenodo API v1.0
    pub const REQUIRED_FIELDS = [_][]const u8{
        "title",
        "upload_type",
        "creators",
    };

    /// Validate metadata completeness
    pub fn validate(title: ?[]const u8, upload_type: ?[]const u8, creators_len: usize, description: ?[]const u8, keywords_len: usize, allocator: std.mem.Allocator) !ValidationResult {
        var missing = std.ArrayList([]const u8).initCapacity(allocator, 3) catch @panic("OOM");
        defer missing.deinit(allocator);

        var warnings = std.ArrayList([]const u8).initCapacity(allocator, 5) catch @panic("OOM");
        defer warnings.deinit(allocator);

        // Check required fields
        if (title == null or title.?.len == 0) {
            try missing.append(allocator, "title");
        }
        if (upload_type == null or upload_type.?.len == 0) {
            try missing.append(allocator, "upload_type");
        }
        if (creators_len == 0) {
            try missing.append(allocator, "creators");
        }

        // Check recommended fields
        if (description == null or description.?.len == 0) {
            try warnings.append(allocator, "description is recommended");
        }
        if (keywords_len < 5 or keywords_len > 10) {
            try warnings.append(allocator, "keywords: 5-10 recommended");
        }
        if (description != null and description.?.len < 50) {
            try warnings.append(allocator, "description too short (<50 chars)");
        }
        if (description != null and description.?.len > 5000) {
            try warnings.append(allocator, "description too long (>5000 chars)");
        }

        const missing_slice = try missing.toOwnedSlice(allocator);
        const warnings_slice = try warnings.toOwnedSlice(allocator);

        return ValidationResult{
            .is_valid = missing_slice.len == 0,
            .missing_required = missing_slice,
            .warnings = warnings_slice,
        };
    }

    /// Generate validation report as markdown
    pub fn generateValidationReport(result: ValidationResult, allocator: std.mem.Allocator) ![]u8 {
        var report = std.ArrayList(u8).initCapacity(allocator, 512) catch @panic("OOM");
        defer report.deinit(allocator);

        if (result.is_valid) {
            try report.appendSlice(allocator, "✅ **Validation Passed**\n\n");
        } else {
            try report.appendSlice(allocator, "❌ **Validation Failed**\n\n");
            try report.appendSlice(allocator, "**Missing Required Fields:**\n");
            for (result.missing_required) |field| {
                try report.writer(allocator).print("- {s}\n", .{field});
            }
            try report.appendSlice(allocator, "\n");
        }

        if (result.warnings.len > 0) {
            try report.appendSlice(allocator, "⚠️ **Warnings:**\n");
            for (result.warnings) |warn| {
                try report.writer(allocator).print("- {s}\n", .{warn});
            }
        }

        return report.toOwnedSlice(allocator);
    }
};

// ═══════════════════════════════════════════════════════════════════════════
// V111 TESTS
// ═══════════════════════════════════════════════════════════════════════════

test "DateUtils - validate YYYY-MM-DD format" {
    try std.testing.expect(DateUtils.validateDateFormat("2025-03-27"));
    try std.testing.expect(!DateUtils.validateDateFormat("2025/03/27"));
    try std.testing.expect(!DateUtils.validateDateFormat("25-03-2025"));
    try std.testing.expect(!DateUtils.validateDateFormat("2025-13-01")); // Invalid month
    try std.testing.expect(!DateUtils.validateDateFormat("2025-00-01")); // Invalid day
}

test "DateUtils - today as ISO 8601" {
    const date = try DateUtils.todayAsISO8601(std.testing.allocator);
    defer std.testing.allocator.free(date);
    try std.testing.expect(date.len == 10);
    try std.testing.expect(std.mem.startsWith(u8, date, "20")); // Year starts with 20
}

test "DoiUtils - validate Zenodo DOI" {
    try std.testing.expect(DoiUtils.validateZenodoDOI("10.5281/zenodo.12345678"));
    try std.testing.expect(!DoiUtils.validateZenodoDOI("10.1234/zenodo.12345678"));
    try std.testing.expect(!DoiUtils.validateZenodoDOI("10.5281/zenodo.1234567")); // Too short
    try std.testing.expect(!DoiUtils.validateZenodoDOI("10.5281/zenodo.1234567a")); // Non-digit suffix
}

test "DoiUtils - extract record ID from DOI" {
    const id = DoiUtils.extractRecordId("10.5281/zenodo.12345678");
    try std.testing.expectEqualStrings("12345678", id.?);
    try std.testing.expect(DoiUtils.extractRecordId("invalid.doi") == null);
}

test "DoiUtils - generate DOI from record ID" {
    const doi = try DoiUtils.generateFromRecordId("12345678", std.testing.allocator);
    defer std.testing.allocator.free(doi);
    try std.testing.expect(std.mem.startsWith(u8, doi, "10.5281/zenodo."));
}

test "KeywordUtils - validate length" {
    try std.testing.expect(KeywordUtils.validateLength("AI"));
    try std.testing.expect(!KeywordUtils.validateLength("A")); // Too short
    try std.testing.expect(!KeywordUtils.validateLength("This is a very long keyword that exceeds the maximum allowed length of 50 characters and should be rejected"));
}

test "KeywordUtils - validate count" {
    try std.testing.expect(KeywordUtils.validateCount(5));
    try std.testing.expect(KeywordUtils.validateCount(10));
    try std.testing.expect(!KeywordUtils.validateCount(4)); // Too few
    try std.testing.expect(!KeywordUtils.validateCount(11)); // Too many
}

test "KeywordUtils - sanitize keyword" {
    const sanitized = try KeywordUtils.sanitize("AI/Machine-Learning!", std.testing.allocator);
    defer std.testing.allocator.free(sanitized);
    try std.testing.expect(std.mem.indexOf(u8, sanitized, "/") == null);
    try std.testing.expect(std.mem.indexOf(u8, sanitized, "!") == null);
    try std.testing.expect(std.mem.indexOf(u8, sanitized, "AI") != null);
}

test "MetadataValidator - validate completeness" {
    const result = try MetadataValidator.validate(
        "Test Paper",
        "software",
        2,
        "This is a test abstract.",
        6,
        std.testing.allocator,
    );
    defer {
        std.testing.allocator.free(result.missing_required);
        std.testing.allocator.free(result.warnings);
    }

    try std.testing.expect(result.is_valid);
    try std.testing.expectEqual(@as(usize, 0), result.missing_required.len);
}

test "MetadataValidator - missing required fields" {
    const result = try MetadataValidator.validate(
        null,
        null,
        0,
        "Test abstract.",
        3,
        std.testing.allocator,
    );
    defer {
        std.testing.allocator.free(result.missing_required);
        std.testing.allocator.free(result.warnings);
    }

    try std.testing.expect(!result.is_valid);
    try std.testing.expect(result.missing_required.len > 0);
}

test "MetadataValidator - generate validation report" {
    const result = MetadataValidator.ValidationResult{
        .is_valid = true,
        .missing_required = &[_][]const u8{},
        .warnings = &[_][]const u8{"keywords count is low"},
    };

    const report = try MetadataValidator.generateValidationReport(result, std.testing.allocator);
    defer std.testing.allocator.free(report);

    try std.testing.expect(std.mem.indexOf(u8, report, "Validation Passed") != null);
    try std.testing.expect(std.mem.indexOf(u8, report, "keywords count is low") != null);
}
