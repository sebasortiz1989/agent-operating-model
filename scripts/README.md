# scripts/

Four detection scripts and one setup script. **None of them edits a file, and none
decides anything.** They report and exit; a human still decides.

| Script | Hook | What it says |
|---|---|---|
| `queue-lint.sh` | `SessionStart` | whether `Plans/PROMPT_QUEUE.md` still obeys its own shape rules — index↔body one-to-one, `Parallel:` lines, numbering, cited paths. **An empty queue is clean** |
| `state-drift.sh` | `SessionStart` | which role's `State.md` line is older than that role's newest `Updates/` entry — **roles are read from `.claude/skills/`, never a table** — and a size census once State nears its budget |
| `size-budget.py` | `SessionStart` | every per-session file against its budget: State, the queue, the board, `CLAUDE.md`, `Working_Rules.md`, each skill, and **each role's skill + references together**. Silent when everything fits; `--report` prints all of it plus the cold-session floor |
| `setup-hooks.sh` | once per clone | points `core.hooksPath` at `.githooks/` — a commit subject carried to the dialog, a warning when a commit spans more than one row |

Wire the first three in `.claude/settings.json` under `SessionStart`. Then, once per clone:

```bash
bash scripts/setup-hooks.sh
```

## The generation line

Each script's second line reads `# hub-scripts generation YYYY-MM-DD`. **Keep it when you
copy the file into a project.** Six of these scripts once existed in five repositories at
four different generations, and the only way to tell was `wc -l` and a diff — which is how
a fixed defect was found still live in two of them. The line costs nothing and answers the
question before it is asked.

## Two things that break when ported, said out loud

- **`size-budget.py`'s `BUDGETS` list names this model's paths.** A project that renames
  them must change the list — a budget pointing at a file that does not exist is a check
  that always passes, which reads exactly like a check that works.
- **`state-drift.sh` needs `### <Role>` headings in `State.md`** whose text starts with a
  skill's name, title-cased. A hub whose State is organised by project rather than by role
  gets the size report only, and the script says so rather than passing silently.
