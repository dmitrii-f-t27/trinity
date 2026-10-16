// What t27f-spec-view must never do: call something PASS that nobody established.
//
// One test per claim in dmitrii-f-t27/trinity#1. The compiler is the vendored WASM, run for
// real; the specs are a real corpus file, the policy itself and the fixtures under
// qa/t27f-fixtures/. No test stubs the compiler's answer except the ones whose subject is a
// wrong answer.
//
//   node --test scripts/t27f-spec-view.test.mjs

import test from 'node:test'
import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { POLICY_SPEC, SITE, TREE_WASM, decide, focusLine, inspect, openCompiler, policyFrom, renderView, resultJson } from './t27f-spec-view.mjs'

const sha256 = (b) => createHash('sha256').update(b).digest('hex')
const treeWasm = readFileSync(join(SITE, TREE_WASM))
const policySource = readFileSync(join(SITE, POLICY_SPEC), 'utf8')
const fixture = (name) => readFileSync(join(SITE, 'qa/t27f-fixtures', name), 'utf8')
const GF16 = 'public/t27/files/specs/numeric/gf16.t27'
const gf16 = readFileSync(join(SITE, GF16), 'utf8')

const run = (source, extra = {}) => inspect({ source, name: extra.name ?? 'spec.t27', wasmBytes: treeWasm, policySource, policyWasmBytes: treeWasm, ...extra })
const treeCompiler = await openCompiler(treeWasm, TREE_WASM)
const policy = policyFrom(treeCompiler.analyze(policySource))

// A valid module with one extra custom section: the same code, different bytes.
const CUSTOM = Buffer.from([0x00, 0x05, 0x04, 0x74, 0x65, 0x73, 0x74])
const repacked = Buffer.concat([treeWasm, CUSTOM])
// A valid module that exports one memory and nothing else.
const memoryOnly = Buffer.from([0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x05, 0x03, 0x01, 0x00, 0x01, 0x07, 0x0a, 0x01, 0x06, 0x6d, 0x65, 0x6d, 0x6f, 0x72, 0x79, 0x02, 0x00])

test('(1) the tree compiler is the pinned one, and the pin names its source', () => {
  assert.equal(sha256(treeWasm), policy.WASM_SHA256)
  assert.equal(treeWasm.length, policy.WASM_BYTES)
  for (const name of policy.REQUIRED_EXPORTS) assert.ok(treeCompiler.exports.includes(name), name)
  assert.match(policy.COMPILER_COMMIT, /^[0-9a-f]{40}$/)
  assert.match(policy.VENDORED_BY, /^[0-9a-f]{40}$/)
  assert.ok(['unmeasured', 'byte-identical', 'behaviour-equal', 'differs'].includes(policy.REBUILD_STATUS))
  assert.equal(policy.tests.state, 'HOLDS', 'the policy spec passes its own tests')
})

test('(2) a real corpus spec compiles; malformed and non-t27 input do not', async () => {
  const ok = await run(gf16, { name: 'gf16.t27' })
  assert.equal(ok.compile.verdict, 'PASS')
  assert.equal(ok.compile.module, 'triformat-gf16')
  assert.equal(ok.compiler.pinned, true)

  const bad = await run(fixture('malformed.t27'))
  assert.equal(bad.compile.verdict, 'FAIL')
  assert.equal(bad.compile.rule, 'not_parsed')
  assert.ok(bad.compile.errors.length > 0, 'the compiler says why')

  const md = await run(fixture('not_t27.txt'), { name: 'not_t27.txt' })
  assert.notEqual(md.compile.verdict, 'PASS')

  const empty = await run(fixture('empty.t27'))
  assert.equal(empty.compile.verdict, 'UNKNOWN', 'typecheck.ok is true for an empty file; that is not a pass')
  assert.equal(empty.compile.rule, 'empty_module')
})

test('(3) no compiler, an empty one, a broken one or the wrong bytes: never PASS', async () => {
  const cases = {
    missing: [null, 'compiler_absent'],
    empty: [Buffer.alloc(0), 'compiler_absent'],
    garbage: [Buffer.from('not wasm at all'), 'compiler_absent'],
    memoryOnly: [memoryOnly, 'compiler_unpinned'],
    repacked: [repacked, 'compiler_unpinned'],
  }
  for (const [label, [bytes, rule]] of Object.entries(cases)) {
    const r = await run(gf16, { wasmBytes: bytes })
    assert.equal(r.compile.verdict, 'UNKNOWN', label)
    assert.equal(r.compile.rule, rule, label)
    assert.equal(r.compile.analysed, false, `${label}: an untrusted compiler is never run`)
    assert.equal(r.tests, null, label)
  }
})

test('(3) the policy cannot be read by a broken tree compiler, or loosened by editing it', async () => {
  const noTree = await run(gf16, { policyWasmBytes: null })
  assert.equal(noTree.compile.verdict, 'UNKNOWN')
  assert.equal(noTree.compile.rule, 'policy_unreadable')

  // A rule the harness implements is dropped from the table.
  const dropped = policySource.replace('"empty_module"];', '"declarations_discarded"];')
  assert.notEqual(dropped, policySource)
  const r1 = await run(gf16, { policySource: dropped })
  assert.equal(r1.compile.verdict, 'UNKNOWN')
  assert.match(r1.policy.error, /RULES lists a rule twice|is not in RULES/)

  // A missing compiler is declared a pass: the policy's own test refuses it.
  const lax = policySource.replace('RULE_VERDICTS : [10]str = ["UNKNOWN",', 'RULE_VERDICTS : [10]str = ["PASS",')
  assert.notEqual(lax, policySource)
  const r2 = await run(gf16, { policySource: lax, wasmBytes: null })
  assert.equal(r2.compile.verdict, 'UNKNOWN')
  assert.match(r2.policy.error, /own tests are FAILS/)
})

test('(3) wrong or self-contradicting analysis data is UNKNOWN or FAIL, never PASS', async () => {
  // Start from the compiler's real answer for a real spec, then break one thing at a time:
  // each case below is otherwise exactly an answer that passes.
  const src = fixture('false_assert.t27')
  const bytes = Buffer.byteLength(src)
  const real = treeCompiler.analyze(src)
  assert.equal(decide(policy, treeCompiler, () => real, { expectBytes: bytes }).verdict, 'PASS', 'the unbroken answer passes')
  const broken = (edit) => { const a = structuredClone(real); edit(a); return a }
  const cases = {
    null: [null, 'analysis_unreadable'],
    array: [[], 'analysis_unreadable'],
    empty: [{}, 'analysis_unreadable'],
    sourceLinesText: [broken((a) => { a.sourceLines = '17' }), 'analysis_unreadable'],
    sourceLinesNegative: [broken((a) => { a.sourceLines = -1 }), 'analysis_unreadable'],
    sourceBytesOtherInput: [broken((a) => { a.sourceBytes += 1 }), 'analysis_unreadable'],
    tokensObject: [broken((a) => { a.tokens = {} }), 'analysis_unreadable'],
    tokenWithoutLine: [broken((a) => { delete a.tokens[0].line }), 'analysis_unreadable'],
    tokenColumnZero: [broken((a) => { a.tokens[0].col = 0 }), 'analysis_unreadable'],
    tokenPastLastLine: [broken((a) => { a.tokens[0].line = a.sourceLines + 1 }), 'analysis_unreadable'],
    tokenLexemeNumber: [broken((a) => { a.tokens[0].lexeme = 7 }), 'analysis_unreadable'],
    astNotModule: [broken((a) => { a.ast.kind = 'FnDecl' }), 'analysis_unreadable'],
    astChildrenObject: [broken((a) => { a.ast.children = {} }), 'analysis_unreadable'],
    astChildNull: [broken((a) => { a.ast.children.push(null) }), 'analysis_unreadable'],
    typecheckList: [broken((a) => { a.typecheck = [] }), 'analysis_unreadable'],
    noAst: [broken((a) => { delete a.ast }), 'not_parsed'],
    astErrorBesideAst: [broken((a) => { a.astError = 'parse error' }), 'not_parsed'],
    noTypecheckOk: [broken((a) => { delete a.typecheck.ok }), 'typecheck_unknown'],
    typecheckOkText: [broken((a) => { a.typecheck.ok = 'true' }), 'typecheck_unknown'],
    okWithErrorCount: [broken((a) => { a.typecheck.errorCount = 2 }), 'typecheck_contradicts'],
    okWithErrorList: [broken((a) => { a.typecheck.errors = ['type mismatch'] }), 'typecheck_contradicts'],
    okWithFatal: [broken((a) => { a.typecheck.fatal = 'stopped' }), 'typecheck_contradicts'],
    errorCountText: [broken((a) => { a.typecheck.errorCount = '0' }), 'typecheck_contradicts'],
    failWithNoError: [broken((a) => { a.typecheck.ok = false }), 'typecheck_contradicts'],
    failWithErrors: [broken((a) => { a.typecheck.ok = false; a.typecheck.errorCount = 1; a.typecheck.errors = ['type mismatch'] }), 'typecheck_errors'],
    discarded: [broken((a) => { a.discarded = ['fn x'] }), 'declarations_discarded'],
    emptyModule: [broken((a) => { a.ast.children = [] }), 'empty_module'],
  }
  for (const [label, [analysis, rule]] of Object.entries(cases)) {
    const d = decide(policy, treeCompiler, () => analysis, { expectBytes: bytes })
    assert.notEqual(d.verdict, 'PASS', label)
    assert.equal(d.rule, rule, label)
  }
  const thrown = decide(policy, treeCompiler, () => { throw new Error('boom') }, { expectBytes: bytes })
  assert.equal(thrown.verdict, 'UNKNOWN')
  assert.equal(thrown.rule, 'analysis_unreadable')
})

test('(4) focus is a line number of this source or it is refused', async () => {
  const r = await run(gf16)
  const lines = gf16.split('\n').length
  assert.equal(focusLine(null, lines), null)
  assert.equal(focusLine(12, lines), 12)
  assert.equal(focusLine('12', lines), 12)
  assert.equal(focusLine(lines, lines), lines)
  const refused = ['"><script>x</script>', '12" onload="x', '1e3', '0x10', ' 12', '12 ', '-1', '0', '', '1.5', 0, -3, 1.5, NaN, Infinity, lines + 1, String(lines + 1), '99999999999999999999', {}, [], true]
  for (const f of refused) assert.throws(() => renderView(r, gf16, { focus: f }), RangeError, JSON.stringify(f))
  const html = renderView(r, gf16, { focus: '975' })
  assert.match(html, /<body data-focus="975">/)
  assert.match(html, /<style>#L975\{background:#fff6c8\}<\/style>/)
})

test('(4) two analyses are identical, and focus changes nothing but the focus', async () => {
  const a = await run(gf16, { name: 'gf16.t27' })
  const b = await run(gf16, { name: 'gf16.t27' })
  assert.equal(resultJson(a), resultJson(b))
  const strip = (html) => html.replace(/data-focus="[^"]*"/, '').replace(/<style>#L\d+\{[^}]*\}<\/style>/, '')
  const v10 = renderView(a, gf16, { focus: 10 })
  const v975 = renderView(a, gf16, { focus: 975 })
  assert.notEqual(v10, v975)
  assert.equal(strip(v10), strip(v975))
  assert.equal(strip(v10), strip(renderView(b, gf16)))
  assert.equal(resultJson(a), resultJson(b), 'rendering did not touch the result')
})

test('(5) a typecheck pass is not a test pass', async () => {
  const r = await run(fixture('false_assert.t27'))
  assert.equal(r.compile.verdict, 'PASS')
  assert.equal(r.compile.typecheck.ok, true)
  assert.equal(r.tests.state, 'FAILS')
  assert.deepEqual(r.tests.blocks.map((b) => [b.name, b.state]), [['false_on_purpose', 'FAILS'], ['true_on_purpose', 'HOLDS']])

  // What the evaluator cannot run is NOT_EVALUATED, and never counted as holding.
  const g = await run(gf16)
  assert.equal(g.tests.state, 'NOT_EVALUATED')
  assert.ok(g.tests.invariantsNotExecuted > 0 && g.tests.benchesNotExecuted > 0)
})

test('(4) positions claim only what the compiler gives', async () => {
  const r = await run(gf16)
  assert.equal(r.positions.astSpans, false)
  assert.ok(r.positions.astNodesLineUnknown > 0, 'some AST kinds carry no line')
  assert.ok(r.outline.some((o) => o.line === null), 'a line the compiler did not give is shown as null, not invented')
  const html = renderView(r, gf16)
  assert.match(html, /line not given by the compiler/)
  assert.match(html, /left unmarked: \d+ String/)
})

test('(6) the run and the page make no network request', async () => {
  const real = globalThis.fetch
  let calls = 0
  globalThis.fetch = () => { calls++; throw new Error('network used') }
  try {
    const r = await run(gf16)
    const html = renderView(r, gf16)
    assert.equal(calls, 0)
    assert.match(html, /Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'"/)
    for (const re of [/<script/i, /<link/i, /<img/i, /\ssrc=/i, /url\(/i, /@import/i]) assert.doesNotMatch(html, re)
  } finally {
    globalThis.fetch = real
  }
})
