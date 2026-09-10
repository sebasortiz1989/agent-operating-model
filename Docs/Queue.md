# The prompt queue

**The board says what is being built. The queue says what happens next, and in what
order.** They are different questions and they live in different files:
`Plans/BOARD.md` is sized rows; `Plans/PROMPT_QUEUE.md` is the next few sessions, in
run order, each one ready to paste.

**Why it exists.** Without it, every session begins with the human re-deriving what
should happen next from a board of thirty rows, and re-typing a prompt they typed a
variant of yesterday. **The queue makes the next session a copy-paste**, and it makes
"what am I waiting on?" a file rather than a memory.

---

## The split: an index, and one file per prompt

```
Plans/PROMPT_QUEUE.md      the index — rules, run order, pairing, gates, flags, done
Plans/queue/N.md           one prompt body, N counting from 0
```

**The index holds no prompt bodies.** It stays short enough that every role opening it
reads all of it. A body that grew a page of reasoning does not push the index out of
readability, because it is not in the index.

**The queue is addressable.** A role told **"run prompt 3"** opens `Plans/queue/3.md`,
**confirms the role tag in the heading is its own**, reads back the `Parallel:` value,
and runs the fenced body as its starting message. **It stops if the tag names another
role, the number does not exist, or the title is struck.**

Addressing is an option, not a replacement — pasting the body works identically.

## The rules that are easy to get wrong

- **In run order, numbered from 0, contiguous.** A refresh **reorders**, which means
  `git mv` on the body files — not moving a block of text in the index. Renumbering the
  index without moving the files orphans every body.
- **A number is a position, not an identity.** Positions are reused as the queue moves,
  so the `Done` ledger lists titles **without** numbers, and nothing else cites a prompt
  number except the human, and only for today.
- **Five is the ceiling.** Past five it is a plan, and that is the board's job.
- **A body is a summary and then the prompt.** Above the fence: the `Parallel:` line,
  two to five lines of size / gate / what, and a suggested commit subject. Nothing else
  — reasoning goes inside the fence where the session reads it, or into `Updates/`.
- **A suggested commit subject is not permission to commit.** It exists so there is one
  ready when the human asks.
- **Striking is `git rm` on the body** plus one line in the `Done` ledger.
- **`Parallel:` is a permission, not an instruction.** Running one at a time is always
  allowed. And two prompts that touch different files are still unsafe together if both
  run a build in the same working tree.

## Gates and flags

**A gate is something only the human can clear** — a decision, a merge, a device check,
a go-ahead on a proposal. **No role runs one and no role waits quietly on one:** a gate
that blocks a prompt is named in that prompt's row as well.

Gates keep the things the human owes out of the flag list, where they would read as
problems rather than as decisions waiting on them.

- **A cleared gate is not shown.** Once cleared it is history, and history in a block
  every session reads is a cost every session pays. Drop it and leave a one-line pointer
  to the record. Nothing is deleted; it stops being carried.
- **Gate identifiers never renumber.** `G1` stays `G1` after `G2` clears — bodies cite
  them, and a number that moves is a dead address.

**A flag is a problem or an observation**, at most ten, each carrying the number of
passes it has been carried: `! [2]` blocking, `i [1]` looks like a problem and is not.
**A flag entering its fourth pass leaves the block** — it becomes a prompt if it is
actionable, or a line in `Docs/` if it is a standing condition. A flag carried forever
is a flag nobody reads.

---

## Showing the queue: a fenced monospace block, every time

**Whenever the queue reaches the chat — rebuilt, or asked for — it is a plain fenced
code block.** Never prose, never bullets, never a rendered widget. Reformatting it into
sentences makes the reader reconstruct the order, which is the exact failure "read it
top to bottom" exists to prevent.

**Use a plain fence, not a shell-tagged one.** A ```bash fence gets a Run button in some
clients, and the queue is not a command.

It carries, in this order: a header with the refresh date and the live count; the
`RUNNING ORDER` table; the pairing table; `GATES`; the suggested commit subjects; and
`FLAGS`.

### The column limit is the load-bearing part

**No line in the fence may exceed 78 columns.**

The failure it prevents is specific and does not look like a formatting problem. A row
ran to 98 characters. The reader's viewport soft-wrapped it, and **the overflow landed
at column 0 — which in a monospace table reads as a value in the first column.** The
reader saw a word sitting under `ROLE` that no session had ever put there.

**A wrapped line in this block does not look wrapped. It looks like data.** That is why
this is a hard limit and not a preference: the whole point of the fence is that a column
can be scanned, and a wrap silently invents an entry.

**The comment stays in its own column.** The tempting fix — move the long comment onto
full-width lines under the row — reads as prose attached to the role and loses the one
thing the table is for, which is scanning a single column downward. **Make the columns
fit; never abandon the last one.**

**Widths are forced, and they are arithmetic, not taste.** A four-column layout that
fits 78 with a 2-space left margin: `N` 3 · `ROLE` 14 · `WHAT` 18 · `COMMENTS` 41.
Add a fifth column and the comment column pays for it — decide which you would rather
have. **A role name longer than its column wraps inside that column**, and that is
correct. Wrap each cell independently and pad to the column, so a long comment grows the
row's **height** rather than its width.

**The commit subjects are a contiguous list — no blank line between them.** One line per
prompt, stacked, so the block is scanned rather than scrolled.

**Check it; do not eyeball it.** And scope the check to the fence — the prose around it
is markdown and wraps normally, so a whole-file check reports dozens of false positives
and teaches you to ignore the check:

````bash
python3 -c "
import pathlib
t=pathlib.Path('Plans/PROMPT_QUEUE.md').read_text()
s=t.index('  IN RUN ORDER.'); e=t.index('```',s)
bad=[(len(l),l) for l in t[s:e].splitlines() if len(l)>78]
print(f'{len(bad)} line(s) over 78 in the fence')
[print(f'  {n}: {l[:80]}') for n,l in bad]"
````

### The row prefix is parsed, so do not reflow it away

`scripts/queue-lint.sh` finds index rows with `^  ([0-9]+)  (/[a-z-]+)` — two spaces,
the number, two spaces, the role. **Change that prefix and every row becomes an
orphan.** `N` is 3 wide for exactly this reason.

**If your queue keeps its bodies inline instead of split, the linter should key on the
`## N — ` headings and this warning does not apply to you.** A rule that is false where
it is written is worse than no rule — say which shape your queue is, in the file that
carries the rule.

---

## What the linter checks

`scripts/queue-lint.sh` is detection only; it never edits the queue.

- every index row has a body file, and every body file has an index row
- each body's heading matches its filename
- numbering is contiguous from 0, with no duplicates
- every live prompt has a `Parallel:` line
- preambles are two to five lines
- struck prompts have no body left behind
- cross-references to prompt numbers that do not exist
- cited paths that are not on disk

**An empty queue is a legitimate state, not a failure.** A hub between passes has no
live prompt and nothing is wrong with it. A check that fails on every session of a
dormant project is a check nobody reads.
