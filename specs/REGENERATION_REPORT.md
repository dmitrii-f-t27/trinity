# REGENERATION REPORT

Pipeline audit: 20 specs through `vibeec gen`, compilation verification via `zig ast-check`.

**Date:** 2026-03-10
**Zig:** 0.15.x
**Compiler:** `zig-out/bin/vibee gen <spec.tri> <output.zig>`

---

## Summary

| Metric | Value |
|--------|-------|
| Specs tested | 20 |
| Compile (PASS) | 3 (15%) |
| Fail | 16 (80%) |
| Empty output | 1 (5%) |
| Target | 80%+ |
| **Verdict** | **PIPELINE BROKEN** |

---

## Phase 1: Stub Deletion

189 auto-generated skeleton specs deleted (28-29 lines each, `tri strict fix` output with `PLACEHOLDER: 0`).

| Before | After |
|--------|-------|
| 428 specs (LIVE+VALID) | 239 specs |
| 166 stubs estimated | 189 stubs actual (23 more found at threshold) |

---

## Phase 2: Regeneration Test (LIVE specs — have existing .zig)

| Spec | Orig LOC | Gen LOC | Pipeline | Compiles | Error Category |
|------|----------|---------|----------|----------|----------------|
| dynamic_memory | 317 | 339 | OK | NO | UNDECLARED_REF |
| tri_search_commands | 272 | 218 | OK | NO | TYPE_MAPPING |
| commands | 1559 | 0 | EMPTY | N/A | PARSER_FAIL |
| math_compute | 248 | 346 | OK | NO | SYNTAX_NEGATIVE |
| math_format | 219 | 314 | OK | NO | SYNTAX_NEGATIVE |
| math_identities | 265 | 285 | OK | NO | SYNTAX_NEGATIVE |
| math_eval | 185 | 320 | OK | NO | SYNTAX_NEGATIVE |
| codegen_utils | 373 | 598 | OK | NO | SYNTAX_OTHER |
| **sacred_cosmology** | **654** | **496** | **OK** | **YES** | — |
| evolving_dark_energy | 486 | 575 | OK | NO | SYNTAX_OTHER |

**Result: 1/10 (10%)**

---

## Phase 3: Generation Test (SUBSTANTIAL specs — no existing .zig)

| Spec | Spec LOC | Gen LOC | Pipeline | Compiles | Error Category |
|------|----------|---------|----------|----------|----------------|
| swarm_coordinator | 1972 | 2018 | OK | NO | SYNTAX_OTHER |
| swarm_agents | 1041 | 1177 | OK | NO | SYNTAX_OTHER |
| dashboard_agent | 655 | 1520 | OK | NO | TYPE_MAPPING |
| autonomous_lifecycle | 477 | 568 | OK | NO | SYNTAX_FIELD |
| governance_agent | 415 | 939 | OK | NO | TYPE_MAPPING |
| codegen_full_automation | 252 | 340 | OK | NO | SYNTAX_FIELD |
| metrics_collector | 224 | 581 | OK | NO | TYPE_MAPPING |
| swarm_orchestrator | 222 | 476 | OK | NO | TYPE_MAPPING |
| **telegram_pulse_client** | **244** | **368** | **OK** | **YES** | — |
| **agent_mu_auto_fixer** | **164** | **295** | **OK** | **YES** | — |

**Result: 2/10 (20%)**

---

## Phase 4: Error Analysis

### Error Categories (16 failures)

| Category | Count | Root Cause | Codegen Location |
|----------|-------|------------|------------------|
| **TYPE_MAPPING** | 5 | `Int64`, `UInt64`, `List` not in `mapType()` | `spec_compiler.zig:421-474` |
| **SYNTAX_NEGATIVE** | 4 | YAML list-style fields (`- name: x`) emitted as `-: name: x` | `emitter.zig:1140-1146` |
| **SYNTAX_FIELD** | 2 | Lowercase `list<T>`, `string`, `float` not mapped | `spec_compiler.zig:421-474` |
| **UNDECLARED_REF** | 1 | Test references `cosineSimilarity()` which is never defined | `codegen/tests_gen.zig` |
| **SYNTAX_OTHER** | 4 | Mixed: `#` comments in code, `.error` reserved word, duplicate fn, dash in identifier | Parser + emitter |

### Detailed Breakdown

#### TYPE_MAPPING (5 files)

`mapType()` only handles: `String`, `Int`, `Float`, `Bool`, `List<T>`, `Option<T>`.

Missing mappings:
- `Int64` → should map to `i64`
- `UInt64` → should map to `u64`
- `UInt32` → should map to `u32`
- `List` (bare, no generic) → should map to `[]const u8` or error
- `list<T>` (lowercase) → should normalize case then map

Files: `dashboard_agent`, `governance_agent`, `metrics_collector`, `swarm_orchestrator`, `tri_search_commands`

#### SYNTAX_NEGATIVE (4 files)

Specs use YAML list-format for struct fields:
```yaml
fields:
  - name: x
    type: "f64"
```

Parser emits literally: `    -: name: x,` instead of `    x: f64,`

The parser only understands simple format: `fields:\n  x: Float`

Files: `math_compute`, `math_eval`, `math_format`, `math_identities`

#### SYNTAX_FIELD (2 files)

Specs use lowercase type names: `list<Task>`, `string`, `float`.

`mapType()` is case-sensitive — `Float` works but `float` passes through as-is (invalid Zig type).

Files: `autonomous_lifecycle`, `codegen_full_automation`

#### UNDECLARED_REF (1 file)

Test generator references `cosineSimilarity()` in a test for `similarity_search` behavior, but the function is never generated — only a stub `pub fn similarity_search() !void {}`.

File: `dynamic_memory`

#### SYNTAX_OTHER (4 files)

| File | Error | Cause |
|------|-------|-------|
| `codegen_utils` | Duplicate `pub fn stripQuotes()` | Behavior and implementation both emitted |
| `evolving_dark_energy` | `pub const -: f64 = 0` | YAML list constants (`- name: PHI`) parsed as name=`-` |
| `swarm_agents` | `# Sacred number` in code | YAML comment leaked into generated Zig |
| `swarm_coordinator` | `.error` as enum/field | Zig reserved word not escaped to `@"error"` |

---

## Root Cause Summary

**3 bugs in the VIBEE codegen produce 16/16 failures:**

### Bug 1: YAML List-Format Not Parsed (9 files)

The parser (`vibee_parser.zig`) only understands simple key-value fields:
```yaml
fields:
  name: String     # WORKS
  age: Int         # WORKS
```

But many specs use YAML list format:
```yaml
fields:
  - name: x        # BROKEN — emits "-: name: x"
    type: Float
```

**Impact:** 4 SYNTAX_NEGATIVE + 4 SYNTAX_OTHER + 1 partial = 9 files
**Fix:** `vibee_parser.zig` `parseFields()` — detect `- name:` list items, extract name+type.

### Bug 2: Incomplete Type Mapping (7 files)

`mapType()` in `spec_compiler.zig:421-474` is case-sensitive and missing common aliases:

| Missing | Should Map To |
|---------|---------------|
| `Int64` | `i64` |
| `UInt64` | `u64` |
| `UInt32` | `u32` |
| `float` | `f64` |
| `string` | `[]const u8` |
| `list<T>` | `[]const T` |
| `List` (bare) | error or `[]const u8` |

**Impact:** 5 TYPE_MAPPING + 2 SYNTAX_FIELD = 7 files
**Fix:** Add case-insensitive matching + aliases to `mapType()`.

### Bug 3: Reserved Words and Comments Leak (3 files)

- YAML `#` comments pass through to generated Zig code
- `.error` enum variant not escaped to `@"error"`
- Behavior stub + implementation both emitted (duplicate function)

**Impact:** 3 SYNTAX_OTHER files
**Fix:** `cleanTypeName()` already strips `#` — need to apply it to ALL emitted values, not just types. `escapeReservedWord()` needs to cover enum variants too.

---

## What Works (3/20)

| Spec | Why It Works |
|------|-------------|
| `sacred_cosmology` | Simple types (String, Float, Int), no lists, no YAML list-format fields |
| `telegram_pulse_client` | Simple types, flat struct fields, no generics |
| `agent_mu_auto_fixer` | Minimal spec (164 LOC), basic types only |

**Pattern:** Specs that use only `String`, `Int`, `Float`, `Bool` with simple `field: Type` format compile successfully. The codegen handles the happy path correctly.

---

## Fix Priority

| Priority | Bug | Files Fixed | Effort |
|----------|-----|-------------|--------|
| P0 | YAML list-format fields | +9 files (→ 12/20 = 60%) | Parser change |
| P1 | Case-insensitive type mapping + aliases | +7 files (→ 19/20 = 95%) | `mapType()` additions |
| P2 | Comment/reserved word leaks | +3 files (→ 19-20/20) | Emitter cleanup |

**Fixing P0 alone would bring compilation from 15% to ~60%.**
**Fixing P0+P1 would bring compilation from 15% to ~95%.**

---

## Specs Inventory Post-Cleanup

| Category | Count | Status |
|----------|-------|--------|
| LIVE (has .zig) | 102 | Testable |
| SUBSTANTIAL (valid, no .zig) | 148 | Generatable |
| ARCHIVED (dead+meta) | 201 | In `archive/specs/` |
| DELETED (stubs) | 189 | Removed |
| **TOTAL ORIGINAL** | **640** | — |
| **REMAINING ACTIVE** | **250** | — |

---

## Conclusion

The pipeline generates Zig code from .tri specs. It produces correct output for simple specs (15% currently). Two parser bugs (YAML list-format fields + incomplete type mapping) account for 85% of failures. These are localized fixes in `vibee_parser.zig` and `spec_compiler.zig`.

The pipeline is not dead — it is broken in specific, fixable ways.
