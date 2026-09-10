# Session records

One file per session:

```
YYYY-MM-DD_HHMM_<role>_short-topic.md
```

**`HHMM` is the clock time you create the file** — `date +%Y-%m-%d_%H%M` — not a
sequence number.

**Why the clock and not a counter.** A counter requires knowing what else was
written today. **Parallel sessions cannot see each other**: two of them on the
same day both reach for `_02_`, and one silently overwrites the other, or two
files claim the same position in a record whose whole value is that it is
append-only. The clock cannot collide that way, and it sorts the same.

**If you are changing an existing hub over, leave the old filenames alone.** The
folder is append-only and other files cite it by name; the convention changes
going forward.

## Why these exist

An agent has no memory between sessions. This directory is the memory. Written
well, a record lets a session with zero context pick up a thread without
re-deriving the reasoning — which is the entire point, and the reason a record
that only lists files touched is worthless.

## What a record contains

```markdown
# YYYY-MM-DD — <Role> — <what happened, in a phrase>

**Trigger:** <what started this — a request, a review finding, a board row>

## What was decided
<The call, and the reasoning that is not obvious from the outcome.>

## What was built
<Artifacts, with paths. Board rows touched.>

## What it cost
<Hours or row sizes. What was filed as a result.>

## What is still owed
<Explicitly. This is the section the next session reads first.>

## State paste — PROPOSED, not applied
<The exact lines proposed for State.md, formatted to that file's own rules.
Needs an explicit human yes before it lands.>
```

## The rule that makes them worth reading

**Record what failed.** A session record that only lists successes is a record
nobody can learn from, and it makes the next session repeat the same dead end.
If a step failed, if a probe came back no, if a mutation survived — write it
down with the outcome, not the intent.
