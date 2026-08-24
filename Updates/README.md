# Session records

One file per session:

```
YYYY-MM-DD_NN_<role>_short-topic.md
```

`NN` is a per-day sequence, so two sessions on one day sort correctly.

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
