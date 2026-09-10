# Prompt bodies — one file per prompt

`N.md`, counting from 0, matching the index in `Plans/PROMPT_QUEUE.md` one-to-one.
`scripts/queue-lint.sh` fails on a body with no index row and on an index row with no
body. The rules are in `Docs/Queue.md`.

## The shape

```markdown
# N — `/role` · what this prompt is

**Parallel:** <safe with X | not safe with Y, and why | nothing else in this pass>

Two to five lines. Size, what gates it, what the work is. **Nothing else** —
reasoning goes inside the fence, where the session actually reads it, or into
`Updates/`, where it becomes the record.

**Suggested commit subject:** `[add] what happened, in the repo's own style`

​```
The prompt itself, verbatim, ready to paste or to run by address.

It states the row, the acceptance criteria, and what "done" looks like —
per Docs/Working_Rules.md §4, the bar is set here, at the start, not
discovered at review.
​```
```

## Why the preamble is capped at five lines

The preamble is read by a human deciding what to run next. The fence is read by the
session doing the work. **Reasoning in the preamble is read by everyone and used by
nobody** — it pushes the runnable part below the fold and makes the index long enough
that roles stop reading all of it.

## Striking

`git rm Plans/queue/N.md`, plus one line in the index's `## Done` ledger. Then
renumber the remaining bodies with `git mv` so the sequence stays contiguous from 0 —
**renumbering the index without moving the files orphans every body.**
