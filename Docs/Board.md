# The board

Work lives in `Plans/BOARD.md`. It is a living document, updated in place, and
deliberately undated — it holds **order and status only.** Ticket bodies live in
dated spec files, never on the board.

## Why a markdown board

Because the agent can read it. An external tracker is a second place the truth
lives, and the one the agent cannot see.

## Row naming

```
<prefix>/<Letter><Number>        e.g. web/A1, api/B2
```

The prefix is the product repo. The letter groups a theme; the number sequences
within it. A row filed out of a review keeps the letter of the row that produced
it — so `web/A4` and `web/A5` are visibly the tail of `web/A1`, not new work.

## Columns

| Column | Holds |
|---|---|
| # | Order |
| Ticket | Row name and one-line title |
| Build hrs | A **range**, low–high |
| Cumulative | Running total |
| Gate | What must be struck first |
| Status | `open`, `blocked`, or struck through when done |

## Sizing

Estimate in **hours, as a range**, never in points. Points obscure; a range
tells you the uncertainty as well as the size.

Keep a **delta table** below the board recording every change to the total —
every row filed, struck, re-sized or moved, with its own line. This is what
makes the remaining total auditable rather than asserted. Numbers that cannot be
reconstructed from a change log get quietly wrong.

**Build hours are engineering size, not calendar time.** A row can sit open for
a week and strike in one session when review passes. To convert to a calendar
estimate, divide by real weekly build hours — measure those from commit
timestamps rather than assuming them.

## Gates

Two, and both are named on the row:

- **Review** — an independent pass in a fresh session, with mutation testing.
- **Hand check** — a human uses the real thing, on the real device. Written as
  *what specifically to check*, not "test it".

A row does not strike until both are satisfied, or until the human explicitly
rules that one is being skipped — **in which case the board records the skip.**
An unstated gap is the problem; a stated one is a decision.

## Discovered work

A review that finds a defect files a **new row**. It does not expand the row
under review. This keeps sizes honest and makes the cost of a decision visible
after the fact.
