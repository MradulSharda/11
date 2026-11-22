---
name: prolog-dev
description: Development guide, conventions, and review checklist for SWI-Prolog 9.x
---
# Prolog Development Skill

## Environment & Language Version
- SWI-Prolog 9.x
- Allowed libraries: `lists`, `apply`, `yall`, `aggregate`.
- Forbidden: `assert`, `retract`, `b_setval`, `nb_setval`, top-level initialization directives, calling `halt/0`.

## Coding Conventions
- Meaningful predicate names in `snake_case`.
- Pure declarative style with clear base and recursive cases.
- Determinism where appropriate (avoid unintended choice points using cuts or clean guards).

## Running and Testing
- Execute via terminal: `swipl -q -f <file>.pl -g "<goal>" -t halt`

## Self-Review Checklist
1. Are any forbidden built-ins (`assert`, `retract`, global state) used?
2. Does the predicate fail gracefully instead of throwing errors or looping infinitely?
3. Does the file contain only definitions (no initialization directives)?