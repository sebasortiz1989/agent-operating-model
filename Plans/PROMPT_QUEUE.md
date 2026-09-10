# Prompt queue — the index

**Living document, updated in place.** The rules live in `Docs/Queue.md`; this file
carries the run order, the pairing table, the gates, the flags and the done ledger.

**Last refreshed:** — · **Live prompts:** 0

**Show this in chat as a plain fenced block** — the `RUNNING ORDER` table, the pairing
table, `GATES`, the commit subjects and `FLAGS`. Never prose, never bullets. Plain
fence, never a shell-tagged one: a `bash` fence gets a Run button in some clients and
the queue is not a command. Protocol: `Docs/Queue.md` → **Showing the queue**.

---

## How to use it

**The queue is addressable.** Any role told **"run prompt 3"** opens
`Plans/queue/3.md`, **confirms the role tag in the heading is its own**, reads back the
`**Parallel:**` value, and runs the fenced body as its starting message. **It stops if
the tag names another role, the number does not exist, or the title is struck.**

Addressing is an option, not a replacement — pasting the body works identically.

- **THE FILE IS IN RUN ORDER.** Prompt `N` is the `N`th thing to run. A refresh
  **reorders** the prompts, which means `git mv` on `Plans/queue/N.md`, not moving a
  block of text. Reading top to bottom *is* the plan.
- **NUMBERING STARTS AT 0**, contiguous, every refresh.
- **A NUMBER IS A POSITION, NOT AN IDENTITY.** Positions are reused, so `## Done` lists
  titles **without** numbers.
- **FIVE IS THE CEILING.** Past five it is a plan, and that is `Plans/BOARD.md`'s job.
- **THE INDEX HOLDS NO PROMPT BODIES.** Striking a prompt is `git rm` on its body plus
  one line in `## Done`.
- **A SUGGESTED COMMIT SUBJECT IS NOT PERMISSION TO COMMIT.** It exists so there is one
  ready when the human asks.

---

## RUNNING ORDER — and what may run beside what

```
  IN RUN ORDER. Top to bottom is the order to run them.
  BODY: Plans/queue/<N>.md — open that file, not this one.

  N  ROLE          WHAT              COMMENTS
  --------------------------------------------------------------------------
  -- none --

  THE QUEUE IS EMPTY. That is a legitimate state, not an oversight — a hub
  between passes has no live prompt and nothing is wrong with it.

  Widths are forced and they are arithmetic: N 3, ROLE 14, WHAT 18,
  COMMENTS 41, plus a 2-space left margin = 78 exactly. No line in this
  fence may exceed 78 columns. Docs/Queue.md says why, and it is not a
  formatting preference.


  PAIR    FILES  ORDER  NOTE
  --------------------------------------------------------------------------
  -- nothing live to pair --

  FILES asks CAN THESE TWO WRITE AT ONCE. ORDER asks DOES ONE NEED THE
  OTHER'S RESULT. They are different questions and they disagree often
  enough to be worth separating — and two prompts touching different files
  are still unsafe together if both run a build in one working tree.


  GATES — human only, not role prompts
  --------------------------------------------------------------------------
  -- none open --

  A gate is something only the human can clear: a decision, a merge, a
  device check, a go-ahead. No role runs one and no role waits quietly on
  one — a gate that blocks a prompt is named in that prompt's row as well.
  A CLEARED GATE IS NOT SHOWN; leave a one-line pointer to the record.
  Gate identifiers never renumber: G1 stays G1 after G2 clears.


  SUGGESTED COMMIT SUBJECT — copy the line for the prompt you just finished
  --------------------------------------------------------------------------
  -- none live --

  One line per prompt, CONTIGUOUS — no blank line between them, so the
  block is scanned rather than scrolled.


  FLAGS — at most ten, and each says how many passes it has been carried
  --------------------------------------------------------------------------
  -- none --

  ! is a blocking or budget problem. i is something that looks like a
  problem and is not. A flag entering its FOURTH pass leaves this block: a
  prompt if it is actionable, a line in Docs/ if it is a standing
  condition. A flag carried forever is a flag nobody reads.
```

---

## Done

*Titles only, without numbers — a number is a position and positions are reused.*

*(nothing yet)*
