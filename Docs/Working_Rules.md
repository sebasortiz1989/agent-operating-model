# Working rules — how a session behaves before it writes anything

**Rewritten from `multica-ai/andrej-karpathy-skills`
(`skills/karpathy-guidelines/SKILL.md`, MIT) against this model's own precedent.
One clause is deliberately not adopted — §3.**

**Tradeoff: these bias toward caution over speed.** For a trivial task, use judgment.

**Binds every role**, hardest on the implementing ones. **Keep it under 3 KB** — a file
every session reads pays for its own length.

**Not here, because enforced elsewhere:** review gates and mutation testing
(`Docs/Board.md`, the architect skill), the MEASURED/REASONED label (`Docs/Probes.md`),
and filing an out-of-row defect rather than absorbing it (`Docs/Conventions.md` → Scope).

## 1. Say what you assumed before you build on it

- **State assumptions explicitly.** If the answer changes what gets built, ask.
- **Two readings? Present both.** Picking one silently builds the wrong row — and then
  writes tests that agree with it.
- **A simpler approach? Say so, and push back.**
- **Unclear? Stop and name what is confusing.**

*A question about an acceptance criterion costs one message. Answering it silently and
wrongly costs the row, the review and the rework.*

## 2. The minimum that solves the problem

No features beyond the ask. No abstraction for a single use. No configurability nobody
requested. No error handling for impossible states.

**If you wrote 200 lines and it could be 50, rewrite it.** The test: would a senior
engineer call this overcomplicated?

**Split by seam, never by size.** A file created because another one got long has no
reason to exist, and the split will not survive the next feature.

## 3. Surgical — every changed line traces to the request

- Do not improve adjacent code, comments or formatting.
- Do not refactor what is not broken; match the surrounding style.
- Remove the imports and locals **your** change orphaned. Nothing else.

*The failure this prevents: the unreviewed refactor riding along inside an approved
row. The reviewer signed off on the row; the refactor arrived free.*

**⚠ NOT ADOPTED:** the source says *"notice unrelated dead code — mention it, don't
delete it."* Here the bar is higher: **notice it and FILE it as a board row.** Never
delete it inside an unrelated row; never stay silent either. A mention in chat is not a
record — see `Docs/Conventions.md` → Scope.

## 4. Define done before you start

Turn the task into something checkable:

- *"Add validation"* → write tests for the invalid inputs, then make them pass
- *"Fix the bug"* → write a test that reproduces it, then make it pass
- *"Refactor X"* → the suite passes before and after

For a multi-step task, state the plan before the first step:

```
1. [step] → verify: [check]
2. [step] → verify: [check]
```

**Weak criteria ("make it work") need constant clarification. Strong ones let a session
run alone** — and the bar is set at the start, not discovered at review.
