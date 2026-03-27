# Zenodo V113: Usage Examples & Best Practices

**Date:** 2026-03-27
**Cycle Duration:** 10 minutes (autonomous)
**Status:** Documentation Complete

---

## Executive Summary

V113 provides comprehensive usage examples for Zenodo templates, demonstrating how to use the V100-V111 structures for scientific publication workflows.

---

## Usage Examples

### Example 1: Complete Metadata Creation

```zig
const std = @import("std");
const zenodo_templates = @import("zenodo_templates");

pub fn createTrinityMetadata(allocator: std.mem.Allocator) !void {
    // Create paper metadata
    const metadata = zenodo_templates.PaperMetadata{
        .title = "Trinity S³AI: Ternary Sparse Sacred Scalable AI",
        .authors = &[_][]const u8{ "Vasilev, Dmitrii" },
        .abstract = "We present a framework for...",
        .keywords = &[_][]const u8{ "ternary", "sparse", "AI" },
        .year = 2026,
        .doi = "10.5281/zenodo.19227879",
        .conference = .neurips,
    };

    // Generate abstract
    const abstract = try metadata.formatAsAbstract(allocator);
    defer allocator.free(abstract);

    // Validate
    const validation = try metadata.validateAbstractLength();
    _ = validation;
}
```

### Example 2: Date Validation

```zig
pub fn validatePublicationDate() bool {
    return zenodo_templates.DateUtils.validateDateFormat("2026-03-27");
}

pub fn getCurrentDate(allocator: std.mem.Allocator) ![]u8 {
    return zenodo_templates.DateUtils.todayAsISO8601(allocator);
}
```

### Example 3: DOI Operations

```zig
pub fn validateAndExtractDOI() !void {
    const doi = "10.5281/zenodo.19227879";

    // Validate
    if (zenodo_templates.DoiUtils.validateZenodoDOI(doi)) {
        // Extract record ID
        const id = zenodo_templates.DoiUtils.extractRecordId(doi);
        _ = id; // "19227879"
    }
}
```

### Example 4: Keyword Management

```zig
pub fn prepareKeywords(allocator: std.mem.Allocator) !void {
    const raw = "AI/Machine-Learning!";

    // Sanitize
    const clean = try zenodo_templates.KeywordUtils.sanitize(raw, allocator);
    defer allocator.free(clean);

    // Validate count (5-10 recommended)
    const count = 7;
    const is_valid = zenodo_templates.KeywordUtils.validateCount(count);
    _ = is_valid;
}
```

### Example 5: Metadata Validation

```zig
pub fn validateSubmission(allocator: std.mem.Allocator) !void {
    const result = try zenodo_templates.MetadataValidator.validate(
        "Paper Title",
        "software",
        2,  // authors count
        "Abstract text here...",
        6,  // keywords count
        allocator
    );
    defer {
        allocator.free(result.missing_required);
        allocator.free(result.warnings);
    }

    if (result.is_valid) {
        const report = try zenodo_templates.MetadataValidator.generateValidationReport(result, allocator);
        defer allocator.free(report);
        _ = report;
    }
}
```

### Example 6: Bundle Type Operations

```zig
pub fn getBundleInfo(allocator: std.mem.Allocator) ![]u8 {
    const bundle = zenodo_templates.BundleType.ternary_nn;

    return std.fmt.allocPrint(allocator,
        \\Name: {s}
        \\Display: {s}
        \\DOI: {s}
    , .{
        bundle.fileName(),
        bundle.displayName(),
        bundle.doi(),
    });
}
```

---

## Best Practices

### 1. Always validate dates before submission
```zig
if (!DateUtils.validateDateFormat(publication_date)) {
    return error.InvalidDateFormat;
}
```

### 2. Sanitize user input for keywords
```zig
const clean = try KeywordUtils.sanitize(user_input, allocator);
```

### 3. Use keyword count validation (5-10 recommended)
```zig
if (!KeywordUtils.validateCount(keywords.len)) {
    // Warn user about recommended count
}
```

### 4. Validate metadata before submission
```zig
const result = try MetadataValidator.validate(...);
if (!result.is_valid) {
    // Handle missing required fields
}
```

### 5. Use DOI utilities for Zenodo-specific operations
```zig
if (DoiUtils.validateZenodoDOI(doi)) {
    const id = DoiUtils.extractRecordId(doi);
    // Use record ID
}
```

---

## Common Patterns

### Creating a Complete Submission

```zig
pub fn createSubmission(allocator: std.mem.Allocator) !void {
    // 1. Prepare metadata
    const metadata = createMetadata();

    // 2. Validate
    const validation = try MetadataValidator.validate(...);

    // 3. Generate JSON
    const json = try metadata.toZenodoJson(allocator);
    defer allocator.free(json);

    // 4. Submit to Zenodo (via API)
}
```

### Multi-Venue Citation Formatting

```zig
pub fn formatForNeurIPS(allocator: std.mem.Allocator, paper: PaperMetadata) ![]u8 {
    // Use V103 AbstractGenerator for NeurIPS format
    return try AbstractGenerator{
        .context = "problem context",
        .method = "our method",
        .results = "key results",
        .impact = "broader impact",
    }.generate(allocator);
}
```

---

## Files Modified (Proposed)

```
src/tri/zenodo_templates.zig   +150 LOC (usage examples + 5 tests)
docs/research/ZENODO_V113_DOCUMENTATION.md  (this file)
```

---

## Commits

```
docs(zenodo): V113 - Usage Examples & Best Practices (#435)

- Provided complete metadata creation example
- Provided date validation and DOI operation examples
- Provided keyword and metadata validation examples
- Provided bundle type operations example
- Documented best practices and common patterns

φ² + 1/φ² = 3 | TRINITY
```

---

**V113 - Usage Examples & Best Practices**

10-minute autonomous cycle completed. Documentation complete with usage examples.

**φ² + 1/φ² = 3 | TRINITY**
