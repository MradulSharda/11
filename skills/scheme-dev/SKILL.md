---
name: scheme-dev
description: Development guide, conventions, and review checklist for Racket 8.x (#lang racket/base)
---
# Scheme Development Skill

## Environment & Language Version
- Racket 8.x with `#lang racket/base`.
- Strictly restricted primitives: `define`, `lambda`, `let`, `let*`, `letrec`, `named let`, `if`, `cond`, `and`, `or`, `not`, `begin`, `'`, `cons`, `car`, `cdr`, `list`, compositions of car/cdr up to 4 levels, `null?`, `pair?`, `eq?`, `assq`, `assoc`, `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max`, `display`, `newline` (and `read` in S2).
- Forbidden: `set!`, `append`, `length`, `map`, `filter`, `member`, strings, vectors, hash tables, loops. All utilities must be implemented from scratch.

## Coding Conventions
- Prefer tail recursion for accumulators to prevent stack overflow on large inputs (e.g. 10,000 elements / depth 100).
- Pure functional paradigm: no side effects except required `display`/`newline`.

## Running and Testing
- Run via terminal: `racket <file>.rkt`

## Self-Review Checklist
1. Are only the explicitly allowed built-ins used?
2. Is tail recursion used where list processing could exceed default stack depths?
3. Are there no top-level prints or test executions in the submitted solution file?