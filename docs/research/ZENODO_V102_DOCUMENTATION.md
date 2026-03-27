# Zenodo V102: API Integration Structures (Best Practices)

**Date:** 2026-03-27
**Cycle Duration:** 10 minutes (autonomous)
**Status:** Complete

---

## Executive Summary

V102 implemented Zenodo API integration structures based on official Zenodo REST API v1.0 documentation research. The focus was on adding missing API client structures, rate limiting, funding/grant references, and related identifiers for complete Zenodo metadata compliance.

**Research Source:** https://developers.zenodo.org/ (Zenodo REST API v1.0)

**Key Changes:**

### zenodo_templates.zig (+380 LOC)
- **OAuthClient**: OAuth 2.0 authentication client with scope management
- **GrantReference**: Funding/grant references with DOI-prefixed IDs (Crossref Funder Registry)
- **RelatedIdentifierType**: 15 identifier types (doi, arxiv, pmid, isbn, issn, url, ark, etc.)
- **RelationType**: 22 relationship types (cites, is-supplement-to, continues, etc.)
- **RelatedIdentifier**: Full structure for linking related works
- **CommunitySubmission**: Community-specific submissions with review tracking
- **RateLimiter**: API rate limiting based on Zenodo limits (60/min guest, 100/min auth, 5000/min OAI-PMH)

---

## Structures Implemented

### OAuthClient

```zig
pub const OAuthClient = struct {
    client_id: []const u8,
    client_secret: []const u8,
    access_token: ?[]const u8 = null,
    expires_at: ?u64 = null,
    scopes: OAuthScopes,

    pub const OAuthScopes = packed struct(u8) {
        deposit_write: bool = false,
        deposit_actions: bool = false,
        deposit_read: bool = false,
        user_read: bool = false,
        _reserved: u4 = 0,
    };

    pub fn init(client_id: []const u8, client_secret: []const u8, scopes: OAuthScopes) OAuthClient
    pub fn getAuthorizationHeader(self, allocator) ![]u8
    pub fn isTokenValid(self) bool
    pub fn formatAsMarkdown(self, allocator) ![]u8
};
```

**Zenodo OAuth Scopes:**
- `deposit:write` — Create and edit deposits
- `deposit:actions` — Publish/discard deposits
- `deposit:read` — Read deposit metadata
- `user:read` — Read user profile

### GrantReference

```zig
pub const GrantReference = struct {
    /// Grant identifier (DOI format: 10.13039/* for Crossref, 10.5281/* for Zenodo)
    id: []const u8,
    /// Grant name/award number
    award_title: []const u8,
    /// Funder name
    funder: []const u8,
    /// Funder DOI (optional)
    funder_doi: ?[]const u8 = null,

    pub fn formatAsZenodoJson(self, allocator) ![]u8
};
```

**Example Grant IDs:**
- `10.13039/501100000780` — European Research Council (Crossref)
- `10.5281/zenodo.XXXXXX` — Zenodo grant

### RelatedIdentifierType

```zig
pub const RelatedIdentifierType = enum {
    doi, arxiv, pmid, isbn, issn, url, ark, bibcode,
    eprint, handle, lccn, lsid, purl, urn, w3id,

    pub fn fromString(s: []const u8) ?RelatedIdentifierType
    pub fn toString(self) []const u8
};
```

### RelationType

```zig
pub const RelationType = enum {
    is_cited_by, cites,
    is_supplement_to, is_supplemented_by,
    is_continued_by, continues,
    is_described_by, describes,
    has_metadata, is_metadata_for,
    is_new_version_of, is_previous_version_of,
    is_part_of, has_part,
    is_referenced_by, references,
    is_documented_by, documents,
    is_compiled_by, compiles,
    is_variant_form_of, is_original_form_of,

    pub fn toString(self) []const u8
};
```

### RelatedIdentifier

```zig
pub const RelatedIdentifier = struct {
    identifier: []const u8,
    relation_type: RelationType,
    scheme: RelatedIdentifierType,

    pub fn formatAsZenodoJson(self, allocator) ![]u8
};
```

### CommunitySubmission

```zig
pub const CommunitySubmission = struct {
    community_id: []const u8,
    status: SubmissionStatus,
    review_deadline: ?[]const u8 = null,

    pub const SubmissionStatus = enum {
        pending, accepted, rejected, withdrawn,

        pub fn toString(self) []const u8
        pub fn fromString(s: []const u8) ?SubmissionStatus
    };

    pub fn formatAsZenodoJson(self, allocator) ![]u8
};
```

### RateLimiter

```zig
pub const RateLimiter = struct {
    timestamps: std.ArrayList(i64),
    max_requests: u32,
    window_size: u32 = 60,

    pub const AuthLevel = enum {
        guest,       // 60 requests/minute
        authenticated, // 100 requests/minute
        oai_pmh,    // 5000 requests/minute
    };

    pub fn init(allocator, max_requests: u32, window_size: u32) !RateLimiter
    pub fn forAuthLevel(allocator, level: AuthLevel) !RateLimiter
    pub fn deinit(self, allocator) void
    pub fn canRequest(self) bool
    pub fn recordRequest(self, allocator) !void
    pub fn remainingRequests(self) u32
    pub fn waitTime(self) u32
};
```

**Zenodo API Rate Limits (from official docs):**
- **Guest**: 60 requests/minute
- **Authenticated**: 100 requests/minute
- **OAI-PMH**: 5000 requests/minute (harvest endpoint only)

---

## Tests Added (12 new tests)

| Test | Description |
|------|-------------|
| OAuthClient - initialization and scopes | Verifies OAuth client setup |
| OAuthClient - scopes string representation | Tests scope formatting |
| GrantReference - Zenodo JSON format | Validates grant JSON output |
| RelatedIdentifierType - enum conversion | Tests type string mapping |
| RelationType - enum conversion | Tests relation string mapping |
| RelatedIdentifier - Zenodo JSON format | Validates related work JSON |
| CommunitySubmission - Zenodo JSON format | Tests community JSON output |
| SubmissionStatus - enum conversion | Tests status string mapping |
| RateLimiter - guest rate limiting (60/min) | Verifies guest limits |
| RateLimiter - authenticated rate limiting (100/min) | Verifies auth limits |
| RateLimiter - OAI-PMH rate limiting (5000/min) | Verifies OAI-PMH limits |
| RateLimiter - AuthLevel max requests | Tests auth level limits |

**Total: 27/27 tests passing ✓**

---

## Zenodo API v1.0 Research Findings

### Key Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/deposit/depositions` | POST | Create new deposit |
| `/api/deposit/depositions/:id` | GET | Read deposit metadata |
| `/api/deposit/depositions/:id` | PUT | Update deposit metadata |
| `/api/deposit/depositions/:id/actions/publish` | POST | Publish deposit |
| `/api/records/:id` | GET | Get published record |
| `/api/files/:id` | POST | Upload files (new API, 50GB limit) |

### Metadata Requirements

**Required Fields:**
- `title` — Record title
- `upload_type` — Resource type (publication, poster, dataset, etc.)
- `creators` — Array of {name, affiliation, orcid}

**Optional Fields:**
- `description` — Abstract (500-1000 words recommended)
- `keywords` — Array of keywords (5-10 recommended)
- `publication_date` — YYYY-MM-DD format
- `related_identifiers` — Array of related works
- `grants` — Array of grant references
- `communities` — Array of community submissions

### OAuth 2.0 Flow

1. **Authorization Code:**
   - Redirect to: `https://zenodo.org/oauth/authorize`
   - Parameters: `client_id`, `redirect_uri`, `response_type=code`, `scope`

2. **Token Exchange:**
   - POST to: `https://zenodo.org/oauth/token`
   - Parameters: `client_id`, `client_secret`, `code`, `grant_type=authorization_code`

3. **Use Token:**
   - Header: `Authorization: Bearer <access_token>`

---

## Files Modified

```
src/tri/zenodo_templates.zig   +380 LOC (7 new structures + 12 tests)
docs/research/ZENODO_V102_DOCUMENTATION.md  (new)
```

---

## CLI Commands (Future Work)

The following CLI commands could be added to `tri_zenodo.zig` in future versions:

```bash
tri zenodo oauth-init          # Initialize OAuth client
tri zenodo rate-limit          # Check current rate limit status
tri zenodo grant-add           # Add grant reference to bundle
tri zenodo related-add         # Add related identifier
tri zenodo community-submit    # Submit to community
```

---

## Commits

```
feat(zenodo): V102 - API integration structures (OAuth, RateLimiter, RelatedIdentifiers)

- Implemented OAuthClient for Zenodo API authentication
- Implemented GrantReference for funding/grant acknowledgment
- Implemented RelatedIdentifierType (15 types: doi, arxiv, pmid, etc.)
- Implemented RelationType (22 relationship types)
- Implemented RelatedIdentifier for linking related works
- Implemented CommunitySubmission for community submissions
- Implemented RateLimiter (60/min guest, 100/min auth, 5000/min OAI-PMH)
- Added 12 new tests (27/27 passing)
- Based on Zenodo REST API v1.0 official documentation

φ² + 1/φ² = 3 | TRINITY
```

---

**V102 - API Integration Structures (Best Practices)**

10-minute autonomous cycle completed successfully. Build passing, all tests passing.

**φ² + 1/φ² = 3 | TRINITY**
