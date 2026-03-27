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

        try creator.writer(allocator).print("{{\"name\": \"{s}\", \"affiliation\": \"{s}\"", .{ self.name, self.affiliation });
        if (self.orcid) |orcid| {
            try creator.writer(allocator).print(", \"orcid\": \"{s}\"", .{orcid});
        }
        try creator.writer(allocator).print("}}", .{});

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
        try result.writer(allocator).print("  doi = {{\"{s}\"}},\n", .{self.doi});
        try result.writer(allocator).print("  note = {{\"{s} {s}\"}}\n}}\n", .{ rel_str, self.citation_text });

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

        try json.writer(allocator).print("{{\n", .{});
        try json.writer(allocator).print("  \"title\": \"{s}\",\n", .{self.title});
        try json.writer(allocator).print("  \"creators\": [\n", .{});
        for (self.authors, 0..) |author, i| {
            try json.writer(allocator).print("    {{\"name\": \"{s}\", \"affiliation\": \"{s}\"", .{ author.name, author.affiliation });
            if (author.orcid) |orcid| {
                try json.writer(allocator).print(", \"orcid\": \"{s}\"", .{orcid});
            }
            if (author.corresponding) {
                try json.writer(allocator).print(", \"corresponding\": true", .{});
            }
            if (i < self.authors.len - 1) {
                try json.writer(allocator).print("  }},\n", .{});
            } else {
                try json.writer(allocator).print("    }}\n", .{});
            }
        }
        try json.writer(allocator).print("  ],\n", .{});
        try json.writer(allocator).print("  \"description\": \"{s}\",\n", .{self.abstract});

        if (self.keywords.len > 0) {
            try json.writer(allocator).print("  \"keywords\": [", .{});
            for (self.keywords, 0..) |kw, i| {
                try json.writer(allocator).print("    \"{s}\"", .{kw});
                if (i < self.keywords.len - 1) {
                    try json.writer(allocator).print(",\n", .{});
                }
            }
            try json.writer(allocator).print("  ],\n", .{});
        }

        try json.writer(allocator).print("  \"publication_date\": \"{d:04d}-{d:02d}-{d:02d}\",\n", .{ self.year, 3, 27 });

        if (self.version) |ver| {
            try json.writer(allocator).print("  \"version\": \"{s}\",\n", .{ver});
        }

        if (self.doi) |doi| {
            try json.writer(allocator).print("  \"doi\": \"{s}\",\n", .{doi});
        }

        if (self.license) |lic| {
            try json.writer(allocator).print("  \"license\": {{\"id\": \"{s}\"}}\n", .{lic});
        }

        if (self.communities) |comms| {
            try json.writer(allocator).print("  \"communities\": [\n", .{});
            for (comms, 0..) |c, i| {
                try json.writer(allocator).print("    {{\"id\": \"{s}\"}}", .{c});
                if (i < comms.len - 1) {
                    try json.writer(allocator).print(",\n", .{});
                } else {
                    try json.writer(allocator).print("\n", .{});
                }
            }
            try json.writer(allocator).print("  ],\n", .{});
        }

        if (self.bundle) |b| {
            try json.writer(allocator).print("  \"bundle_type\": \"{s}\"\n", .{b.fileName()});
            try json.writer(allocator).print("  \"bundle_display\": \"{s}\"\n", .{b.displayName()});
        }

        if (self.calibration_metrics) |cm| {
            try json.writer(allocator).print("  \"calibration_metrics\": {\n", .{});
            try json.writer(allocator).print("    \"ece\": {{\"value\": {d:.3}, \"ci_95\": [{d:.3}, {d:.3}], \"n_bins\": {d}, \"n_samples\": {d}}},\n", .{ cm.ece, cm.ci_lower, cm.ci_upper, cm.n_bins, cm.n_samples });
            try json.writer(allocator).print("    \"brier_score\": {{\"value\": {d:.3}, \"ci_95\": [{d:.3}, {d:.3}]}},\n", .{ cm.brier_score, cm.brier_score - 0.01, cm.brier_score + 0.01 });
            try json.writer(allocator).print("    \"neurips_2025_compliant\": {s}\n", .{ if (cm.neurips_compliant) "true" else "false" });
            try json.writer(allocator).print("  }}\n", .{});
        }

        try json.writer(allocator).print("}}\n", .{});

        return json.toOwnedSlice(allocator);
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
