---
name: tsql-study-guide
description: House conventions for the T-SQL-Material study repo. Use when creating a new NN- topic folder, writing examples.sql, adding interview-ready answers, updating the root README table, or checking T-SQL 2019-only syntax.
---

# T-SQL Study Guide

Conventions for `T-SQL-Material` (SQL Server 2019 interview prep, Markdown + runnable `.sql`).

## Topic folders

- Name: `NN-kebab-case/` (`00` start-here → up; numbers = difficulty order).
- Each folder: `README.md` + `examples.sql` (+ optional `*-in-detail.md` + its `.sql`).
- README order: Goal → Definition → Sample Tables → Examples → Query Breakdown →
  Edge Cases → Scenario Questions → Cheat Recap.
- Definition block: What it is / Why introduced / Problem solved / italic
  **Interview-ready answer** in simple spoken English (short words, keep exact keywords).
- Wire every folder into root `README.md` (table row, cheat line, study order, roadmap).

## examples.sql law

- Self-contained + F5-clean on 2019: create demo objects, drop them, live demos only.
- `CREATE VIEW/PROC/FUNCTION/TRIGGER` first in batch (GO walls); views never on `#temp`;
  `#temp` dies across `EXEC` scope; `OFFSET` needs `ORDER BY`.
- T-SQL only: `TOP`/`OFFSET-FETCH`, `+` concat, `EXCEPT`, no `LIMIT`/`MINUS`/`||`/`NULLS FIRST`.
- Gotchas to respect: `COUNT(col)` skips NULLs, `NOT IN` + NULL empties, `5--2` = 5,
  `IDENT_CURRENT` needs exact non-temp names.

## Style

- Tables first for comparable items; full explanations (no terse mode here).
- No source links in docs. Never install toolchains automatically.
