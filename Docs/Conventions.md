# Conventions

## Git

### Session start (mandatory)

```bash
git checkout main && git pull --ff-only origin main
git status --porcelain            # must be clean before you branch
git checkout -b agent/<role>      # or switch to it and rebase
```

Never start work on a stale default branch. Most merge pain traces back to a
session that skipped this.

### Agent commits

- Agents commit on **`agent/<role>`** and open a PR. Never to the default branch.
- One commit per accepted unit of work, not per file touched.
- **The commit message states what actually happened**, including what failed.
  A message that describes intent rather than outcome is how a partial change
  gets recorded as a complete one.
- Never force-push a shared branch.

### The failure this prevents

A multi-step script edits three files. Edit two fails silently; edit three never
runs. The commit command sits on its own line, so it commits and pushes anyway —
with a message describing all three.

**Chain the commit behind the work** (`&&`, not a new line), and verify the
result before writing the message. If a step failed, say so in the message and
fix it in a follow-up commit that says what happened.

## State

`State.md` is the single source of truth for what is currently true.

- **Only the manager role edits it, and only after an explicit human yes.**
- Every other role *proposes* a paste at the end of its session record and
  changes nothing.
- Entries are dated, newest first, **one line each.** The one-line rule is what
  keeps the file readable; a paste drafted as three paragraphs gets collapsed on
  the way in, not waved through.

## Session records

One file per session in `Updates/`:

```
Updates/YYYY-MM-DD_HHMM_<role>_short-topic.md
```

**`HHMM` is the clock time you create the file** (`date +%Y-%m-%d_%H%M`), not a
sequence number. A counter requires knowing what else was written today, and
**parallel sessions cannot see each other** — two sessions on one day both reach
for `_02_`, and one silently overwrites the other or claims the same position in
an append-only record. The clock cannot collide that way and sorts identically.

Record what was decided, what was built, what it
cost, what is still owed, and the proposed State paste. Write it so a future
session with no memory can pick the thread up — that is its only purpose.

## End-of-day checkpoint

**Commit and push before stopping, even mid-task.** Cloud containers are
ephemeral; uncommitted work is lost when one is reclaimed. A mid-task commit
that says "checkpoint, incomplete" is strictly better than losing the session.

## Scope

Do the row that is open.

If you find a defect outside it, **file it as a new row and name it.** Do not
absorb it into the current change, and do not leave it unmentioned. An unstated
gap is the problem; a stated one is a decision someone made.

## Size budgets

**A file every session reads is a cost paid once per role per session, not once
per day.** `State.md`, the board and the prompt queue all grow the same way:
every session appends its full reasoning to a file every later session must read.
Correct locally, ruinous in aggregate, and invisible without measuring.

`scripts/size-budget.py` names the ceiling for each. **The rule, not the number:
a per-session file carries the CLAIM; the reasoning lives in the file that
produced it.** A breach is a record written into the wrong file — move it to
`Updates/`, an ADR or a dated archive. Do not delete it, and **do not raise the
budget to make the check quiet.**

Edit the budget list before you edit anything else if your layout differs. A
budget pointing at a file that does not exist is a check that always passes,
which reads exactly like a check that works.

## The prompt queue

`Plans/BOARD.md` says what is being built. `Plans/PROMPT_QUEUE.md` says what
happens next and in what order, with one ready-to-paste body per prompt in
`Plans/queue/`. Full rules, including how it is rendered in chat and why the
column limit is load-bearing: `Docs/Queue.md`.

## Review gates

Nothing merges without an independent review pass, and the reviewer is never the
author. See `Docs/Board.md` for where the gates sit in the flow, and the
`architect` skill for what a review has to do.
