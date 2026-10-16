#!/usr/bin/env node
// t27f-spec-view.mjs -- one real .t27, the vendored compiler, a read-only view. Nothing else.
//
// The minimal independent slice of the Spec Explorer (dmitrii-f-t27/trinity#1): a spec goes
// through the same WebAssembly compiler the /specs page loads (public/t27/t27_compiler.wasm,
// the ABI of src/lib/t27Compiler.ts), and comes out as result.json plus a static view.html
// whose lines link to the compiler's own positions. No network, no Queen, no GitHub, no model.
//
// This is NOT the whole T27F and does not replace SpecExplorer.tsx: it draws none of
// SpecCodeView/SpecGraphics, because those need the full Vite build. It is the evidence that
// the pipeline underneath them runs on its own.
//
// Every decision comes from specs/t27f/spec_view.t27, read through the compiler's AST:
// the WASM pin, the required exports, the ordered verdict rules and what each one decides,
// the test states. This file holds only the predicates that read the compiler's JSON,
// because the compiler's JS backend does not lower fn bodies (measured; see the spec). The
// table and the predicates are checked against each other on every run.
//
// Nothing is parsed with a regular expression and nothing is reimplemented: the compiler
// driver, constsOf, literalValue, verdictOf and compilerErrors are agents-from-specs.mjs's,
// the assert evaluator is viewport-from-spec.mjs's.
//
//   node scripts/t27f-spec-view.mjs <spec.t27> [--wasm <file>] [--out <dir>] [--focus <line>]
//   node scripts/t27f-spec-view.mjs --compare <a.wasm> <b.wasm> <dir-of-specs> [--require-equal]
//   node scripts/t27f-spec-view.mjs --survey <dir-of-specs>
//
// Exit code: 0 compile verdict PASS, 1 FAIL, 2 UNKNOWN, 3 usage. The test verdict is printed
// beside it and never changes the exit code -- a type-checked spec is not a tested one.

import { createHash } from 'node:crypto'
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs'
import { basename, dirname, join, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { compilerErrors, decodeBytes, literalValue, loadCompiler, verdictOf } from './agents-from-specs.mjs'
import { evalExpr } from './viewport-from-spec.mjs'

export const SITE = resolve(dirname(fileURLToPath(import.meta.url)), '..')
export const POLICY_SPEC = 'specs/t27f/spec_view.t27'
/** The compiler that reads the policy: the one in this tree. A --wasm under test never reads its own rules. */
export const TREE_WASM = 'public/t27/t27_compiler.wasm'
export const SCHEMA = 1

const sha256 = (bytes) => createHash('sha256').update(bytes).digest('hex')

// ---------------------------------------------------------------------------
// The compiler, as bytes.
// ---------------------------------------------------------------------------

/**
 * What a WASM file is before anything trusts it. Never throws: a missing, empty or broken
 * file is a state the verdict rules decide about, not an exception that skips them.
 */
export async function openCompiler(bytes, path = '(bytes)') {
  const state = { path, loaded: false, bytes: bytes ? bytes.length : 0, sha256: bytes ? sha256(bytes) : null, exports: [], analyze: null, error: null }
  if (!bytes) return { ...state, error: 'file not found' }
  if (bytes.length === 0) return { ...state, error: 'file is empty' }
  let mod
  try {
    mod = await WebAssembly.compile(bytes)
  } catch (e) {
    return { ...state, error: `not a WebAssembly module: ${e.message}` }
  }
  state.exports = WebAssembly.Module.exports(mod).map((x) => x.name).sort()
  const abi = ['memory', 't27_alloc', 't27_free', 't27_analyze']
  if (abi.every((n) => state.exports.includes(n))) {
    try {
      state.analyze = await loadCompiler(bytes)
    } catch (e) {
      return { ...state, error: `instantiate failed: ${e.message}` }
    }
  }
  return { ...state, loaded: true }
}

export function readBytes(path) {
  return existsSync(path) && statSync(path).isFile() ? readFileSync(path) : null
}

// ---------------------------------------------------------------------------
// The policy: specs/t27f/spec_view.t27, through the compiler.
// ---------------------------------------------------------------------------

export class PolicyError extends Error {}

/** Every const of a module the shared decoder can read; the rest are left out, never guessed. */
export function readableConsts(analysis) {
  const env = {}
  for (const d of (analysis?.ast?.children ?? []).filter((n) => n.kind === 'ConstDecl')) {
    const expr = d.children?.[0]
    if (!expr) continue
    try { env[d.name] = literalValue(expr, d.name) } catch { /* hex, calls, structs: not evaluated */ }
  }
  return env
}

const isObj = (x) => x !== null && typeof x === 'object' && !Array.isArray(x)
const isCount = (x) => Number.isInteger(x) && x >= 0

/**
 * Whether an answer has the compiler's shape at all, for this input. Each condition is one
 * the real compiler meets on every spec measured; an answer that misses one is not read.
 */
function malformed(a, expectBytes) {
  if (!isObj(a)) return 'not an object'
  if (!isCount(a.sourceLines)) return 'sourceLines is not a whole number'
  if (expectBytes !== undefined && a.sourceBytes !== expectBytes) return `sourceBytes ${a.sourceBytes} is not the input's ${expectBytes}`
  if (!Array.isArray(a.tokens)) return 'tokens is not a list'
  const bad = a.tokens.find((t) => !isObj(t) || typeof t.kind !== 'string' || typeof t.lexeme !== 'string' || !Number.isInteger(t.line) || t.line < 1 || t.line > a.sourceLines || !Number.isInteger(t.col) || t.col < 1)
  if (bad !== undefined) return `token ${JSON.stringify(bad)} has no valid kind, lexeme, line or column`
  if (a.ast !== undefined && !(isObj(a.ast) && a.ast.kind === 'Module' && Array.isArray(a.ast.children) && a.ast.children.every((n) => isObj(n) && typeof n.kind === 'string'))) return 'ast is not a Module with a list of nodes'
  if (a.typecheck !== undefined && !isObj(a.typecheck)) return 'typecheck is not an object'
  return null
}

/** The predicates. One per rule name the policy may list; the policy decides order and outcome. */
export const PREDICATES = {
  compiler_absent: (c) => !c.compiler.loaded,
  compiler_unpinned: (c) => c.compiler.sha256 !== c.policy.WASM_SHA256 || c.compiler.bytes !== c.policy.WASM_BYTES,
  exports_missing: (c) => c.policy.REQUIRED_EXPORTS.some((n) => !c.compiler.exports.includes(n)) || !c.compiler.analyze,
  analysis_unreadable: (c) => malformed(c.analysis(), c.expectBytes) !== null,
  not_parsed: (c) => { const a = c.analysis(); return !a?.ast || Boolean(a.astError) },
  typecheck_unknown: (c) => typeof c.analysis()?.typecheck?.ok !== 'boolean',
  typecheck_contradicts: (c) => {
    const tc = c.analysis()?.typecheck ?? {}
    if (tc.errorCount !== undefined && !isCount(tc.errorCount)) return true
    if (tc.errors !== undefined && !Array.isArray(tc.errors)) return true
    const said = (tc.errorCount ?? 0) > 0 || (tc.errors?.length ?? 0) > 0
    return tc.ok === true ? said || Boolean(tc.fatal) : !said && !tc.fatal
  },
  typecheck_errors: (c) => c.analysis()?.typecheck?.ok !== true,
  declarations_discarded: (c) => verdictOf(c.analysis()).discarded > 0,
  empty_module: (c) => !Array.isArray(c.analysis()?.ast?.children) || c.analysis().ast.children.length === 0,
}

const NEED = {
  WASM_SHA256: 'string', WASM_BYTES: 'number', REQUIRED_EXPORTS: 'array', VERDICTS: 'array', RULES: 'array',
  RULE_VERDICTS: 'array', DEFAULT_VERDICT: 'string', TEST_STATES: 'array', TEST_PRECEDENCE: 'array', TEST_EMPTY: 'string',
  AST_LINE_UNKNOWN: 'number', AST_HAS_SPANS: 'boolean', TYPECHECK_EVALUATES_ASSERTS: 'boolean',
}

/** The policy as data, or a PolicyError naming what is wrong with it. */
export function policyFrom(analysis) {
  const problems = []
  if (!analysis?.ast || analysis.astError) throw new PolicyError(`${POLICY_SPEC} does not parse: ${compilerErrors(analysis ?? {}).join('; ')}`)
  const v = verdictOf(analysis)
  if (!v.typecheckOk || v.discarded > 0) throw new PolicyError(`${POLICY_SPEC} is not clean: ${JSON.stringify(v)} ${compilerErrors(analysis).join('; ')}`)
  const p = readableConsts(analysis)
  for (const [k, t] of Object.entries(NEED)) {
    const got = Array.isArray(p[k]) ? 'array' : typeof p[k]
    if (got !== t) problems.push(`${k} must be ${t}, is ${got}`)
  }
  if (!problems.length) {
    const rules = new Set(p.RULES)
    const impl = new Set(Object.keys(PREDICATES))
    for (const r of rules) if (!impl.has(r)) problems.push(`rule ${r} has no predicate in this harness`)
    for (const r of impl) if (!rules.has(r)) problems.push(`predicate ${r} is not in RULES`)
    if (rules.size !== p.RULES.length) problems.push('RULES lists a rule twice')
    if (p.RULES.length !== p.RULE_VERDICTS.length) problems.push(`RULES has ${p.RULES.length} entries, RULE_VERDICTS ${p.RULE_VERDICTS.length}`)
    for (const x of [...p.RULE_VERDICTS, p.DEFAULT_VERDICT]) if (!p.VERDICTS.includes(x)) problems.push(`verdict ${x} is not in VERDICTS`)
    for (const x of [...p.TEST_PRECEDENCE, p.TEST_EMPTY]) if (!p.TEST_STATES.includes(x)) problems.push(`test state ${x} is not in TEST_STATES`)
    if (!/^[0-9a-f]{64}$/.test(p.WASM_SHA256)) problems.push('WASM_SHA256 is not a full lowercase SHA-256')
  }
  if (problems.length) throw new PolicyError(`${POLICY_SPEC}: ${problems.join('; ')}`)
  const tests = specTests(analysis, p)
  if (tests.state !== 'HOLDS') throw new PolicyError(`${POLICY_SPEC}: its own tests are ${tests.state}: ${JSON.stringify(tests.blocks.filter((b) => b.state !== 'HOLDS'))}`)
  return { ...p, sha256: null, tests }
}

// ---------------------------------------------------------------------------
// Tests: evaluated where the existing evaluator can, NOT_EVALUATED everywhere else.
// ---------------------------------------------------------------------------

const firstBy = (order, states, empty) => order.find((s) => states.includes(s)) ?? empty

export function specTests(analysis, policy) {
  const top = analysis?.ast?.children ?? []
  const env = readableConsts(analysis)
  const order = policy.TEST_PRECEDENCE
  const blocks = top.filter((n) => n.kind === 'TestBlock').map((b) => {
    const asserts = (b.children ?? []).map((stmt) => {
      const call = stmt.kind === 'StmtExpr' ? stmt.children?.[0] : stmt
      const line = call?.line > policy.AST_LINE_UNKNOWN ? call.line : null
      if (call?.kind !== 'ExprCall' || call.name !== 'assert' || (call.children ?? []).length !== 1) {
        return { line, state: 'NOT_EVALUATED', detail: `${call?.kind ?? stmt.kind} is not a one-argument assert; this harness does not execute statements` }
      }
      try {
        const value = evalExpr(call.children[0], env)
        return value === true ? { line, state: 'HOLDS' } : { line, state: 'FAILS', detail: `evaluates to ${JSON.stringify(value)}` }
      } catch (e) {
        return { line, state: 'NOT_EVALUATED', detail: e.message }
      }
    })
    return { name: b.name ?? null, state: firstBy(order, asserts.map((a) => a.state), policy.TEST_EMPTY), asserts }
  })
  return {
    state: firstBy(order, blocks.map((b) => b.state), policy.TEST_EMPTY),
    blocks,
    invariantsNotExecuted: top.filter((n) => n.kind === 'InvariantBlock').length,
    benchesNotExecuted: top.filter((n) => n.kind === 'BenchBlock').length,
    typecheckEvaluatesAsserts: policy.TYPECHECK_EVALUATES_ASSERTS,
  }
}

// ---------------------------------------------------------------------------
// One inspection.
// ---------------------------------------------------------------------------

/** The rule that decides, walked in the policy's order. The analysis runs only when a rule needs it. */
export function decide(policy, compiler, analyzeSource, { expectBytes } = {}) {
  let analysed = false
  let cached
  const trusted = () => compiler.loaded && !PREDICATES.compiler_unpinned({ compiler, policy }) && !PREDICATES.exports_missing({ compiler, policy })
  const ctx = {
    compiler,
    policy,
    expectBytes,
    // An untrusted compiler is never run: every analysis-based rule then sees "no analysis".
    analysis: () => {
      if (!analysed) {
        analysed = true
        if (trusted()) {
          try { cached = analyzeSource(compiler.analyze) } catch (e) { cached = { __error: e.message } }
        }
      }
      return cached?.__error ? null : cached
    },
  }
  for (const [i, rule] of policy.RULES.entries()) {
    if (PREDICATES[rule](ctx)) return { verdict: policy.RULE_VERDICTS[i], rule, analysed: cached !== undefined && !cached?.__error, analysis: ctx.analysis(), error: cached?.__error ?? null }
  }
  return { verdict: policy.DEFAULT_VERDICT, rule: null, analysed: true, analysis: ctx.analysis(), error: null }
}

function positions(analysis, policy) {
  let linked = 0
  let unknown = 0
  const walk = (n) => {
    if (n !== analysis.ast) (n.line > policy.AST_LINE_UNKNOWN ? linked++ : unknown++)
    for (const c of n.children ?? []) walk(c)
  }
  if (analysis?.ast) walk(analysis.ast)
  return { tokens: 'line-col', tokenCount: Array.isArray(analysis?.tokens) ? analysis.tokens.length : 0, astNodesWithLine: linked, astNodesLineUnknown: unknown, astSpans: policy.AST_HAS_SPANS }
}

/**
 * Inspect one spec. `wasmBytes` is the compiler under test; the policy is always read by the
 * compiler in this tree (`policyWasmBytes`), so a broken compiler under test cannot rewrite
 * the rules that judge it.
 */
export async function inspect({ source, name = 'spec.t27', wasmBytes, wasmPath = '(bytes)', policySource, policyWasmBytes }) {
  const policyCompiler = await openCompiler(policyWasmBytes, TREE_WASM)
  const base = { schema: SCHEMA, tool: 't27f-spec-view', input: { name, bytes: Buffer.byteLength(source ?? ''), sha256: sha256(source ?? '') } }
  let policy
  try {
    if (!policyCompiler.analyze) throw new PolicyError(`the tree compiler cannot read the policy: ${policyCompiler.error ?? 'required exports missing'}`)
    policy = policyFrom(policyCompiler.analyze(policySource))
    policy.sha256 = sha256(policySource)
  } catch (e) {
    // The one decision not taken from the spec: with no readable policy there is no table to
    // consult, and the only honest verdict is that nothing was established.
    return { ...base, policy: { path: POLICY_SPEC, readable: false, error: e.message }, compile: { verdict: 'UNKNOWN', rule: 'policy_unreadable', analysed: false, errors: [] }, tests: null }
  }
  const compiler = await openCompiler(wasmBytes, wasmPath)
  const d = decide(policy, compiler, (analyze) => analyze(source), { expectBytes: Buffer.byteLength(source ?? '') })
  // A rejected answer is reported by its rule and never drawn: nothing below reads it.
  const a = d.rule === 'analysis_unreadable' ? null : d.analysis
  const top = Array.isArray(a?.ast?.children) ? a.ast.children : []
  return {
    ...base,
    policy: { path: POLICY_SPEC, readable: true, sha256: policy.sha256, ownTests: policy.tests.state, rules: policy.RULES.length },
    compiler: {
      path: compiler.path, bytes: compiler.bytes, sha256: compiler.sha256, pinnedSha256: policy.WASM_SHA256,
      pinned: compiler.sha256 === policy.WASM_SHA256, exports: compiler.exports, error: compiler.error,
    },
    compile: {
      verdict: d.verdict, rule: d.rule, analysed: d.analysed,
      module: a?.ast?.name ?? null,
      typecheck: a?.typecheck ? { ok: a.typecheck.ok ?? null, errorCount: a.typecheck.errorCount ?? null, warnings: a.typecheck.warnings ?? null } : null,
      errors: a ? compilerErrors(a) : d.rule === 'analysis_unreadable' && d.analysis ? [`answer rejected: ${malformed(d.analysis, Buffer.byteLength(source ?? ''))}`] : d.error ? [d.error] : [],
    },
    tests: a?.ast && d.rule !== 'not_parsed' ? specTests(a, policy) : null,
    positions: a ? positions(a, policy) : null,
    outline: top.map((n) => ({ kind: n.kind, name: n.name ?? null, line: n.line > policy.AST_LINE_UNKNOWN ? n.line : null })),
    // Kept for the view, not for result.json: tokens are the compiler's, with exact positions.
    _tokens: Array.isArray(a?.tokens) ? a.tokens : [],
    _nodesByLine: a?.ast ? nodesByLine(a.ast, policy) : {},
  }
}

function nodesByLine(ast, policy) {
  const out = {}
  const walk = (n) => {
    if (n !== ast && n.line > policy.AST_LINE_UNKNOWN) (out[n.line] ??= []).push(n.name ? `${n.kind} ${n.name}` : n.kind)
    for (const c of n.children ?? []) walk(c)
  }
  walk(ast)
  return out
}

/** result.json: everything except the view's working data. Stable key order, no clock. */
export function resultJson(r) {
  const { _tokens, _nodesByLine, ...rest } = r
  return JSON.stringify(rest, null, 2) + '\n'
}

// ---------------------------------------------------------------------------
// The view. Static HTML, no script, no subresource, a CSP that forbids both.
// ---------------------------------------------------------------------------

const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

/**
 * One source line, cut at the compiler's token columns. A token is marked only when its
 * lexeme is exactly the bytes at its column. A String token is the case that is not: its
 * column is the opening quote and its lexeme the unescaped contents, so its extent in the
 * source is not in the token -- it is left unmarked and counted, never given a guessed end.
 */
function lineHtml(text, toks, unmarked) {
  const bytes = Buffer.from(text, 'utf8')
  const sorted = [...toks].sort((x, y) => x.col - y.col)
  let at = 0
  let html = ''
  for (const t of sorted) {
    const lex = Buffer.from(decodeBytes(t.lexeme ?? ''), 'utf8')
    const start = t.col - 1
    if (start < at || !lex.length || !bytes.subarray(start, start + lex.length).equals(lex)) {
      unmarked[t.kind] = (unmarked[t.kind] ?? 0) + 1
      continue
    }
    html += esc(bytes.subarray(at, start).toString('utf8')) + `<span class="k-${esc(t.kind)}" title="${esc(t.kind)} ${t.line}:${t.col}">${esc(lex.toString('utf8'))}</span>`
    at = start + lex.length
  }
  return html + esc(bytes.subarray(at).toString('utf8'))
}

/**
 * The focused line, or null for none. Only a whole line number of this source is accepted --
 * a number or its decimal digits; anything else is refused, never coerced into markup.
 */
export function focusLine(focus, lineCount) {
  if (focus === null || focus === undefined) return null
  const n = typeof focus === 'number' ? focus : typeof focus === 'string' && /^[1-9][0-9]*$/.test(focus) ? Number(focus) : NaN
  if (!Number.isSafeInteger(n) || n < 1 || n > lineCount) throw new RangeError(`focus must be a line number from 1 to ${lineCount}, got ${JSON.stringify(focus)}`)
  return n
}

export function renderView(r, source, { focus = null } = {}) {
  const lines = (source ?? '').split('\n')
  const at = focusLine(focus, lines.length)
  const byLine = {}
  for (const t of r._tokens ?? []) (byLine[t.line] ??= []).push(t)
  const unmarked = {}
  const rows = lines.map((text, i) => {
    const n = i + 1
    const nodes = (r._nodesByLine?.[n] ?? []).join(', ')
    return `<tr id="L${n}"><td class="n"><a href="#L${n}">${n}</a></td><td class="s"><code>${lineHtml(text, byLine[n] ?? [], unmarked)}</code></td><td class="a">${esc(nodes)}</td></tr>`
  }).join('\n')
  const unmarkedText = Object.entries(unmarked).sort().map(([k, v]) => `${v} ${k}`).join(', ') || 'none'
  const c = r.compile ?? {}
  const t = r.tests
  const outline = (r.outline ?? []).map((o) => `<li>${esc(o.kind)} ${esc(o.name ?? '')} ${o.line ? `<a href="#L${o.line}">line ${o.line}</a>` : '<span class="u">line not given by the compiler</span>'}</li>`).join('')
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>t27f spec view: ${esc(r.input?.name)}</title>
<style>
body{font:14px/1.45 ui-sans-serif,system-ui,sans-serif;margin:16px;color:#111;background:#fff}
code,td.n,td.a{font-family:ui-monospace,Menlo,monospace}
.v{display:inline-block;padding:2px 8px;border-radius:4px;font-weight:600;margin-right:8px}
.PASS,.HOLDS{background:#d6f5d6}.FAIL,.FAILS{background:#f8d0d0}.UNKNOWN,.NOT_EVALUATED,.NONE{background:#eee}
table{border-collapse:collapse;width:100%}td{vertical-align:top;padding:0 6px;white-space:pre}
td.n{color:#888;text-align:right}td.n a{color:inherit;text-decoration:none}td.a{color:#555;font-size:12px}
tr:target{background:#fff6c8}.u{color:#888}
.k-Ident{color:#0b4f8a}.k-Comment{color:#777}[class^="k-Kw"]{color:#7a1fa2;font-weight:600}[class$="Literal"],.k-Number,.k-String{color:#a34700}
@media (prefers-color-scheme: dark){body{color:#ddd;background:#111}.PASS,.HOLDS{background:#1d4d1d}.FAIL,.FAILS{background:#5a1f1f}.UNKNOWN,.NOT_EVALUATED,.NONE{background:#333}tr:target{background:#3a3415}.k-Ident{color:#7fb7ee}}
</style></head>
<body data-focus="${esc(at ?? '')}">
<h1>${esc(r.input?.name)}</h1>
<p><span class="v ${esc(c.verdict)}">compile: ${esc(c.verdict)}</span>${c.rule ? `rule <code>${esc(c.rule)}</code>` : 'no rule fired'}
 &middot; <span class="v ${esc(t?.state ?? 'NONE')}">tests: ${esc(t?.state ?? 'NONE')}</span></p>
<p>A compile verdict is the compiler parsing and type-checking this file. It does not run a test block:
asserts over constants are evaluated by this tool where it can, and everything else is NOT_EVALUATED.</p>
<p>Source sha256 <code>${esc(r.input?.sha256)}</code>. Compiler <code>${esc(r.compiler?.sha256 ?? 'none')}</code>
${r.compiler?.pinned ? '(the pinned bytes)' : '<strong>(not the pinned bytes)</strong>'}. Policy <code>${esc(r.policy?.path)}</code>.</p>
<p>Positions: tokens carry line and column; a token is marked only where its lexeme is the source bytes at that column
(left unmarked: ${esc(unmarkedText)});
AST nodes carry a line only for some kinds (${r.positions?.astNodesWithLine ?? 0} with, ${r.positions?.astNodesLineUnknown ?? 0} without) and no spans.</p>
${(c.errors ?? []).length ? `<h2>Compiler messages</h2><ul>${c.errors.map((e) => `<li><code>${esc(e)}</code></li>`).join('')}</ul>` : ''}
<h2>Top level</h2><ul>${outline}</ul>
<h2>Source</h2>
<table>
${rows}
</table>
${at ? `<style>#L${at}{background:#fff6c8}</style>` : ''}
</body></html>
`
}

// ---------------------------------------------------------------------------
// Two compilers, one corpus.
// ---------------------------------------------------------------------------

export function specFiles(dir) {
  const out = []
  const walk = (d) => {
    for (const e of readdirSync(d, { withFileTypes: true })) {
      const p = join(d, e.name)
      if (e.isDirectory()) walk(p)
      else if (e.name.endsWith('.t27')) out.push(p)
    }
  }
  walk(dir)
  return out.sort()
}

/** Byte-compare two compilers and then compare what they say about every spec in `dir`. */
export async function compareCompilers(aBytes, bBytes, dir) {
  const [a, b] = [await loadCompiler(aBytes), await loadCompiler(bBytes)]
  const files = specFiles(dir)
  const differ = []
  const ha = createHash('sha256')
  const hb = createHash('sha256')
  for (const f of files) {
    const src = readFileSync(f, 'utf8')
    let ja, jb
    try { ja = JSON.stringify(a(src)) } catch (e) { ja = `THROW ${e.message}` }
    try { jb = JSON.stringify(b(src)) } catch (e) { jb = `THROW ${e.message}` }
    ha.update(ja + '\n')
    hb.update(jb + '\n')
    if (ja !== jb) differ.push(relative(dir, f))
  }
  return {
    a: { bytes: aBytes.length, sha256: sha256(aBytes), corpusOutputSha256: ha.digest('hex') },
    b: { bytes: bBytes.length, sha256: sha256(bBytes), corpusOutputSha256: hb.digest('hex') },
    byteIdentical: sha256(aBytes) === sha256(bBytes),
    specs: files.length,
    differ: differ.length,
    differExamples: differ.slice(0, 20),
  }
}

/**
 * Every spec in `dir` through inspect(), tallied by verdict and rule. With the pinned compiler
 * the two shape rules must never fire: if they do, it is this harness that is wrong about the
 * compiler's answers, not the corpus.
 */
export async function surveyCorpus(dir, { wasmBytes, policySource, policyWasmBytes }) {
  const files = specFiles(dir)
  const verdicts = {}
  const rules = {}
  const tests = {}
  const shapeRejected = []
  for (const f of files) {
    const r = await inspect({ source: readFileSync(f, 'utf8'), name: relative(dir, f), wasmBytes, policySource, policyWasmBytes })
    const c = r.compile
    verdicts[c.verdict] = (verdicts[c.verdict] ?? 0) + 1
    rules[c.rule ?? '(none)'] = (rules[c.rule ?? '(none)'] ?? 0) + 1
    tests[r.tests?.state ?? '(none)'] = (tests[r.tests?.state ?? '(none)'] ?? 0) + 1
    if (c.rule === 'analysis_unreadable' || c.rule === 'typecheck_contradicts' || c.rule === 'policy_unreadable') shapeRejected.push({ spec: relative(dir, f), rule: c.rule, errors: c.errors })
  }
  return { specs: files.length, verdicts, rules, tests, shapeRejected: shapeRejected.length, shapeRejectedExamples: shapeRejected.slice(0, 20) }
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function arg(args, flag) {
  const i = args.indexOf(flag)
  return i >= 0 ? args[i + 1] : undefined
}

async function main(args) {
  // The run has no network in it. If anything here ever reaches for one, it fails loudly.
  globalThis.fetch = () => { throw new Error('t27f-spec-view: the network is not part of this run') }
  if (args[0] === '--compare') {
    const [, aPath, bPath, dir] = args
    if (!aPath || !bPath || !dir) { console.error('usage: t27f-spec-view.mjs --compare <a.wasm> <b.wasm> <dir>'); return 3 }
    const r = await compareCompilers(readFileSync(aPath), readFileSync(bPath), dir)
    console.log(JSON.stringify(r, null, 2))
    // A measurement by default; --require-equal turns a difference into a failed run.
    return r.differ === 0 || !args.includes('--require-equal') ? 0 : 1
  }
  if (args[0] === '--survey') {
    if (!args[1]) { console.error('usage: t27f-spec-view.mjs --survey <dir>'); return 3 }
    const tree = readBytes(join(SITE, TREE_WASM))
    const r = await surveyCorpus(args[1], { wasmBytes: tree, policySource: readFileSync(join(SITE, POLICY_SPEC), 'utf8'), policyWasmBytes: tree })
    console.log(JSON.stringify(r, null, 2))
    return r.shapeRejected === 0 && r.specs > 0 ? 0 : 1
  }
  const specPath = args.find((x, i) => !x.startsWith('--') && !['--wasm', '--out', '--focus'].includes(args[i - 1]))
  if (!specPath) { console.error('usage: t27f-spec-view.mjs <spec.t27> [--wasm <file>] [--out <dir>] [--focus <line>]'); return 3 }
  const wasmPath = arg(args, '--wasm') ?? join(SITE, TREE_WASM)
  const source = readFileSync(specPath, 'utf8')
  const r = await inspect({
    source,
    name: basename(specPath),
    wasmBytes: readBytes(wasmPath),
    wasmPath: relative(process.cwd(), wasmPath) || wasmPath,
    policySource: readFileSync(join(SITE, POLICY_SPEC), 'utf8'),
    policyWasmBytes: readBytes(join(SITE, TREE_WASM)),
  })
  const out = arg(args, '--out')
  const focus = arg(args, '--focus') ?? null
  try { focusLine(focus, source.split('\n').length) } catch (e) { console.error(`t27f-spec-view: ${e.message}`); return 3 }
  if (out) {
    mkdirSync(out, { recursive: true })
    writeFileSync(join(out, 'result.json'), resultJson(r))
    writeFileSync(join(out, 'view.html'), renderView(r, source, { focus }))
  }
  const c = r.compile
  console.log(`t27f-spec-view: ${r.input.name} sha256 ${r.input.sha256.slice(0, 16)}; compiler ${r.compiler?.sha256?.slice(0, 16) ?? 'none'}${r.compiler?.pinned ? ' (pinned)' : ' (NOT pinned)'}`)
  console.log(`  compile ${c.verdict}${c.rule ? ` (rule ${c.rule})` : ''}; tests ${r.tests?.state ?? 'none'}${r.tests ? ` (${r.tests.blocks.length} block(s), ${r.tests.invariantsNotExecuted} invariant(s) and ${r.tests.benchesNotExecuted} bench(es) not executed)` : ''}`)
  for (const e of c.errors ?? []) console.log(`  compiler: ${e}`)
  if (r.policy && !r.policy.readable) console.log(`  policy: ${r.policy.error}`)
  if (out) console.log(`  wrote ${join(out, 'result.json')} and ${join(out, 'view.html')}`)
  return { PASS: 0, FAIL: 1, UNKNOWN: 2 }[c.verdict] ?? 2
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main(process.argv.slice(2)).then((code) => process.exit(code), (e) => { console.error(e); process.exit(2) })
}
