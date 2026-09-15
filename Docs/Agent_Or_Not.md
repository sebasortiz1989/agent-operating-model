# Agent, script, human, or a written note — choosing before you build

**The most expensive decision in an agent project is made before any of it is
built: what kind of thing this should be.** Four options, and three of them are
cheaper than an agent.

**Keep this under 4 KB.** It is read when something new is proposed, not every
session.

**Not here, because enforced elsewhere:** what the detection scripts do
(`scripts/`, and the README → *What this is not*), and the review gates that
apply once something *is* an agent (`Docs/Board.md`).

## The order, and it is an order

Work down it. Stop at the first line that fits. **Going down the list costs more
at every step**, so the discipline is to stop early, not to arrive at the answer
you wanted.

### 1. Does it need to exist at all?

Most proposed agents die here and should. *"We could automate this"* is not a
reason; it is an observation. **Ask what breaks if nobody does it.** If the
answer is *nothing measurable*, write the note and move on.

### 2. Must the answer be identical every run? → a script

**This is the hard line, and it is not a preference.** A check that returns
3,000 on Monday and 3,200 on Tuesday is not a check — it is a second opinion.
Gates, budgets, counts, conformance, lint: all deterministic, all scripts.

**An agent cannot be a gate.** It can *read* one. The moment a model is deciding
whether a threshold was crossed, the threshold has stopped existing.

*Corollary: if you find yourself writing "usually" or "should normally" into an
agent's instructions for something countable, you wanted a script.*

### 3. Is it irreversible, outward-facing, or someone else's to decide? → a human

Publishing, sending, deleting, paying, committing on someone's behalf. **An
agent may prepare all of it and must not be the one to release it.** The draft
is the agent's; the decision is not.

This is not distrust of the model. It is that **the cost of a wrong reversible
action is a retry, and the cost of a wrong irreversible one is unbounded** — and
nothing in a plausible-sounding answer distinguishes the two.

### 4. Does it need judgement against written rules, on input that varies? → an agent

This is the actual case for an agent, and it is narrower than it first looks.
**All three clauses must hold.** Judgement without written rules is improvisation
and will not be reproducible enough to review. Written rules without varying
input is a script. Varying input without judgement is a parser.

**If it qualifies, it inherits the gates** — the reviewer is not the author, and
claims are labelled measured or reasoned.

### 5. Otherwise → write it down

A documented process costs one write and never breaks, never drifts, never needs
a runtime. **It is the correct answer far more often than it is chosen**, because
it is the one that produces nothing to demo.

## What each wrong choice costs

| Wrong choice | What it costs |
|---|---|
| **Agent where a script belonged** | A gate that drifts — and worse, one that still *sounds* authoritative when it drifts. Nobody notices for weeks |
| **Script where an agent belonged** | Rules that grow a flag per exception until the flags contradict each other |
| **Agent where a human belonged** | One irreversible action taken on a confident misreading. The failure is rare, which is why it is not caught |
| **Anything where a note belonged** | Permanent maintenance for a problem nobody had |

## The two questions that settle most arguments

1. **If I run this twice on the same input, must I get the same answer?**
   Yes → script. **No exceptions**, however tempting the flexibility sounds.
2. **If this is wrong, what does it cost to undo?**
   Unbounded → a human releases it, whatever drafted it.

**Everything else is a judgement call, and judgement calls are the only place an
agent belongs.**
