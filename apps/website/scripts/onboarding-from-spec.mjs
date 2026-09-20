#!/usr/bin/env node
// onboarding-from-spec.mjs -- the agent-facing surface of t27.ai, from `specs/catalog/onboarding.t27`.
//
// Reads the vendored `public/t27/files/specs/catalog/onboarding.t27` through the real compiler
// (`t27_compiler.wasm`), checks the constant schema, evaluates every `test` block of the spec,
// and writes the two files the site serves to anything that crawls it:
//
//   public/agents.t27   the document
//   public/llms.txt     the same bytes, at the address a crawler already asks for
//
// The two files are byte-identical on purpose. `llms.txt` has no schema -- it is a text file for
// language models -- so the text we put there is our own language rather than a translation of
// the offer into Markdown, an A2A card and an ai-plugin manifest. What is published compiles:
// this generator hands the rendered document back to the compiler before writing it, so an
// invitation written in t27 cannot ship as something t27 cannot read.
//
// Nothing here parses a `.t27` with a regular expression; constants and asserts come from the
// compiler's AST. The asserts are evaluated on purpose: `typecheck.ok` stays true for
// `assert 1 > 2`, so a spec whose own tests do not hold must not produce a green build.
//
// Run:      node scripts/onboarding-from-spec.mjs            (write)
//           node scripts/onboarding-from-spec.mjs --check    (fail if the committed files are stale)
//           node scripts/onboarding-from-spec.mjs --json     (print the constants as JSON)
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { CYRILLIC, SITE, checkSchema, constsOf, loadCompiler, sha256, verdictOf } from './agents-from-specs.mjs'
import { runSpecTests } from './viewport-from-spec.mjs'

const WASM = 'public/t27/t27_compiler.wasm'
export const ONBOARDING_SPEC = 'public/t27/files/specs/catalog/onboarding.t27'
export const DOC_OUT = 'public/agents.t27'
export const LLMS_OUT = 'public/llms.txt'
export const EXPECTED_MODULE = 'catalog_onboarding'
export const ORIGIN = 'https://t27.ai/'

export const ONBOARDING_REQUIRED = {
  KIND: 'str', ID: 'str', NAME: 'str', GENERATED: 'arr', LICENCE: 'str', CONTACT: 'str',
  SITE: 'str', DOC: 'str', DOC_ALIAS: 'str', LIVE_TRUTH: 'str', RAW_PREFIX: 'str',
  READ: 'arr', READ_ABOUT: 'arr',
  COMPILER: 'str', COMPILER_EXPORTS: 'arr', COMPILER_ABI: 'str', REQUIRES_RUNNING_OUR_CODE: 'bool',
  MEASURED_AT: 'str', SPEC_COUNT: 'u16', SPEC_LINES: 'u32',
  HEALTH_OK: 'u16', HEALTH_WARN: 'u16', HEALTH_FAIL: 'u16', HEALTH_FAIL_NOTE: 'str',
  REPO_COUNT: 'u8', WORLD_COUNT: 'u8',
  GAME: 'str', GAME_DOC: 'str', GAME_BOARD: 'str', WIN_CONDITION: 'str',
  CAMPAIGN: 'str', CAMPAIGN_NOTE: 'str', CYCLE: 'arr', CYCLE_ABOUT: 'arr',
  CLAIM_COLOURS: 'arr', CLAIM_MEANINGS: 'arr', HOVER_COLOUR: 'str', HOVER_NOTE: 'str', HONESTY_LAW: 'str',
  JOIN: 'arr', CONTRIBUTE: 'str', CONTRIBUTE_NOTE: 'str',
  WRITE_API: 'bool', WRITE_API_NOTE: 'str', MCP_HOSTED: 'bool', MCP_NOTE: 'str',
  AGENT_REGISTRY: 'bool', AGENT_REGISTRY_NOTE: 'str', ACCOUNTS: 'bool', UNKNOWN: 'arr',
  IS_INSTRUCTION: 'bool', OWNER_CONSENT_REQUIRED: 'bool', ASKS_FOR_CREDENTIALS: 'bool', ASKS_TO_ACT_ALONE: 'bool',
}

const HEX = /^#[0-9A-F]{6}$/

// ---------------------------------------------------------------------------
// Semantic checks the schema cannot express.
//
// The four consent constants are checked here as well as in the spec's own tests. That is
// deliberate duplication: the spec could be edited to flip a flag AND to relax the test that
// guards it in one commit, and the whole point of the document is that it does not quietly
// become an instruction addressed at somebody else's agent.
// ---------------------------------------------------------------------------
export function semanticProblems(f, file) {
  const p = []
  if (f.KIND !== 'onboarding') p.push(`${file}: KIND must be "onboarding"`)
  if (f.ID !== 'catalog/onboarding') p.push(`${file}: ID must be "catalog/onboarding"`)
  if (JSON.stringify(f.GENERATED) !== JSON.stringify([LLMS_OUT, DOC_OUT])) {
    p.push(`${file}: GENERATED must be exactly ${JSON.stringify([LLMS_OUT, DOC_OUT])}`)
  }
  if (f.SITE !== ORIGIN) p.push(`${file}: SITE must be ${ORIGIN}`)
  if (f.DOC !== `${ORIGIN}agents.t27`) p.push(`${file}: DOC must be ${ORIGIN}agents.t27`)
  if (f.DOC_ALIAS !== `${ORIGIN}llms.txt`) p.push(`${file}: DOC_ALIAS must be ${ORIGIN}llms.txt`)

  if (f.READ.length !== f.READ_ABOUT.length) p.push(`${file}: READ has ${f.READ.length} addresses and READ_ABOUT ${f.READ_ABOUT.length} descriptions`)
  f.READ.forEach((url, i) => {
    if (!url.startsWith(ORIGIN)) p.push(`${file}: READ[${i}] ${url} is not on ${ORIGIN}`)
    if (!(f.READ_ABOUT[i] ?? '').trim()) p.push(`${file}: READ_ABOUT[${i}] is empty; an address nobody can explain does not belong on the list`)
  })
  if (f.LIVE_TRUTH !== f.READ[0]) p.push(`${file}: LIVE_TRUTH must be the first READ address (the manifest)`)
  if (!f.RAW_PREFIX.startsWith(ORIGIN) || !f.RAW_PREFIX.endsWith('/')) p.push(`${file}: RAW_PREFIX must be a ${ORIGIN} path ending in /`)
  if (!f.COMPILER.startsWith(ORIGIN)) p.push(`${file}: COMPILER must be served from ${ORIGIN}`)
  for (const name of ['t27_alloc', 't27_analyze', 't27_free']) {
    if (!f.COMPILER_EXPORTS.includes(name)) p.push(`${file}: COMPILER_EXPORTS must name ${name}`)
  }

  if (f.HEALTH_OK + f.HEALTH_WARN + f.HEALTH_FAIL !== f.SPEC_COUNT) {
    p.push(`${file}: health ${f.HEALTH_OK}+${f.HEALTH_WARN}+${f.HEALTH_FAIL} does not add up to SPEC_COUNT ${f.SPEC_COUNT}`)
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(f.MEASURED_AT)) p.push(`${file}: MEASURED_AT must be an ISO date; a snapshot without its day is not a snapshot`)

  if (f.CYCLE.length !== 5) p.push(`${file}: the cycle is five steps, not ${f.CYCLE.length}`)
  if (f.CYCLE.length !== f.CYCLE_ABOUT.length) p.push(`${file}: every cycle step needs its line in CYCLE_ABOUT`)
  if (f.CLAIM_COLOURS.length !== 3) p.push(`${file}: there are exactly three claim colours, not ${f.CLAIM_COLOURS.length}`)
  if (f.CLAIM_COLOURS.length !== f.CLAIM_MEANINGS.length) p.push(`${file}: every claim colour needs its meaning`)
  for (const [i, c] of f.CLAIM_COLOURS.entries()) if (!HEX.test(c)) p.push(`${file}: CLAIM_COLOURS[${i}] ${c} is not an upper-case #RRGGBB`)
  if (!HEX.test(f.HOVER_COLOUR)) p.push(`${file}: HOVER_COLOUR ${f.HOVER_COLOUR} is not an upper-case #RRGGBB`)
  if (f.CLAIM_COLOURS.includes(f.HOVER_COLOUR)) p.push(`${file}: the hover colour is not a claim state and must not be one of the three`)

  // The invitation has to keep routing through a person. If the first step stops naming the
  // owner, what is published is no longer an invitation.
  if (!/owner/i.test(f.JOIN[0] ?? '')) p.push(`${file}: JOIN[0] must address the reader's owner; an offer that skips them is not an offer`)
  for (const [i, s] of f.JOIN.entries()) if (!s.trim()) p.push(`${file}: JOIN[${i}] is empty`)
  if (!f.UNKNOWN.length) p.push(`${file}: UNKNOWN must not be empty -- the honesty law needs somewhere to land`)
  for (const [i, s] of f.UNKNOWN.entries()) if (!s.trim()) p.push(`${file}: UNKNOWN[${i}] is empty`)

  if (f.IS_INSTRUCTION !== false) p.push(`${file}: IS_INSTRUCTION must be false`)
  if (f.OWNER_CONSENT_REQUIRED !== true) p.push(`${file}: OWNER_CONSENT_REQUIRED must be true`)
  if (f.ASKS_FOR_CREDENTIALS !== false) p.push(`${file}: ASKS_FOR_CREDENTIALS must be false`)
  if (f.ASKS_TO_ACT_ALONE !== false) p.push(`${file}: ASKS_TO_ACT_ALONE must be false`)
  if (f.REQUIRES_RUNNING_OUR_CODE !== false) p.push(`${file}: REQUIRES_RUNNING_OUR_CODE must be false while every READ address is plain JSON`)
  for (const flag of ['WRITE_API', 'MCP_HOSTED', 'AGENT_REGISTRY', 'ACCOUNTS']) {
    if (typeof f[flag] !== 'boolean') p.push(`${file}: ${flag} must be a boolean`)
  }
  if (f.WRITE_API === false && !f.WRITE_API_NOTE.trim()) p.push(`${file}: WRITE_API is false and WRITE_API_NOTE says nothing`)
  if (f.MCP_HOSTED === false && !f.MCP_NOTE.trim()) p.push(`${file}: MCP_HOSTED is false and MCP_NOTE says nothing`)
  if (f.AGENT_REGISTRY === false && !f.AGENT_REGISTRY_NOTE.trim()) p.push(`${file}: AGENT_REGISTRY is false and AGENT_REGISTRY_NOTE says nothing`)
  return p
}

// ---------------------------------------------------------------------------
// Emission. Deterministic: the same spec bytes give the same document.
// ---------------------------------------------------------------------------
export function renderDoc(specText, specSha) {
  return `; GENERATED by apps/website/scripts/onboarding-from-spec.mjs (gHashTag/trinity)
; from specs/catalog/onboarding.t27, sha256 ${specSha}
; Served as ${ORIGIN}agents.t27 and ${ORIGIN}llms.txt -- the same bytes at both addresses.
; Do not edit either file: edit the spec and re-run the generator.

; You asked for llms.txt and got a t27 module. That is not a mistake and not a wall: this
; file is plain text, every line of prose is a comment, and you can read it exactly as you
; read anything else. It is written in the language the site is about, because the offer
; below is an offer to write that language, and handing you a translation would have been
; the first thing here that was not true of us. It compiles; a generator checked that before
; publishing it, along with every number it states about itself.

${specText}`
}

// ---------------------------------------------------------------------------
// Build.
// ---------------------------------------------------------------------------
export async function buildOnboarding({ specText, analyze }) {
  const problems = []
  const file = ONBOARDING_SPEC.replace(/^public\/t27\/files\//, '')
  const analysis = analyze(specText)
  const verdict = verdictOf(analysis)
  if (!verdict.typecheckOk || verdict.discarded > 0 || !verdict.hirOk) problems.push(`${file}: compiler verdict not clean (${JSON.stringify(verdict)})`)
  if (/[^\x00-\x7f]/.test(specText)) problems.push(`${file}: non-ASCII byte in the spec (L3)`)
  if (CYRILLIC.test(specText)) problems.push(`${file}: Cyrillic in the spec (LANG-EN)`)
  const moduleName = analysis.ast?.name ?? null
  if (moduleName !== EXPECTED_MODULE) problems.push(`${file}: module must be ${EXPECTED_MODULE}, is ${moduleName}`)

  let consts = {}
  try { consts = constsOf(analysis) } catch (e) { problems.push(`${file}: ${e.message}`) }
  problems.push(...checkSchema(consts, ONBOARDING_REQUIRED, {}, file))
  const f = Object.fromEntries(Object.entries(consts).map(([k, v]) => [k, v.value]))

  let tests = { tests: 0, asserts: 0, failures: [] }
  if (problems.length === 0) {
    problems.push(...semanticProblems(f, file))
    tests = runSpecTests(analysis, f)
    if (tests.tests === 0) problems.push(`${file}: no test block; the spec must test its own claims`)
    problems.push(...tests.failures.map((m) => `${file}: test ${m}`))
  }

  const specSha = sha256(Buffer.from(specText, 'utf8'))
  let doc = null
  if (problems.length === 0) {
    doc = renderDoc(specText, specSha)
    // What is published has to be readable by the thing it advertises.
    const republished = analyze(doc)
    const rv = verdictOf(republished)
    if (republished.ast?.name !== EXPECTED_MODULE || !rv.typecheckOk || rv.discarded > 0) {
      problems.push(`${DOC_OUT}: the rendered document does not compile (${JSON.stringify(rv)}); the generated header broke it`)
      doc = null
    }
  }
  return { problems, verdict, fields: f, specSha, tests, doc }
}

async function main() {
  const check = process.argv.includes('--check')
  const json = process.argv.includes('--json')
  const specPath = join(SITE, ONBOARDING_SPEC)
  if (!existsSync(specPath)) { console.error(`onboarding-from-spec: ${ONBOARDING_SPEC} is not vendored`); process.exit(1) }
  const analyze = await loadCompiler(readFileSync(join(SITE, WASM)))
  const specText = readFileSync(specPath, 'utf8')
  const out = await buildOnboarding({ specText, analyze })
  if (out.problems.length) {
    console.error(`onboarding-from-spec: ${out.problems.length} problem(s)`)
    for (const p of out.problems) console.error('  ' + p)
    process.exit(1)
  }
  if (json) { console.log(JSON.stringify({ specSha: out.specSha, ...out.fields })); return }

  const targets = [[DOC_OUT, out.doc], [LLMS_OUT, out.doc]]
  if (check) {
    const stale = targets.filter(([rel, text]) => !existsSync(join(SITE, rel)) || readFileSync(join(SITE, rel), 'utf8') !== text)
    if (stale.length) {
      console.error(`onboarding-from-spec --check: stale ${stale.map(([r]) => r).join(', ')}; run node scripts/onboarding-from-spec.mjs`)
      process.exit(1)
    }
  } else {
    for (const [rel, text] of targets) {
      mkdirSync(dirname(join(SITE, rel)), { recursive: true })
      writeFileSync(join(SITE, rel), text)
    }
  }
  const f = out.fields
  console.log(`onboarding-from-spec: ${check ? 'up to date' : 'wrote'} ${DOC_OUT}, ${LLMS_OUT} (${Buffer.byteLength(out.doc)} bytes each); spec sha256 ${out.specSha.slice(0, 16)}; ${f.READ.length} read addresses, ${f.JOIN.length} join steps, ${f.UNKNOWN.length} stated unknowns; spec tests ${out.tests.tests}, asserts ${out.tests.asserts}, all hold`)
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  main().catch((e) => { console.error(e); process.exit(1) })
}
