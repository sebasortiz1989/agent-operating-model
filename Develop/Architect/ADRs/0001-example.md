# ADR-0001 — Work is tracked in the repository, not an external tracker

**Status:** Accepted
**Date:** YYYY-MM-DD

> Example ADR. It is real in form and shows what the *Alternatives rejected*
> section is for. Delete it when you file your first genuine decision.

## Context

Work has to be tracked somewhere both a human and an agent can read. An agent
session cannot see a browser-based tracker, so any board living outside the
repository is invisible at exactly the moment it is needed — when an agent is
deciding what to do next and what "done" means.

Splitting the difference — tracker for humans, markdown summary for agents —
was considered and is the worst option: two sources of truth that disagree
within a week, with no mechanism to notice the drift.

## Decision

The board is `Plans/BOARD.md`, a markdown file in this repository. It holds
**order and status only.** Ticket bodies live in dated spec files. Every change
to the remaining hour total is recorded in a delta table beneath the board.

## Alternatives rejected

- **Jira / Linear / GitHub Projects.** Better tooling, better reporting,
  invisible to the agent. Rejected on that alone.
- **GitHub Issues.** Readable by an agent through an API, but the ordering and
  sizing model is weak, and the delta table has nowhere to live.
- **Tracker plus a synced markdown mirror.** Two sources of truth. A sync check
  reports "in sync" right up until it is comparing against the wrong thing.

## Consequences

**Cheap:** an agent reads the board directly at session start. Board history is
in git alongside the code it describes. The remaining total is auditable line by
line.

**Expensive:** no burndown charts, no dependency graph, no notifications. Board
edits can conflict when two sessions touch it, which is a real cost and the main
argument the rejected options had going for them.
