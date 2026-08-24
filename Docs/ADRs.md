# Architecture Decision Records

One markdown file per significant, cross-cutting decision that outlives the
session that made it. Owned by the architect role.

## Naming

```
Develop/Architect/ADRs/NNNN-short-title.md
```

Zero-padded, sequential. Status lives inside the file: `Proposed`, `Accepted`,
or `Superseded by ADR-NNNN`.

## When to write one

- Choices that are expensive to reverse
- Rules other roles must obey (git, CI, promotion, API policy)
- Security, secrets, or observability baselines spanning repos
- **A decision that ruled something out.** The rejected option is the part
  nobody remembers and everyone re-proposes.

## When not to

- Single-repo implementation detail with no cross-cutting impact
- Undecided brainstorming — wait until the decision is real
- Feature behaviour, which belongs in a spec and a board row

## Superseding

Never edit an accepted ADR's decision. **Write a new one and mark the old
superseded**, naming which sections fall and which still stand. Partial
supersession is normal and must be explicit — an ADR marked wholly dead when
half of it still binds is how a live rule gets lost.

Amendments are the lighter form: append a dated `## Amendment N` when the
decision holds but its detail moved.

## Template

```markdown
# ADR-NNNN — Title

**Status:** Proposed | Accepted | Superseded by ADR-NNNN
**Date:** YYYY-MM-DD

## Context
<What forced a decision. Include the constraint that made the obvious answer wrong.>

## Decision
<What was decided, in the imperative.>

## Alternatives rejected
<Each with the reason. This section is the one that pays off later.>

## Consequences
<What this now makes cheap, and what it makes expensive.>
```

## Index

Keep a table of every ADR and its live status in
`Develop/Architect/ADRs/README.md`. A directory listing is not an index —
it does not say which ones still bind.
