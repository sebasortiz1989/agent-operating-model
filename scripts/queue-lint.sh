#!/usr/bin/env bash
# hub-scripts generation 2026-09-12 — a project that copies this file keeps this line,
# so a later diff can say which generation it runs rather than counting lines.
# Check the prompt queue's INVARIANTS — the shape rules, not the content.
#
# WHY THIS EXISTS. Every check below is a failure that actually happened, four of
# them in a single day: a collapsed-section tag whose opener failed to land, so a
# prompt that was right there could not be found; a stale figure inside an
# acceptance criterion; a prompt citing a session record that was never written;
# and numbering that had grown holes. All mechanical, all found by a person
# reading rather than by a script — which is the argument for the script.
#
# This detects MALFORMATION — whether the file still obeys its own rules. It
# never edits the queue. The rules themselves are in Docs/Queue.md.
#
#   bash scripts/queue-lint.sh          # report; exit 1 if anything fails
set -uo pipefail
cd "${HUB_ROOT:-$(dirname "$0")/..}" || exit 0

Q=Plans/PROMPT_QUEUE.md
QDIR=Plans/queue
[ -f "$Q" ] || { echo "queue-lint: no $Q — nothing to check"; exit 0; }

python3 - "$Q" "$QDIR" <<'PY'
import re, sys, pathlib
from collections import Counter

def lineno(pos):
    """1-based line number, so a failure names a place the reader can jump to."""
    return text.count('\n', 0, pos) + 1

q = pathlib.Path(sys.argv[1])
qdir = pathlib.Path(sys.argv[2])
# encoding is explicit: the queue is full of em dashes, and on Windows the
# default codec mangles them before any heading match runs.
text = q.read_text(encoding="utf-8", errors="replace")
fails, notes = [], []

# ---------------------------------------------------------------------------
# THE SPLIT. Prompt BODIES live one-per-file in Plans/queue/;
# this file keeps the index (the RUNNING ORDER table), the rules and the Done log.
#
# The parse changed and so did three checks, but NOT what they protect. Under one
# file the danger was two blocks answering to one address, or a block hiding below
# the Done log where the parser never looked. Under one-file-per-prompt those
# become: two files claiming one number, a body with no index row, and an index row
# with no body — the last of which is NEW and is the invariant that makes two files
# safe where one was.
# ---------------------------------------------------------------------------

# ---- the index rows: the RUNNING ORDER table is the index ----
# A row is a line in the fenced table starting "  N  /role". The table is fenced
# monospace by the model's rule, so it is parsed as text rather than as markdown.
index_rows = {}
for m in re.finditer(r'(?m)^  ([0-9]+)  (/[a-z-]+)', text):
    index_rows.setdefault(m.group(1), []).append(lineno(m.start()))

# ---- the body files ----
body_files = sorted(qdir.glob('[0-9]*.md')) if qdir.is_dir() else []
bodies = {}          # number -> (path, text)
for f in body_files:
    stem = f.stem
    btext = f.read_text(encoding="utf-8", errors="replace")
    if not stem.isdigit():
        fails.append(f"{f}: filename is not a prompt number — the body of prompt N "
                     f"is {qdir}/N.md and nothing else")
        continue
    heads = re.findall(r'(?m)^## ([0-9]+) — .*$', btext)
    if len(heads) != 1:
        fails.append(f"{f}: has {len(heads)} '## N — ' headings; a body file holds "
                     f"exactly one prompt")
        continue
    if heads[0] != stem:
        # PORTED from "duplicate prompt numbers": under one file the failure was two
        # blocks answering to one address. Under one file per prompt the same failure
        # arrives as a file whose heading disagrees with its name — 'run prompt 3'
        # opens 3.md and finds prompt 5.
        fails.append(f"{f}: heading says prompt {heads[0]} but the filename says "
                     f"{stem} — 'run prompt {stem}' would open the wrong prompt")
        continue
    if stem in bodies:
        fails.append(f"prompt {stem}: two files claim it")
        continue
    bodies[stem] = (f, btext)

# ---- NEW INVARIANT: index rows and body files are one-to-one ----
# This is the guarantee that makes the split safe, and it did not exist before:
# under one file a prompt could not be half-present.
for n in sorted(set(index_rows) - set(bodies), key=int):
    fails.append(f"index row for prompt {n} (line {index_rows[n][0]}) has NO body "
                 f"file — {qdir}/{n}.md is missing. A refresh that renumbered the "
                 f"index without `git mv`ing the bodies does exactly this")
for n in sorted(set(bodies) - set(index_rows), key=int):
    # PORTED from "prompt headings OUTSIDE the live section": a prompt the index
    # does not list is invisible to a reader working top-down and findable by one
    # who guesses a number — the same defect the split-to-one-file-per-prompt
    # produced the first time it was done by hand.
    fails.append(f"{bodies[n][0]} has NO row in the RUNNING ORDER table — an orphan. "
                 f"Every body is listed in the index, or it is struck and deleted")
for n, lines in index_rows.items():
    if len(lines) > 1:
        fails.append(f"prompt {n} has {len(lines)} index rows (lines "
                     f"{', '.join(map(str, lines))}) — two rows, one address")

if not bodies and not index_rows:
    # An EMPTY queue is a legitimate state, not a failure. A hub between passes,
    # or one that is dormant, has no live prompt and nothing is wrong with it.
    if fails:
        for f_ in fails:
            print(f"queue-lint: FAIL  {f_}")
        sys.exit(1)
    print("queue-lint: queue is EMPTY — no live prompts. Nothing to check.")
    sys.exit(0)

# A prompt heading left behind in the index file is now always wrong: bodies moved.
for m in re.finditer(r'(?m)^## [0-9]+ — .*$', text):
    fails.append(f"line {lineno(m.start())}: {m.group(0)[:58]!r} — a prompt BODY is "
                 f"still in {q.name}. Bodies live in {qdir}/N.md")

blocks = [bodies[n][1] for n in sorted(bodies, key=int)]
nums = sorted(bodies, key=int)
for n in nums:
    b = bodies[n][1]
    label = f"prompt {n} ({bodies[n][0]})"
    pre = b.split('```')[0]

    if '**Parallel:**' not in pre:
        fails.append(f"{label}: no **Parallel:** line")

    # A prompt naming a role slash must be runnable. A human-owned prompt need not be.
    is_role = re.search(r'`/[a-z-]+`', b.splitlines()[0]) is not None
    if is_role:
        if b.count('```') < 2:
            fails.append(f"{label}: names a role but has no fenced body — nothing to run")
        if 'Suggested commit subject:' not in pre:
            fails.append(f"{label}: no `Suggested commit subject:` above the fence")

    if len(pre.strip().splitlines()) > 14:
        notes.append(f"{label}: preamble is {len(pre.strip().splitlines())} lines "
                     f"(the rule says two to five; reasons belong inside the fence)")

# ---- numbering: contiguous from 0 ----
# PORTED from the duplicate check, which has MOVED rather than disappeared: two
# blocks can no longer answer to one address, because a filename is unique by
# construction. What a filesystem cannot prevent is a HOLE — prompt 2 struck and
# deleted without renumbering 3 and 4 down — and that is what this catches. The
# duplicate cases that remain possible (a heading disagreeing with its filename,
# two index rows for one number) are checked above, where the evidence is.
ints = [int(n) for n in nums]
if ints != list(range(len(ints))):
    fails.append(f"numbering is {ints}; it must read 0,1,2,… (the queue is in RUN "
                 f"ORDER, so position is meaning). A struck prompt is deleted AND "
                 f"the ones after it are `git mv`d down")

# ---- (the "outside the live section" check moved) ----
# It is now the index/body one-to-one check near the top. Under one file, an orphan
# was a prompt block below the Done log that `live` never reached. Under one file
# per prompt, an orphan is a body file with no index row — and its converse, an
# index row with no body, is newly detectable and is the stronger half.

# ---- section headings that appear more than once ----
# WHY: a hand-edited splice once produced two '## RUNNING ORDER' blocks and a
# heading cut mid-sentence ('## Done` LEDGER HOLDS…'). A duplicated section is the
# signature of a bad edit, and it is cheap to spot even when the prompts happen to
# look fine.
sections = [m for m in re.finditer(r'(?m)^## (?![0-9]+ — ).*$', text)]
seen = Counter(m.group(0).strip() for m in sections)
for title, c in seen.items():
    if c > 1:
        where = [lineno(m.start()) for m in sections if m.group(0).strip() == title]
        fails.append(f"section {title[:48]!r} appears {c} times (lines "
                     f"{', '.join(map(str, where))}) — the file has been spliced")

# ---- struck prompts must not still have a body file ----
for n in nums:
    if bodies[n][1].splitlines()[0].count('~~'):
        fails.append(f"{bodies[n][0]}: struck prompt still has a body file — strike it in the Done log and `git rm` the body")

# ---- raw HTML anywhere in the file ----
for m in re.finditer(r'(?m)^\s*</?(details|summary|div|span|br)\b[^`]*$', text):
    fails.append(f"raw HTML {m.group(0).strip()[:40]!r} — the queue is markdown only; "
                 f"a struck body is deleted, not collapsed")

# ---- cross-references to prompt numbers that do not exist ----
allprompt = text + ''.join(b for _, b in bodies.values())
for n in sorted({m.group(1) for m in re.finditer(r'\bprompt ([0-9]+)\b', allprompt)}):
    if n not in nums:
        hits = len(re.findall(rf'\bprompt {n}\b', allprompt))
        fails.append(f"reference to 'prompt {n}' but no such prompt exists "
                     f"({hits} place(s)) — a retired number is a dead address")

# ---- cited Updates/ paths must be on disk ----
missing = sorted(m for m in
                 set(re.findall(r'Updates/[0-9]{4}-[0-9]{2}-[0-9]{2}_[A-Za-z0-9_.-]+\.md', allprompt))
                 if not pathlib.Path(m).exists())
for m in missing[:5]:
    fails.append(f"cites {m} — that file does not exist")
if len(missing) > 5:
    fails.append(f"… and {len(missing) - 5} more cited entries that do not exist "
                 f"(if this is most of them, you are probably running from the wrong directory)")

# ---- report ----
print("-" * 64)
# The count says "live", so it must not quietly mean "the ones I bothered to look
# at". PORTED: under one file this compared the live section against every heading
# in the file, because a splice had put prompts where the parser never looked. It
# now compares INDEX ROWS against BODY FILES — the same question ("is the header's
# number the whole truth?") asked of the structure that replaced it.
if len(index_rows) != len(bodies):
    print(f"QUEUE LINT — {len(bodies)} body files, but {len(index_rows)} index rows")
else:
    print(f"QUEUE LINT — {len(bodies)} live prompts")
print("-" * 64)
if fails:
    for f in fails:
        print(f"  FAIL  {f}")
if notes:
    for n in notes:
        print(f"  note  {n}")
if not fails and not notes:
    print("  clean — every prompt is runnable, numbered in order, and cites real files")
elif not fails:
    print("  no failures")
print("-" * 64)
sys.exit(1 if fails else 0)
PY
