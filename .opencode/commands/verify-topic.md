---
description: Validate a topic folder against house conventions (README sections, runnable SQL, root README wiring).
---

Verify topic folder `$ARGUMENTS` (e.g. `/verify-topic 16-window-functions`):

1. Folder exists as `NN-kebab-case/`; `README.md` + `examples.sql` both present.
2. README sections in order: Goal → Definition (What/Why/Problem + Interview-ready
   answer) → Sample Tables → Examples → Query Breakdown → Edge Cases →
   Scenario Questions → Cheat Recap.
3. `examples.sql` claims self-contained: creates its demo objects, drops them,
   F5-clean shapes only (flag any batch-killer, unclosed comment, or `#temp`
   crossing `EXEC`/view scope).
4. Root `README.md` lists the folder in the table + cheat sheet with the next
   free number holding.
5. T-SQL-only scan: flag `LIMIT`, `MINUS`, `||` concat, `NULLS FIRST`, backticks.

Report a table: Check (metric) | Pass/Fail | Detail (file:line). Do not fix —
list fixes as follow-ups.
