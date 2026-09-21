// CAN THE HUD BE READ WHILE THE MAP IS LIT?
//
// The owner's report, 2026-09-21, with a photograph of the clients strip:
// "тускло! сделай видимость лучше" — it is dim, make it more visible. The
// picture shows the filter chips with the honeycomb running straight through
// the words, a hex line crossing every second glyph.
//
// The Queen's board draws every panel over a LIVE field: a hex hive, a
// starfield, and cells that light gold, green and red. So every colour on this
// page has two contrasts, not one — the one over empty sky, which is always
// fine, and the one over the brightest thing the field can put underneath it,
// which is the one nobody checks by looking. Three separate CSS comments in
// Queen.css record somebody raising an alpha because a panel "was legible only
// where the map happened to be empty". Raising it by eye is how you get four
// different alphas and no statement of what any of them buys.
//
// This gate does the arithmetic instead. It reads the tokens out of the
// stylesheet, composites each ground over a field at FULL brightness, puts the
// text colour on that, and applies WCAG 2.1 relative luminance. A colour pair
// that cannot clear its threshold with the hive at its loudest does not ship.
//
// White is the bound for the field. The hive's own brightest paint is gold
// (#ffd700, L=0.699) and the starfield's is white (L=1.0), so white is both the
// true upper bound and the simple thing to state.
//
// The second half of the gate is about WHERE a ground may be written. The veil
// under the content surfaces was fifteen hand-written rgba() literals ranging
// from 0.42 to 0.86, which is fifteen independent chances to be wrong and no
// way to fix them together. There is one token now, and this refuses a
// sixteenth literal.

import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'
import assert from 'node:assert/strict'

const here = dirname(fileURLToPath(import.meta.url))
const cssPath = resolve(here, '../src/pages/Queen.css')
const css = readFileSync(cssPath, 'utf8')

// ── colour ───────────────────────────────────────────────────────────────────

/** `rgba(2, 8, 6, 0.72)` / `rgb(1 2 3)` / `#ffd700` -> {r,g,b,a} in 0..255,0..1 */
function parseColor(text) {
  const hex = /^#([0-9a-f]{6})$/i.exec(text.trim())
  if (hex) {
    const n = parseInt(hex[1], 16)
    return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255, a: 1 }
  }
  const fn = /^rgba?\(([^)]+)\)$/i.exec(text.trim())
  assert.ok(fn, `not a colour this gate can read: ${text}`)
  const parts = fn[1].split(/[,/\s]+/).filter(Boolean).map(Number)
  assert.ok(parts.length === 3 || parts.length === 4, `odd colour: ${text}`)
  return { r: parts[0], g: parts[1], b: parts[2], a: parts.length === 4 ? parts[3] : 1 }
}

/** `over` is opaque. Returns the opaque result of painting `top` on it. */
function composite(top, over) {
  return {
    r: top.a * top.r + (1 - top.a) * over.r,
    g: top.a * top.g + (1 - top.a) * over.g,
    b: top.a * top.b + (1 - top.a) * over.b,
    a: 1,
  }
}

/** WCAG 2.1 relative luminance. */
function luminance({ r, g, b }) {
  const lin = (c) => {
    const s = c / 255
    return s <= 0.03928 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4
  }
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
}

function contrast(fg, bg) {
  const a = luminance(fg)
  const b = luminance(bg)
  const [hi, lo] = a > b ? [a, b] : [b, a]
  return (hi + 0.05) / (lo + 0.05)
}

// The field at its loudest, and the sky behind it when it is quiet. Every pair
// below is measured against BOTH, because a colour that only works over a lit
// hive is the same defect pointing the other way.
const LIT = { r: 255, g: 255, b: 255, a: 1 }
const DARK = { r: 0, g: 0, b: 0, a: 1 }

// ── the tokens, read from the stylesheet ─────────────────────────────────────

function token(name) {
  const rule = new RegExp(`--${name}:\\s*([^;]+);`).exec(css)
  assert.ok(rule, `the stylesheet no longer defines --${name}`)
  return parseColor(rule[1])
}

const PANEL = token('hud-panel')
const VEIL = token('hud-veil')
const NAV = token('hud-nav')
const MUTED = token('hud-muted')
const GOLD = token('hud-gold')
const GREEN = token('hud-green')
const CYAN = token('hud-cyan')

// ── 1. every ground carries its text over a lit field ────────────────────────

// 4.5 is WCAG AA for body text, and everything in this HUD is body text: the
// whole interface is 0.6-0.72rem mono. 3.0 is the large-text threshold and is
// allowed only for the status hues, which appear as headline numbers and bold
// one-word states, never as a sentence.
const GROUNDS = [
  { name: '--hud-panel', color: PANEL },
  { name: '--hud-veil', color: VEIL },
  { name: '--hud-nav', color: NAV },
]
const INKS = [
  { name: '--hud-muted', color: MUTED, min: 4.5, why: 'every label, note and sub-line on the board' },
  { name: '--hud-gold', color: GOLD, min: 3.0, why: 'headline numbers and the private badge' },
  { name: '--hud-green', color: GREEN, min: 3.0, why: 'live states' },
  { name: '--hud-cyan', color: CYAN, min: 3.0, why: 'research states' },
]

const table = []
for (const ground of GROUNDS) {
  for (const ink of INKS) {
    for (const [field, fieldName] of [[LIT, 'lit'], [DARK, 'dark']]) {
      const bg = composite(ground.color, field)
      const fg = composite(ink.color, bg)
      const ratio = contrast(fg, bg)
      table.push({ ground: ground.name, ink: ink.name, field: fieldName, ratio })
      assert.ok(
        ratio >= ink.min,
        `${ink.name} on ${ground.name} over a ${fieldName} field is ${ratio.toFixed(2)}:1, ` +
          `below the ${ink.min}:1 this text needs (${ink.why}). ` +
          `Raise the ground's alpha or the ink's, in the token — not in the rule that noticed.`,
      )
    }
  }
}

// The pressed chip is the one control on this board whose colour and ground are
// BOTH written down, and it has been broken twice by a layer that restyled one
// of them. Gold ground, near-black ink: check the pair as shipped.
{
  const ratio = contrast(parseColor('#050505'), parseColor('#d9a441'))
  assert.ok(ratio >= 4.5, `the pressed chip reads ${ratio.toFixed(2)}:1`)
}

// The veil is meant to stay LIGHTER than a panel — that difference is the whole
// reason there are two tokens. A veil that creeps up to the panel's alpha is a
// board with no map under it, which is a different complaint from the same
// person.
assert.ok(
  VEIL.a < PANEL.a,
  `--hud-veil (${VEIL.a}) must stay lighter than --hud-panel (${PANEL.a}): content lets the map through, chrome does not`,
)
assert.ok(VEIL.a >= 0.6, `--hud-veil at ${VEIL.a} cannot carry --hud-muted over a lit hive`)

// ── 2. every hand-written ground carries text too ────────────────────────────

// The first draft of this section banned literals outright, which was the wrong
// rule twice over: it flagged 52 places, of which 39 were translucent TINTS
// (rgba(255,255,255,0.04) on a chip, a green wash on a lit cell) that are
// painted ON a ground and carry no text at all — and banning a number does not
// say what is wrong with it. The rule below does the same arithmetic as section
// 1 on every near-black ground in the file, so a literal is allowed exactly
// when it is legible, and the failure prints the ratio rather than a style
// preference.
//
// One thing this does NOT do, stated so the number is not read as more than it
// is: it measures every ground against --hud-muted rather than against whatever
// ink that particular rule sets. --hud-muted is the LIGHTEST ink on the board,
// so the claim is one-directional and sound — a ground that fails here fails
// for every ink on it — but passing here is necessary, not sufficient.
// .queen-starfield-source is the worked example: it scored 4.24:1 against
// --hud-muted and 3.41:1 against its own #b9cad5.
const DARK_GROUND = /background:\s*(rgba\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*0?\.\d+\s*\))\s*[;,]/g

/** The near-black translucent fills in a rule body — a ground, not a tint. */
function groundsIn(body) {
  const found = []
  for (const match of body.matchAll(DARK_GROUND)) {
    const color = parseColor(match[1])
    if (color.a < 1 && Math.max(color.r, color.g, color.b) <= 20) found.push(color)
  }
  return found
}

// Surfaces that draw rather than write. A ground with no text on it cannot make
// text illegible, so it is free to be as thin as the design wants. Both are
// named, with the evidence, rather than pattern-matched — a third one is a
// decision somebody has to write down here.
const NO_TEXT = [
  // The page's own base, painted BEHIND .queen-hive-stage / canvas.queen-starfield
  // / .queen27-hover-card rather than over them (they are its children), which
  // is why it attenuates nothing and why every ratio above is measured against
  // a fully lit field.
  '.queen27-comb-field',
  // aria-hidden="true" in QueenResearchCity.tsx:293.
  '.queen27-city-canvas',
]

// Rules, the crude way that is right here: this stylesheet nests only in media
// queries, and a media query's own line carries no `background:`.
const rules = []
{
  let cursor = 0
  for (let i = 0; i < css.length; i += 1) {
    if (css[i] === '{') {
      const selector = css.slice(cursor, i)
      const close = css.indexOf('}', i)
      if (close > -1) rules.push({ selector: selector.trim(), body: css.slice(i + 1, close), at: i })
    } else if (css[i] === '}') {
      cursor = i + 1
    }
  }
}

const lineOf = (index) => css.slice(0, index).split('\n').length
const selectorOf = (rule) => rule.selector.split('\n').pop().trim()

const thin = []
let measured = 0
for (const rule of rules) {
  if (NO_TEXT.some((name) => rule.selector.includes(name))) continue
  for (const ground of groundsIn(rule.body)) {
    measured += 1
    const bg = composite(ground, LIT)
    const ratio = contrast(composite(MUTED, bg), bg)
    if (ratio < 4.5) {
      thin.push(`${lineOf(rule.at)}: ${selectorOf(rule)} — alpha ${ground.a}, ${ratio.toFixed(2)}:1`)
    }
  }
}

assert.deepEqual(
  thin,
  [],
  'a ground was thinned until the hive came through the words. ' +
    'Use var(--hud-veil) for a content surface or var(--hud-panel) for chrome — ' +
    'both are chosen by this threshold rather than by eye. If the surface truly ' +
    'carries no text, add it to NO_TEXT above with the evidence that says so.',
)

// ── 3. the shell restyles a ground and its ink together ──────────────────────

// #888888 on solid #050505 is 5.9:1 and perfectly fine. The defect is a layer
// that swaps the ground for a translucent one and leaves the colour written
// against the old one — measured at 1.6:1 on the chips in the owner's
// photograph. These are the rules that repaired it; they are asserted by name
// because the next person to touch this file will be reading the chip's base
// rule, where the colour still says --muted.
const shell = css.slice(css.indexOf('.queen27-page.is-shell .queen27-chip:not([aria-pressed="true"]),'))
assert.match(
  shell,
  /\.queen27-page\.is-shell \.queen27-chip:not\(\[aria-pressed="true"\]\) \{\s*color: var\(--hud-muted\);/,
  'the shell gives the resting chip a translucent ground; it must give it the ink to go with it',
)
assert.match(
  shell,
  /\.queen27-page\.is-shell :is\(\.queen27-lane-filter, \.queen27-dir-filter\),[\s\S]{0,120}\{\s*color: var\(--hud-muted\);/,
  'the filter rows set --muted directly on themselves, so the heading\'s --hud-muted never reaches them',
)

// The clients strip is the one row on this board that carries another person's
// name, over the densest gold the hive paints. It gets the panel, not the veil.
const laneHead = /\.queen27-lane-head\.is-private \{([^}]+)\}/.exec(css)
assert.ok(laneHead, '.queen27-lane-head.is-private is gone')
assert.match(
  laneHead[1],
  /background: var\(--hud-panel/,
  'the private clients strip must sit on the panel: the map may run under a column of cards, not under somebody\'s name',
)
assert.match(laneHead[1], /backdrop-filter: blur\(/, 'the private strip takes the hive\'s edges out of its letters')

// The search box has no <label>: its placeholder is the accessible name, so it
// is body text and not a hint. Left to the UA it is #757575 — 4.39:1 measured
// in the browser, which is how a word in the owner's photograph was still
// failing after the ground under it had been fixed.
assert.match(
  css,
  /\.queen27-lane-search::placeholder \{\s*color: var\(--hud-muted/,
  'the only label on the person-search box is its placeholder; it may not keep the UA grey',
)

// ── done ─────────────────────────────────────────────────────────────────────

const worst = table.reduce((a, b) => (a.ratio < b.ratio ? a : b))
const mutedLit = table.find((r) => r.ink === '--hud-muted' && r.ground === '--hud-veil' && r.field === 'lit')
console.log(
  `queen-contrast: ${table.length} pairs measured over a lit and a dark field, ` +
    `worst ${worst.ratio.toFixed(2)}:1 (${worst.ink} on ${worst.ground}, ${worst.field}), ` +
    `--hud-muted on --hud-veil over a lit hive ${mutedLit.ratio.toFixed(2)}:1, ` +
    `${measured} hand-written grounds measured, ${NO_TEXT.length} exempt as draw surfaces`,
)
