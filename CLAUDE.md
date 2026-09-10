# CLAUDE.md — Agent Operating Model

This repository is a **hub**: the operating record for a product, not the
product's source. Code lives in product repositories; decisions, state, tickets
and standards live here.

## Before any role work

1. If `project.yaml` still holds placeholders, fill it before anything else.
2. Follow the git rules in `Docs/Conventions.md` — sync the default branch,
   agent commits go on `agent/<role>`, then PR.
3. Read `State.md`.
3b. **`Docs/Working_Rules.md`** — how a session behaves before it writes: state
   assumptions, build the minimum, keep changes surgical, define done first.
   **Under 3 KB, and it binds every role.**
4. Skim the newest filenames in `Updates/`.
5. Check `Plans/PROMPT_QUEUE.md` — **it is in run order**, so the top live prompt
   is what happens next. Rules: `Docs/Queue.md`.
6. Open only the role folders you need. Do not read the whole hub.

## Roles

Roles are Claude Code skills at `.claude/skills/<role>/SKILL.md` — **one copy
each, no mirrors.** A mirrored skill file is a file that will drift.

| Role | Owns |
|---|---|
| `manager` | State, cross-role status, session records, budget |
| `architect` | Cross-cutting decisions, ADRs, review gate, testing standards |
| `planner` | Turning decisions into sized, sequenced board rows |
| `developer` | Implementation on one platform |

Add or delete roles to fit the project. Four is an example, not a floor.

## After meaningful work

- Save the artifact in the owning role's folder.
- Create **one** `Updates/YYYY-MM-DD_HHMM_<role>_short-topic.md`. `HHMM` is the
  clock time you create it (`date +%Y-%m-%d_%H%M`), **not a sequence number** —
  parallel sessions cannot see each other, so a counter collides.
- Propose State edits; **only the manager role edits `State.md`, and only after
  an explicit human yes.**
- Commit on `agent/<role>`, open a PR. Never commit to the default branch.

## Two rules that carry most of the value

**1. The reviewer is never the author.** Review happens in a fresh session under
the architect role, and it applies mutation testing — break the implementation
deliberately and confirm the suite fails. A suite that stays green against
broken code is not evidence.

**2. Label every claim MEASURED or REASONED.** If a platform behaviour was not
observed, say so. A reasoned answer written as a fact will be quoted back as one
weeks later, by which point nobody remembers it was a guess. When the answer
matters, write a probe — see `Docs/Probes.md`.

## The checks this hub ships with

Four scripts, all **detection only** — none of them edits anything, and none of
them decides anything.

| Script | Says |
|---|---|
| `scripts/queue-lint.sh` | whether the prompt queue still obeys its own rules |
| `scripts/state-drift.sh` | which role's `State.md` line is older than that role's newest session record, and when State is near its size budget |
| `scripts/size-budget.py` | which per-session file has outgrown what every session pays to read it |
| `scripts/setup-hooks.sh` | wires `.githooks/` — a commit subject carried to the dialog, and a warning when a commit spans more than one row |

Run once per clone:

```bash
bash scripts/setup-hooks.sh
```

## Scope discipline

Do the row that is open. If you find a defect outside it, **file it as a new row
and say so** — do not absorb it silently. An unstated gap is the problem; a
stated one is a decision.
