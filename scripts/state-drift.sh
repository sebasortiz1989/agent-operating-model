#!/usr/bin/env bash
# Report where State.md has fallen behind the hub. DETECTION ONLY.
#
# WHY THIS EXISTS. Everything else in a hub tends to get guarded — the board is
# checked against its own rows, the queue is linted. `State.md` was guarded by
# NOTHING, and on the build this model came from it grew to 94 KB (~24k tokens)
# while one role's newest line went eight days and fifteen session records stale,
# and a test-count line still read a figure the suite had passed weeks earlier.
# Two files in one repository disagreed and only an outside reader ever asked.
#
# CLAUDE.md tells EVERY role to read State.md before any work, so this file's
# length is a cost paid once per role per session, not once per day. In a young
# hub this script stays quiet; that is the point. Install it BEFORE the problem.
#
# It reports two things and fixes neither:
#   1. Per-role staleness — session records in Updates/ newer than that role's
#      newest dated line under its `### <Role>` heading in State.
#   2. Size, with a per-section breakdown, once the file is near its budget.
#
# ROLES ARE DERIVED FROM `.claude/skills/`, NOT HARDCODED. A hardcoded role table
# is the defect this script would otherwise ship with: ported to a project whose
# roles differ, it matches nothing and reports "every role is current" forever.
# A check that cannot fail reads exactly like a check that works.
#
# The manager role drafts the State pass and a human approves it. This file
# never edits State.md.
set -uo pipefail

# Hub content sits at the repository root, so every relative path below stays
# as written.
cd "${HUB_ROOT:-$(dirname "$0")/..}" || exit 0
[ -f State.md ] || exit 0
[ -d Updates ] || exit 0

python3 - <<'PY'
import pathlib, re

root  = pathlib.Path(".")
state = (root / "State.md").read_text(encoding="utf-8", errors="replace")
upd   = sorted(p.name for p in (root / "Updates").glob("2*.md"))

# Role slugs come from the skill directories, so this script never needs editing
# when a project adds, renames or deletes a role. The heading candidates are the
# slug title-cased and the slug itself — `backend-developer` matches a State
# heading of `### Backend Developer`.
skills = sorted(p.name for p in (root / ".claude" / "skills").iterdir()
                if p.is_dir()) if (root / ".claude" / "skills").is_dir() else []
ROLES = [(s, [s.replace("-", " ").title(), s]) for s in skills]

def section(heading):
    m = re.search(rf"^### {re.escape(heading)}\s*$", state, re.M)
    if not m:
        return None
    nxt = re.search(r"^(###|##) ", state[m.end():], re.M)
    return state[m.end(): m.end() + (nxt.start() if nxt else len(state))]

def newest_dated(body):
    ds = re.findall(r"\[(\d{4}-\d{2}-\d{2})\]", body or "")
    return max(ds) if ds else None

stale = []
for slug, headings in ROLES:
    body = next((b for b in (section(h) for h in headings) if b is not None), None)
    if body is None:
        continue
    entries = [f for f in upd
               if re.match(rf"^\d{{4}}-\d{{2}}-\d{{2}}_\w+?_{slug}_", f)]
    if not entries:
        continue
    newest = max(f[:10] for f in entries)
    sdate  = newest_dated(body)
    label  = headings[0]
    if sdate is None:
        stale.append((label, "never", newest, len(entries)))
    elif newest > sdate:
        since = sum(1 for f in entries if f[:10] > sdate)
        stale.append((label, sdate, newest, since))

lines = []
lines.append("----------------------------------------------------------------")
lines.append("STATE DRIFT — State.md is read by every role before any work")
lines.append("----------------------------------------------------------------")

if stale:
    lines.append("ROLES WHOSE STATE LINE IS OLDER THAN THEIR NEWEST UPDATE:")
    for label, sdate, newest, since in sorted(stale, key=lambda r: r[1]):
        lines.append(f"  {label:<20} State: {sdate:<10}  newest entry: {newest}  ({since} since)")
elif not any(section(h) for _, hs in ROLES for h in hs):
    # No `### <Role>` section resolved. That is a legitimate shape — a hub whose
    # State is organised by project, or one with a single agent — but it means
    # the staleness check has nothing to match. Say so rather than pass silently.
    lines.append("  State carries no `### <Role>` sections — staleness check does")
    lines.append("  not apply to this hub's shape. Size report only.")
else:
    lines.append("  every role's State line is current with its newest update")

MARKS = ["## Current Phase", "## Key Decisions",
         "## Open Questions / Blockers", "## Latest From Each Agent"]
pos = [(m, state.find(m)) for m in MARKS if state.find(m) >= 0]
pos.append(("EOF", len(state)))
total = len(state)
# The census is GATED, and that is the point. A size table printed every session
# is an audit nobody wants to read, and a file can reach 23,591 tokens with one
# running above it daily. Silent while healthy; loud, and only about the section
# at fault, when not.
# scripts/size-budget.py owns the ceiling for every per-session file.
if total // 4 > 2400:  # 80% of the 3,000-token budget - room to act
    worst = max(zip(pos, pos[1:]), key=lambda z: z[1][1] - z[0][1])
    lines.append("")
    lines.append(f"SIZE: {total:,} chars ~{total//4:,} tokens - approaching or over budget.")
    lines.append(f"  largest section: {worst[0][0]}  ({worst[1][1]-worst[0][1]:,} chars)")
    lines.append("  State carries the CLAIM; the reasoning lives in the file that")
    lines.append("  produced it. See scripts/size-budget.py.")
# The limit: 3,000 tokens. An earlier alarm sat at 20,000
# chars (~5,000 tokens) -- 67% PAST the limit, so it could never have enforced
# it. Warn at 80% of budget so there is room to act before the ceiling.
BUDGET_TOKENS = 3000
BUDGET = BUDGET_TOKENS * 4
if total > BUDGET:
    lines.append(f"  !! OVER BUDGET: ~{total//4:,} tokens against a {BUDGET_TOKENS:,}-token limit")
    lines.append("     . Every role pays this on every session.")
    lines.append("     The fix is a trim pass agreed with a human, not a bigger file.")
elif total > BUDGET * 0.8:
    lines.append(f"  !  {total*100//BUDGET}% of the {BUDGET_TOKENS:,}-token budget"
                 f" (~{(BUDGET-total)//4:,} tokens of headroom left).")
    lines.append("     Trim before the next batch of decisions lands, not after.")

board = ""
for p in list(root.glob("Plans/BOARD.md")) + list(root.glob("Plans/boards/*.md")):
    board += p.read_text(encoding="utf-8", errors="replace")
recent = ""
for f in upd[-12:]:
    recent += (root / "Updates" / f).read_text(encoding="utf-8", errors="replace")

pairs  = set(re.findall(r"\b(\d{3,4})\s*/\s*(\d{3,4})\b", state))
orphan = sorted({f"{a}/{b}" for a, b in pairs
                 if a not in board and a not in recent})
if orphan:
    lines.append("")
    lines.append("FIGURES IN STATE THAT NO BOARD OR RECENT ENTRY REPEATS:")
    lines.append("  " + ", ".join(orphan[:8]))
    lines.append("  ^ a stale headline reads as current. Check before trusting them.")

# Does the staleness check apply at all? If no `### <Role>` section resolves,
# it matched nothing — and "nothing stale" would be a lie of omission.
applies = any(section(h) for _, hs in ROLES for h in hs)

quiet = not stale and total <= BUDGET * 0.8 and not orphan
if quiet:
    # a young hub should print almost nothing
    if applies:
        print("state-drift: State is current and small — nothing to report")
    else:
        print("state-drift: State is small. No `### <Role>` sections, so the")
        print("             staleness check does not apply to this hub's shape.")
else:
    print("\n".join(lines))
    print("----------------------------------------------------------------")
    print("Detection only. The manager role drafts the State pass; a human approves it.")
    print("This file never edits State.md.")
    print("----------------------------------------------------------------")
PY
exit 0
