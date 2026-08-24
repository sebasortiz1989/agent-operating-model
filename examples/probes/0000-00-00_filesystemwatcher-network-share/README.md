# Does `FileSystemWatcher` report every change on an SMB network share?

> ## ⚠️ This is an illustration, not a real probe
>
> **The findings below were not observed. They are invented to demonstrate the
> format.** A real probe's entire value is that its numbers came from a machine;
> these did not.
>
> It is marked this way deliberately, because the convention this repository
> argues for is precisely that a reasoned answer must never be presented as a
> measured one — and an unlabelled fake example would break that rule in the
> document that teaches it.
>
> **Delete this directory when you write your first real probe.**

A probe. Throwaway code kept as evidence — it ships nothing, no application code
imports it, and it is not a member of any build target. It records what was true
on the date below against the versions below. If it stops compiling in a year,
that is information, not a bug. Do not update it; run a new probe beside it.

## The question, in platform terms

A service watches a directory on an SMB share for incoming files and processes
each one. Documentation says `FileSystemWatcher` raises events for changes in a
watched directory. It does not say what happens when the underlying transport is
a network share, nor what happens when changes arrive faster than they are
drained.

Four sub-questions, all platform-level:

1. Are events raised at all for changes made by **another host** on the share,
   or only for changes made by the local process?
2. Under a burst of *N* file creations, are all *N* `Created` events raised?
3. When `InternalBufferSize` overflows, what is observable — an `Error` event,
   a silent gap, or both?
4. Does a single logical file write produce exactly one event?

## Verdict

**No — and the failure is silent by default.** Events are raised for remote
changes, but bursts overflow an internal buffer whose default size is small, and
the resulting gap is only visible if an `Error` handler is attached. A single
file write commonly produces more than one event. Treat this API as *a hint that
something changed*, never as an event log.

## Environment

Without this block the answers below are untrustworthy — you cannot tell whether
they still hold.

| | |
|---|---|
| Date | *illustrative* |
| Runtime | .NET 8.0.x |
| Host OS | Windows Server 2022 / Ubuntu 24.04 |
| Share | SMB 3.1.1 |
| Second host | required — question 1 cannot be answered from one machine |

## How to run it

```
dotnet run --project Probe.csproj -- --share \\host\share\watched
```

Writes a burst, counts events received against events expected, prints the
delta. Question 1 needs a second machine writing to the same share.

## Findings

| # | Question | Answer | MEASURED / REASONED |
|---|---|---|---|
| 1 | Remote-host changes raise events | Yes | *illustrative* |
| 2 | All *N* events raised under burst | **No** — drops begin at the default buffer size | *illustrative* |
| 3 | Overflow observable | Only via the `Error` event; **silent if unhandled** | *illustrative* |
| 4 | One write, one event | **No** — commonly two or three | *illustrative* |

### 3. Overflow is silent unless you ask for it

This is the finding that matters, and the one reasoning would miss. The absence
of events is indistinguishable from the absence of changes. A consumer written
against the documented behaviour looks correct, passes its tests against a local
directory, and loses files in production under load with nothing in the log.

### 4. One write is not one event

A create-then-write-then-close sequence surfaces as several notifications.
Any handler must be **idempotent**, and de-duplication belongs in the consumer,
not in a hope that the API will settle down.

## What this does not answer

- **NFS, or SMB below 3.0.** Only one share protocol was exercised.
- **Sustained load over hours.** This was a burst test, not a soak test.
- **macOS.** The `FSEvents` backing implementation differs and was not run.
- **Whether a polling reconciliation pass closes the gap.** Strongly implied as
  the fix, but that is a **REASONED** conclusion — it was not built or measured
  here, and a probe that recommends an untested remedy is overstepping.
