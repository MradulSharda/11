---
name: prolog-dev
description: Development guide, conventions, failure modes, and review checklist for SWI-Prolog 9.x
---
# Prolog Development Skill

## Environment & Language Version
- SWI-Prolog 9.x
- Allowed libraries: `lists`, `apply`, `yall`, `aggregate`.
- Strictly Forbidden: `assert`, `retract`, `b_setval`, `nb_setval`, top-level initialization directives (`:- initialization`), and calling `halt/0`.

## Coding Conventions
- Predicates named in lowercase `snake_case`.
- Pure declarative style with explicit base cases and recursive clauses.
- Order clauses from specific base cases to general recursive cases.
- Deterministic behavior: prevent unintended infinite loops or spurious choice points on backtracking.

## How to Run and Test
- Test via terminal: `swipl -q -f code/11_q1.pl -g "<goal>" -t halt`
- Run main entrypoint: `swipl -q -f code/11_q1.pl -g main -t halt`

## Known AI Failure Modes in Prolog
1. **Unintended Infinite Recursion / Looping:** Generative models often generate left-recursive rules or forget terminating guards, causing stack overflows or hangs instead of failing cleanly.
2. **Imperative Fallback:** Using side-effects like `assert/1`, `retract/1`, or global state (`b_setval`) instead of passing state declaratively through predicate arguments.
3. **Hardcoding Search Outputs:** Printing hardcoded solution values instead of formulating relational constraints that Prolog's unification engine derives dynamically.
4. **Incorrect Operator / Negation Semantics:** Confusing `\=` (unification failure) with `=\=` (arithmetic value comparison), or misplacing `\+` negation before variables are properly bound.

## Self-Review Checklist
1. Are any forbidden built-ins (`assert`, `retract`, global state, directives) used?
2. Does the predicate fail cleanly rather than looping infinitely on impossible queries?
3. Are all variables properly scoped and bound before being tested with negation?
4. Does the file contain only pure definitions without executing queries at load time?
