# Board

**Living document, updated in place, deliberately undated.** Holds order and
status only — ticket bodies live in dated spec files beside this one.

Conventions, row naming and sizing: `Docs/Board.md`.

| | |
|---|---|
| Rows | 0 — 0 struck, 0 open |
| Remaining | 0–0 build hours |
| Pace | <N> build hrs/week → <N>–<N> weeks |

---

## Sequence

| # | Ticket | Prefix | Build hrs | Cumulative | Gate | Status |
|---|---|---|---|---|---|---|
| 1 | **<X1>** <one-line title> | web | 4–6 | 6 | none | open |
| 2 | **<X2>** <one-line title> | web | 8–12 | 18 | `web/X1` | open |

Strike a done row by wrapping every cell in `~~`, and append how it closed —
what the review found, and whether the hand check ran.

## Where ticket bodies live

| Row | Body |
|---|---|
| `web/X1` | `Plans/YYYY-MM-DD_x1-spec.md` |

## Checkpoints — where work stops for a check

| Row | Review | Hand check |
|---|---|---|
| `web/X1` | on the PR — <what specifically the reviewer must confirm> | after merge — <what only a human on a real device can show> |

## The arithmetic, shown

Every change to the remaining total gets a line. The total must be
reconstructable from this table; a number that cannot be audited drifts.

| Change | Low | High |
|---|---|---|
| Phase as opened | 0 | 0 |
| `web/X1` filed | +4 | +6 |
| **Total** | **4** | **6** |

## Blocked — do not start

| Row | Blocked on |
|---|---|

## Retired — left the board without being built

| Row | Why, and the condition that would revive it |
|---|---|
