# Agent Operating Model

**A working system for building real software with AI coding agents — where the
engineering problem is verification and continuity, not generation.**

Agents write plausible code quickly. That is not the hard part, and it stopped
being the bottleneck some time ago. The hard parts are these:

- **A green test suite proves very little** when the same agent wrote the code
  and the tests to match it.
- **Context does not survive.** Session two does not know what session one
  decided, or why it rejected the obvious alternative.
- **Confident wrong answers are expensive.** An agent will reason its way to a
  plausible platform behaviour and be wrong, and the mistake surfaces days later
  in something unrelated.
- **Scope drifts silently.** Without a ticket that says what "done" means, an
  agent will happily finish something adjacent.

This repository is the operating model I use to work around those four problems.
It is not a prompt collection or a tooling wrapper. It is a set of roles,
review gates, written records and conventions — extracted from a real
multi-repository product build and generalised so it can be dropped onto another
project.

> **Provenance.** Every convention here earned its place by failing first —
> on a real, private, multi-repository product build run almost entirely
> through agent sessions. Nothing about that product appears in this
> repository; what is here is the operating model, generalised. The worked
> example under `examples/` is an illustration written for this repository and
> is labelled as such, because presenting an invented result as a measured one
> is the exact failure the model exists to prevent.

---

## The four mechanisms

### 1. Roles, not one assistant

Each role is a Claude Code skill under `.claude/skills/<role>/SKILL.md` with
its own scope, output location and git rules. An architect reviews; a developer
implements; a planner sizes and sequences; a manager holds state. They do not
overlap, and none of them silently becomes the others.

The point is not personality. It is **that the reviewer is not the author.** An
agent asked to review its own work will find it good.

### 2. Two review gates, and neither is optional

| Gate | What it is | Who |
|---|---|---|
| **Code review** | An independent pass with **mutation testing** — deliberately break the implementation and confirm the suite fails. A test that stays green against broken code is not a test. | Architect role, fresh session |
| **Hand check** | A human uses the actual thing on the actual device. Anything a fixture cannot show. | You |

Mutation testing is the load-bearing half. It is the only cheap way to tell a
real test from one written to accompany code that was already assumed correct.

### 3. Probes — measured, not reasoned

When a platform question cannot be answered from documentation, do not let the
agent reason about it. **Write throwaway code that measures it, then keep the
code permanently** as evidence: excluded from every build target, never
maintained, each with a README recording the question, the verdict, and the
exact toolchain and OS versions it held on.

Every finding is labelled **MEASURED** or **REASONED**, because an agent that
launders a guess into a fact is worse than no agent — the guess gets quoted
later as though it were established.

**Failed probes are kept too.** *"The platform will not do this"* is the more
valuable half of an archive. Keeping only the successes turns it into a record
in which every idea worked, which is a lie that costs real hours.

See [`Docs/Probes.md`](Docs/Probes.md), and a real one in
[`examples/probes/`](examples/probes/0000-00-00_filesystemwatcher-network-share/README.md).

### 4. Written continuity

Agents have no memory between sessions. The repository is the memory.

| Artifact | Answers |
|---|---|
| `State.md` | What is true right now, and what decisions are locked |
| `Updates/` | One dated record per session — what was done and what it cost |
| `Develop/Architect/ADRs/` | Why a cross-cutting call was made, and what it rules out |
| `Plans/BOARD.md` | What is being built, in what order, sized in hours |

A rule that only exists in chat history does not exist.

### 5. A queue, so "what next" is a file and not a memory

The board says what is being built. **The queue says what happens next, in what
order, and each entry is ready to paste.** An index in run order, one body per
prompt, five at a time — past five it is a plan, and that is the board's job.

Two things in it earn their keep beyond the obvious. **Gates** are items only the
human can clear — a decision, a merge, a device check — held separately so they
do not sit in the problem list reading as failures. And **flags carry a pass
count**: a flag entering its fourth pass leaves the block and becomes a row or a
standing rule, because a flag carried forever is a flag nobody reads.

The queue is shown in chat as a fenced monospace block with a **hard 78-column
limit**. That is not formatting fussiness. A row ran to 98 characters, a reader's
viewport soft-wrapped it, and the overflow landed at column 0 — **which in a
monospace table reads as a value in the first column.** A wrapped line in that
block does not look wrapped; it looks like data.

See [`Docs/Queue.md`](Docs/Queue.md).

### 6. Working rules, and checks that only ever report

**[`Docs/Working_Rules.md`](Docs/Working_Rules.md)** is under 3 KB and binds every
role: say what you assumed, build the minimum, keep every changed line traceable
to the request, define done before starting. It is adapted from
`multica-ai/andrej-karpathy-skills` (MIT), with one clause deliberately rejected —
where the source says *mention* unrelated dead code, this model says **file it**,
because a mention in chat is not a record.

Four scripts back the conventions that are mechanical enough to check:
`queue-lint.sh`, `state-drift.sh`, `size-budget.py`, and `setup-hooks.sh` with
`.githooks/`. **They report and exit. None of them edits a file, and none decides
anything.** The one about size exists because a `State.md` reached 23,591 tokens
while every session paid to read it, and nobody noticed without measuring.

---

## What is in here

```
CLAUDE.md                   the rules an agent reads on entering the repo
project.yaml                identity placeholders — fill these first
.claude/skills/             four role skills: manager, architect, planner, developer
Docs/Conventions.md         git workflow, state discipline, size budgets, checkpoint
Docs/Working_Rules.md       how a session behaves before it writes anything
Docs/Queue.md               the prompt queue, and how it is rendered in chat
Docs/Board.md               how work is tracked, row naming, sizing
Docs/Probes.md              the probe convention in full
Docs/ADRs.md                when an ADR is warranted, and the template
State.md                    template
Updates/                    format and an example
Plans/BOARD.md              board template
Plans/PROMPT_QUEUE.md       queue index template, fence included
Plans/queue/                one file per prompt; README carries the body shape
scripts/                    four detection-only checks; none of them edits
.githooks/                  commit-subject carry, multi-row commit warning
examples/probes/            a worked example of the probe format
```

## Using it

1. Copy this repository into your project (or use it as a template).
2. Fill in `project.yaml`.
3. Delete the roles you do not need. **Four is not a minimum** — a solo project
   with one platform can run on manager + architect + developer.
4. Open a session and read `CLAUDE.md`.

**Adopt the gates before the roles.** If you take one thing from this, take
mutation testing in review and the measured/reasoned distinction. Those two
carry most of the value; the role structure is scaffolding around them.

**After the gates, take the working rules and the size budgets** — both are
cheap, neither needs the role structure, and they are what keep a hub readable
long enough for the rest to matter.

## What this is not

- Not a framework, a dependency or a tool. It is markdown and conventions.
- Not automation. The four scripts in `scripts/` **report and exit** — they
  never edit a file and never decide anything. A human still decides, and the
  moment a check starts fixing what it found, it stops being trustworthy as a
  check.
- Not tied to Claude Code specifically, though that is what it was built on.
  The skills are markdown files; the mechanisms are not vendor-specific.

## Licence

MIT — see [`LICENSE`](LICENSE).
