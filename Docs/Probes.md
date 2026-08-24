# Probes — measured, not reasoned

A **probe** is throwaway code written to answer a question the platform will not
answer in documentation. It ships nothing.

The usual instinct is to delete it once the finding is written down. **Don't.**
A findings document says *what* was true. The probe says *how we know.* When the
question returns — in this project or a different one — the probe is
reproducible evidence rather than a claim someone has to trust or re-derive.

## Why this exists

An AI agent asked "does this platform API do X?" will answer. The answer will be
fluent, structured, and frequently wrong — not because the model is careless,
but because plausible-sounding platform behaviour is exactly the kind of thing
that is under-documented and over-represented in training data as folklore.

The failure mode is not that the agent guesses. It is that **the guess enters
the written record indistinguishable from a measurement**, and three weeks later
an architectural decision rests on it.

A probe is the cheapest available fix: stop reasoning, run it, write down what
happened.

## Where they live

In the **product repository**, not the hub — the code belongs next to the
platform it was probing.

```
Probes/
  YYYY-MM-DD_short-question/
    README.md          <- the question, the verdict, the environment
    <source files>
    run.sh             <- optional, but a probe nobody can re-run decays fast
```

## The five rules

1. **Never a member of a build target.** A probe in the app target ships in the
   binary. Excluded from every target, every scheme, always.

2. **Never imported by application code.** A probe is evidence, not a library.
   If its approach is worth shipping it gets **rewritten** into the app
   properly, with tests. The probe stays as it was on the day it ran.

3. **Never updated to keep it compiling.** It records what was true on a date
   against a version. A probe that no longer builds has told you the platform
   moved — that is information, not a bug. Fix it only by running a **new**
   probe beside it.

4. **The README carries the environment or the probe is worthless.** Toolchain
   version, OS version, simulator or physical device, date. Without them a
   future reader cannot tell whether the answer still holds, and an answer of
   unknown vintage is not an answer.

5. **Failed probes are kept too — they are the more valuable half.** A probe
   that says *"we tried this and the platform will not do it"* saves the next
   person the entire session. Keeping only the ones that passed turns the
   archive into a place where every idea worked, which is a lie that costs real
   hours.

## The README is written for a stranger

The reason to keep probes is to reference them **from other projects**. So the
README is written for someone with **no context on your product**: state the
question in **platform terms**, not product terms.

> ✅ "Does `FileSystemWatcher` raise an event for every file created on an SMB
> share, and what happens when the internal buffer overflows?"
>
> ❌ "Can we use a file watcher for the ingest queue?"

The second is unreadable in eighteen months, and unreadable today by anyone who
is not you.

## Marking measured versus reasoned

Every answer in a probe README is labelled:

- **MEASURED** — the probe ran and this is what happened.
- **REASONED** — inferred from what was measured, but not itself observed.

Keep them visually distinct and never blur the line. A probe that launders a
guess into a fact is worse than no probe, because a fact gets quoted and a guess
gets checked.

## README template

```markdown
# <The question, in platform terms>

A probe. Throwaway code kept as evidence — it ships nothing, no application code
imports it, and it is not a member of any build target. It records what was true
on the date below against the versions below. If it stops compiling in a year,
that is information, not a bug. Do not update it; run a new probe beside it.

## The question, in platform terms
<Restate precisely. Break into numbered sub-questions if there is more than one.>

## Verdict
<One paragraph. Lead with yes or no.>

## Environment
| | |
|---|---|
| Date | YYYY-MM-DD |
| Toolchain | |
| OS / SDK | |
| Device | simulator or physical — say which |
| Physical hardware | tested / **not tested** |

## How to run it
<Exact command.>

## Findings
| # | Question | Answer | MEASURED / REASONED |
|---|---|---|---|

## What this does not answer
<The limits. This section is not optional — a probe that claims no limits is
claiming to have tested everything.>
```

A real example, kept exactly as it was written:
[`examples/probes/`](../examples/probes/0000-00-00_filesystemwatcher-network-share/README.md) — a filled-in illustration of this format, clearly labelled as such
