#!/usr/bin/env python3
"""Fail loudly when a file every session reads has grown past its budget.

    python scripts/size-budget.py            # silent if healthy
    python scripts/size-budget.py --report   # print the table anyway

SILENT WHEN HEALTHY. THAT IS THE FEATURE.

Nobody wants to audit token cost by hand every session, and a hook that prints a
size census every session IS that audit, moved from the person to the terminal.
So this prints nothing at all while every tracked file is inside its budget, and
only speaks when one is not.

WHY BUDGETS AND NOT A CLEANUP HABIT

On the build this model came from, `State.md` reached 23,591 tokens and the
prompt queue 36,572, and one build session read ~155,000 tokens before writing a
line of code. None of that was one bad decision. It was every session appending
its full reasoning to a file that every later session must read - correct
locally, ruinous in aggregate, and invisible without measuring.

A number nobody is watching only moves one way.

THE RULE THE BUDGETS ENFORCE, stated in Docs/Conventions.md:

    A file that every session reads carries the CLAIM.
    The reasoning lives in the file that produced it.

Every breach is the same defect: a record written into a per-session file
instead of into Updates/, an ADR, a work order, or a dated archive.

PORTABLE ON PURPOSE. Hub content sits at the repository root in some projects and
one level down in others, so the root is detected rather than assumed. One
script, every project, no per-project fork to drift.

EDIT BUDGETS BEFORE YOU EDIT ANYTHING ELSE. The paths below are this model's
layout. A project that renames them must change this list - a budget pointing at
a file that does not exist is a check that always passes, which reads exactly
like a check that works.
"""
import pathlib
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent

# tokens ~= chars/4. Good enough to catch a file doubling, which is all this
# needs to catch.
BUDGETS = [
    ("State.md", 3_000,
     "claim only; the record goes to Updates/ and a dated archive"),
    ("Plans/PROMPT_QUEUE.md", 10_000,
     "live prompts only; rules in Docs/, history in the Done ledger"),
    ("Plans/BOARD.md", 8_000,
     "the index routes; it does not narrate"),
    ("Docs/Conventions.md", 11_000,
     "rules read once; if it grows, split it by subject"),
]
BOARD_BUDGET = 12_000
SKILL_BUDGET = 10_000

BOARD_WHY = ("a board row is id, size, gate and one-line status - the story of "
             "what a row turned out to be belongs to its work order")
SKILL_WHY = "a skill is instructions, not a knowledge base"


def hub_root():
    """Hub content is at the repo root, or one level down in a `Hub/` folder."""
    for candidate in (REPO, REPO / "Hub"):
        if (candidate / "State.md").is_file():
            return candidate
    return REPO


def rows():
    hub = hub_root()
    out = []

    def add(path, budget, why):
        if path.is_file():
            out.append((path.relative_to(REPO).as_posix(),
                        path.stat().st_size // 4, budget, why))

    for rel, budget, why in BUDGETS:
        add(hub / rel, budget, why)
    for skill in sorted((REPO / ".claude" / "skills").glob("*/SKILL.md")):
        add(skill, SKILL_BUDGET, SKILL_WHY)
    return out


def main():
    all_rows = rows()
    over = [r for r in all_rows if r[1] > r[2]]
    report = "--report" in sys.argv

    if not over and not report:
        return 0

    line = "-" * 64
    print(line)
    print(f"SIZE BUDGET - {len(over)} file(s) over. Every session pays this."
          if over else "SIZE BUDGET - all clear.")
    print(line)

    for path, n, budget, why in (all_rows if report else over):
        print(f"  [{'OVER' if n > budget else 'ok  '}] {n:>7,} / {budget:>6,}   {path}")
        if n > budget:
            print(f"           {why}")

    if over:
        print()
        print("  The rule, not the number: A FILE EVERY SESSION READS CARRIES THE")
        print("  CLAIM; THE REASONING LIVES IN THE FILE THAT PRODUCED IT.")
        print("  A breach is a record written into the wrong file - move it to")
        print("  Updates/, an ADR, a work order, or a dated archive. Do not")
        print("  delete it, and do not raise the budget to make this quiet.")
        print()

    print(line)
    return 1 if over else 0


if __name__ == "__main__":
    sys.exit(main())
