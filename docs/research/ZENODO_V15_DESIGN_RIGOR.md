# Zenodo V15: Scientific Rigor & Peer Review

**Date**: 2026-03-27
**Status**: 📋 Design Document

---

## Overview

V15 focuses on scientific rigor and peer review integration for Trinity's Zenodo publication infrastructure. This document outlines the architecture for adding statistically rigorous publication tools.

---

## Phase 1: Scientific Rigor Module

### Statistical Structures

```zig
/// P-value thresholds for statistical significance
pub const PThreshold = enum {
    very_strict: f64 = 0.001,    // p < 0.001 (***)
    strict: f64 = 0.01,             // p < 0.01 (**)
    moderate: f64 = 0.05,           // p < 0.05 (*)
    lenient: f64 = 0.10,            // p < 0.10 (†)
};

/// Cohen's d effect size interpretation
pub const EffectSize = enum {
    negligible: f64 = 0.2,
    small: f64 = 0.5,
    medium: f64 = 0.8,
    large: f64 = 1.2,
    very_large: f64 = 2.0,
};

/// Confidence interval calculation method
pub const CIMethod = enum {
    bootstrap,        // Non-parametric bootstrap
    bayesian,         // Bayesian credible interval
    analytical,       // Closed-form (t-distribution)
};

/// Statistical test result with full rigor
pub const StatisticalResult = struct {
    metric: []const u8,
    value: f64,
    std_err: ?f64 = null,
    ci_95: ?[]const f64 = null,
    ci_99: ?[]const f64 = null,
    p_value: ?f64 = null,
    n: u32,
    test_name: []const u8,
    test_type: []const u8,
    effect_size: ?EffectSize = null,
    is_significant: bool = false,
};
```

---

## Phase 2: DOI Manager

### Version Management

```zig
/// DOI record with automatic versioning
pub const DOIRecord = struct {
    concept: []const u8,
    version: u32,
    doi: []const u8,
    zenoid_id: u32,
    published_date: i64,
    citation_count: u32,
    metadata: ?[]const u8 = null,
};

/// DOI Manager with Zenodo integration
pub const DOIManager = struct {
    base_url: []const u8 = "https://doi.org/",
    zenodo_api: []const u8 = "https://zenodo.org/api/",
    records: std.StringHashMap([]const u8, DOIRecord),

    pub fn generateDOI(self: *DOIManager, allocator: std.mem.Allocator, concept: []const u8, version: u32) !DOIRecord {
        const doi = try std.fmt.allocPrint(allocator, "10.5281/zenodo.{d}", .{version});
        return .{
            .doi = doi,
            .zenoid_id = 0,
            .published_date = std.time.timestamp(),
        };
    },
};
```

---

## Phase 3: Peer Review Integration

### Review Management

```zig
/// Review action with emoji indicators
pub const ReviewAction = enum {
    accepted:           = "✅",
    partially_accepted: = "🟡",
    rejected:            = "❌",
    deferred:           = "⏭️",
    clarified:          = "💡",
    added_experiment:   = "🧪",
};

/// Reviewer comment with structured response
pub const ReviewerComment = struct {
    reviewer: []const u8,
    comment_number: u32,
    comment_text: []const u8,
    response: []const u8,
    action: ReviewAction,
    location: ?[]const u8 = null,
    references: ?[]const []const u8 = null,
};
```

---

## CLI Commands

```bash
tri zenodo stats         Generate statistical results table
tri zenodo ci            Generate confidence intervals
tri zenodo doi            Generate DOI with versioning
tri zenodo review         Generate peer review response
tri zenodo rigor        Scientific rigor checker
```

---

## Implementation Order

1. ✅ Phase 1: Add toEmoji to SignificanceLevel (V14→V15)
2. ⏳ Phase 2: DOI Manager (separate module)
3. ⏳ Phase 3: Peer Review (separate module)

---

## Testing Strategy

Each structure requires:
- `formatAsLaTeX` → NeurIPS/ICLR format
- `formatAsMarkdown` → GitHub/README format
- Unit test → validates output format
- Integration test → CLI command

---

**φ² + 1/φ² = 3 | TRINITY**
