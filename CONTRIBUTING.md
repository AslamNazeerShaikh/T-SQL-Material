# Contributing to T-SQL Study

This is a study repo built for interview prep — and study notes can be wrong.
**Corrections, fixes, and improvements are always welcome through PRs.**

## What you can contribute

| Contribution (type) | Examples |
|---|---|
| Fixes (correctness) | Wrong query, wrong definition, bad output table, T-SQL that fails on SQL Server 2019 |
| Improvements (clarity) | Simpler wording, better example, missing edge case, extra scenario question |
| New topics (growth) | Next `NN-...` folder from the Level 2 roadmap in the root README |
| Deep-dives (detail) | `*-in-detail.md` companion docs like the one in `01-sql-statement-types/` |

## How to send a PR

1. Fork the repo and create a branch: `git checkout -b fix/union-null-handling`.
2. Make your change (keep the folder conventions below).
3. Test every `.sql` file top-to-bottom on SQL Server 2019+ (SSMS / Azure Data Studio, F5 clean).
4. Commit with a clear message: `Fix HAVING-without-GROUP-BY output in 06` beats `update`.
5. Open the PR with: what was wrong, what you changed, how you tested it.

Small focused PRs (one topic per PR) get reviewed fastest.

## Folder conventions (so PRs stay mergeable)

- One topic per folder: `NN-kebab-case-name/` (`NN` = difficulty order, next free number).
- Every folder must have `README.md` + `examples.sql`.
- README sections in order: Goal → Definition → Sample Tables → Examples → Query
  Breakdown → Edge Cases → Scenario Questions → Cheat Recap.
- `examples.sql` must be self-contained: create its own tables (`#Temp` or uniquely
  named), run with F5, leave no mess behind.

## A note on accuracy

SQL Server behavior varies by version, patch, collation, and settings — an example
that works on one setup can fail on another. If you spot anything wrong, outdated,
or misleading, open a PR (or an issue with the failing script + your version).
There are no bad corrections here; a wrong note fixed helps every future reader.

## Ground rules

- Keep it T-SQL / SQL Server 2019 focused — no other engines.
- Keep spoken answers simple: short words, short sentences (many readers are
  non-native English speakers).
- No dumps of copyrighted material (books, paid courses, exam papers).
- Be kind in reviews — this repo exists to help people get jobs.
