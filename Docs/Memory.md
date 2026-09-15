# Memory — what is shared, what stays isolated, and who pays for it

**Agent memory is not one thing, and treating it as one is how a hub becomes
unreadable.** Three kinds, with different rules, different costs and different
failure modes. The split is the design.

**Keep this under 4 KB.**

**Not here, because enforced elsewhere:** the size budgets themselves
(`Docs/Conventions.md`), the update format (`Updates/`), and why a file that
edits itself stops being trustworthy (README → *What this is not*).

## The two questions that scope everything

1. **Who pays to read it?** Anything every session reads is paid **once per role
   per session**, forever. That is a recurring cost against a fixed context
   budget, and it is the only cost that compounds.
2. **Who is harmed if it leaves?** Not *is it interesting* — **whose is it.**

Every rule below follows from one of those two.

## The three kinds

### 1. Current truth — read by everyone, every session

What is true **now**. Not how it got that way. Edited in place, curated by one
role, and **budgeted**, because its length is the recurring cost above.

> **The rule that keeps it small: a file every session reads carries the claim;
> the reasoning lives in the file that produced it.** When this file starts
> explaining itself, the explanation belongs somewhere else and a pointer stays.

**Failure mode:** it grows to hold the argument as well as the conclusion, and
then nobody reads it — at which point it is worse than absent, because it is
still cited.

### 2. The record — append-only, read on demand

Dated entries: what happened, what was decided, **why the obvious alternative
was rejected**. Cheap precisely because nobody reads it unless they need it, so
it has no budget.

**Append-only, and never edited afterwards.** A correction is the next entry,
not a rewrite of the last one. **An edited history cannot be trusted as
history**, and the second it can be revised, its only value is gone.

*This is what makes session two able to inherit session one's reasoning instead
of re-deriving it and landing somewhere else.*

### 3. Reference facts — durable, and provenance-carrying

The claims everything else is built from. Slow-changing, and each one marked
with **where it came from, when, and whether it was verified or assumed**.

> **A claim without provenance is not a fact.** *Measured* and *reasoned* are
> different words on purpose, and an unverified figure must say so in the same
> sentence it appears in — not in a footnote nobody carries forward.

**Corrections go to the source, never to the copy.** Fixing the artifact and
leaving the reference wrong guarantees the error returns, in something you are
not looking at, months later. **The copy is downstream. Always repair upstream.**

## Isolation — what may cross a boundary

**Default deny.** A fact crosses only deliberately, and **only with its
provenance attached.**

| Crosses freely | Never crosses |
|---|---|
| Conventions, rules, working practice | Anything owned by someone else — a client's, an employer's, a person's |
| Generalised lessons: the shape of a failure, not its subject | Anything that identifies a private product, including **the shape of the idea**, not merely its name |
| Measured results about the process itself | Anything whose leak is irreversible: credentials, financial positions, third-party data |

**The test for whether something may be shared: could you show it to the person
it is about?** Not *would they mind* — *would they recognise it.* A description
specific enough to identify its subject has already crossed, whether or not it
names anything.

**Isolation is per-subject, not per-repository.** Two projects belonging to the
same person still do not pool what belongs to a third party. The boundary
follows ownership, not directory structure.

## What none of this is

**Not a vector store, not retrieval, not an embedding.** These are files, with
rules about who writes them and who pays to read them. **The hard part of agent
memory has never been storage** — it is deciding what deserves to be re-read
every session, and what must never be re-read by anyone.
