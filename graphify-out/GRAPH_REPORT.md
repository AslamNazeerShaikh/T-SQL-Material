# Graph Report - T-SQL-Study  (2026-09-23)

## Corpus Check
- 91 files · ~59,616 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 627 nodes · 554 edges · 92 communities (59 shown, 30 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f4e7d8a1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- What You Must Do When Invoked
- opencode.json
- 03 — Types of Keys in SQL Server
- System Functions by Category (MS-Learn Map + Popular Picks)
- DDL, DML, DQL, DCL, TCL — Full Detail
- 02 — Character Data Types in SQL Server
- 01 — Types of SQL / T-SQL Statements
- 10 — Clustered vs Non-Clustered Index
- 05 — Query vs Subquery
- 07 — SQL Joins
- 09 — CTE (Common Table Expression)
- 12 — NULL Handling (IS NULL, ISNULL vs COALESCE)
- 13 — ORDER BY, TOP, DISTINCT (Ordered, Limited, Unique Lists)
- 16 — Window Functions (Rank, Totals, Shifts, Nth Pay)
- 18 — Views (Saved Queries as Virtual Tables)
- Error Handling — TRY/CATCH, ERROR_* Readers, THROW, XACT_STATE
- Procs Deep-Dive — System vs User, Params, Where-Usable Matrix
- Functions Deep-Dive — Built-ins, Determinism, Where-Usable Matrix
- 21 — Triggers (Auto-Run Rules on Write)
- 22 — Transactions + ACID (Deals, Locks, Deadlocks)
- 26 — Query Optimization Basics (Plans, Seeks, Sargability)
- 27 — Data Types: Numbers, Dates, Specials (IDENTITY, SEQUENCE, XML, Bits)
- 00 — SQL Comments in T-SQL
- Modern Syntax + Session Settings (T-SQL vs SQL, GO, SET Knobs)
- 04 — Constraints in SQL Server
- 06 — WHERE vs HAVING
- 08 — UNION vs UNION ALL
- Set Ops Beyond UNION — INTERSECT + EXCEPT
- 11 — GROUP BY + Aggregate Functions
- 14 — CASE Expression (If-Then in Queries)
- 15 — EXISTS vs IN (Match Tests + Anti-Joins)
- 17 — Temp Tables vs Table Variables (vs CTE)
- 19 — Stored Procedures (Saved Work + Params)
- 20 — Functions (Scalar vs Inline TVF vs Multi-Statement TVF)
- 23 — Normalization (1NF → 3NF + When to Break It)
- 24 — LIKE Pattern Matching (%, _, [], ESCAPE)
- 25 — Dynamic SQL + SQL Injection (Build Safe, Block Holes)
- graphify reference: extra exports and benchmark
- T-SQL Study — SQL Server 2019 Interview Prep
- Audit Options — Triggers vs Temporal Tables vs CDC
- Contributing to T-SQL Study
- Opencode Configuration for T-SQL-Material
- graphify reference: query, path, explain
- T-SQL Study Guide
- AGENTS.md
- graphify reference: add a URL and watch a folder
- graphify reference: commit hook and native CLAUDE.md integration
- graphify reference: incremental update and cluster-only
- sql-reviewer.md
- tsql-topic-writer.md
- default.md
- graphify.js
- graphify reference: GitHub clone and cross-repo merge
- graphify reference: transcribe video and audio
- extraction-spec.md
- 10-indexes/examples.sql
- 20-functions/examples.sql
- 23-normalization/examples.sql
- 26-query-optimization/examples.sql
- 03-keys/examples.sql
- 07-joins/examples.sql
- 17-temp-tables-vs-variables/examples.sql
- 18-views/examples.sql
- 19-stored-procedures/examples.sql
- 04-constraints/examples.sql
- 05-query-vs-subquery/examples.sql
- 08-union-vs-union-all/examples.sql
- 09-cte/examples.sql
- 15-exists-vs-in/examples.sql
- 21-triggers/examples.sql
- 27-data-types-numbers-dates/examples.sql
- 01-sql-statement-types/examples.sql
- 02-character-data-types/examples.sql
- 06-where-vs-having/examples.sql
- 11-group-by-aggregates/examples.sql
- 12-null-handling/examples.sql
- 13-order-by-top-distinct/examples.sql
- 14-case-expression/examples.sql
- 16-window-functions/examples.sql
- error-handling-examples.sql
- temporal-tables-examples.sql
- 22-transactions-acid/examples.sql
- 24-like-pattern-matching/examples.sql
- 25-dynamic-sql-injection/examples.sql
- Security Policy
- bash
- run_all.py
- query-testing — live verification against SQL Server 2025
- summary.md

## God Nodes (most connected - your core abstractions)
1. `bash` - 33 edges
2. `System Functions by Category (MS-Learn Map + Popular Picks)` - 14 edges
3. `What You Must Do When Invoked` - 12 edges
4. `DDL, DML, DQL, DCL, TCL — Full Detail` - 12 edges
5. `02 — Character Data Types in SQL Server` - 11 edges
6. `/graphify` - 10 edges
7. `01 — Types of SQL / T-SQL Statements` - 10 edges
8. `10 — Clustered vs Non-Clustered Index` - 10 edges
9. `05 — Query vs Subquery` - 9 edges
10. `07 — SQL Joins` - 9 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (92 total, 30 thin omitted)

### Community 0 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (24): For /graphify add and --watch, For /graphify query, For the commit hook and native CLAUDE.md integration, For --update and --cluster-only, /graphify, Honesty Rules, Interpreter guard for subcommands, Part A - Structural extraction for code files (+16 more)

### Community 1 - "opencode.json"
Cohesion: 0.15
Nodes (12): enabled, headers, type, url, Authorization, instructions, lsp, mcp (+4 more)

### Community 2 - "03 — Types of Keys in SQL Server"
Cohesion: 0.13
Nodes (14): 03 — Types of Keys in SQL Server, 1. Sample tables, 2. The six keys, 3. Query breakdown, 4. Edge cases, 5. Interview scenario questions, Alternate Key — candidate key not chosen as PK, Candidate Key — *could* be the PK (+6 more)

### Community 3 - "System Functions by Category (MS-Learn Map + Popular Picks)"
Cohesion: 0.13
Nodes (14): 10. Cursor + rowset + skip-list (short), 11. Message + misc single-liners (asked by name), 1. String (most-asked family), 2. Date and time (second most-asked), 3. Conversion (TRY_ twins = interview gold), 4. Mathematical (popular numeric), 5. Aggregate extras (beyond `11`: GROUPING), 6. JSON (2016+, full-stack gold) (+6 more)

### Community 4 - "DDL, DML, DQL, DCL, TCL — Full Detail"
Cohesion: 0.15
Nodes (12): 1. DDL — Data Definition Language, 2. DML — Data Manipulation Language, 3. DQL — Data Query Language, 4. DCL — Data Control Language, 5. TCL — Transaction Control Language, Cheat recap, Comparison — all five side by side, DDL, DML, DQL, DCL, TCL — Full Detail (+4 more)

### Community 5 - "02 — Character Data Types in SQL Server"
Cohesion: 0.17
Nodes (11): 02 — Character Data Types in SQL Server, 1. The six types, 2. Sample table, 3. Examples, 4. Query breakdown, 5. CHAR vs VARCHAR vs NVARCHAR, 6. Edge cases, 7. Interview scenario questions (+3 more)

### Community 6 - "01 — Types of SQL / T-SQL Statements"
Cohesion: 0.18
Nodes (10): 01 — Types of SQL / T-SQL Statements, 1. Categories, 2. Sample table, 3. Examples, 4. Query breakdown, 5. DELETE vs TRUNCATE vs DROP, 6. Edge cases, 7. Interview scenario questions (+2 more)

### Community 7 - "10 — Clustered vs Non-Clustered Index"
Cohesion: 0.18
Nodes (10): 10 — Clustered vs Non-Clustered Index, 1. Sample setup, 2. Definitions, 3. Comparison, 4. Query breakdown, 5. Edge cases, 6. Interview scenario questions, 7. Composite, covering recap + limits (asked follow-ups) (+2 more)

### Community 8 - "05 — Query vs Subquery"
Cohesion: 0.20
Nodes (9): 05 — Query vs Subquery, 1. Sample tables, 2. Definitions, 3. Three types + examples, 4. Query breakdown (correlated example), 5. Edge cases, 6. Interview scenario questions, Cheat recap (+1 more)

### Community 9 - "07 — SQL Joins"
Cohesion: 0.20
Nodes (9): 07 — SQL Joins, 1. Sample tables, 2. Examples, 3. Query breakdown (LEFT + anti-join), 4. Edge cases, 5. Interview scenario questions, 6. Non-equi + semi joins (asked follow-ups), Cheat recap (+1 more)

### Community 10 - "09 — CTE (Common Table Expression)"
Cohesion: 0.20
Nodes (9): 09 — CTE (Common Table Expression), 1. Sample tables, 2. Examples, 3. Query breakdown (recursive), 4. Edge cases, 5. Interview scenario questions, 6. CTE vs derived table (asked follow-up), Cheat recap (+1 more)

### Community 11 - "12 — NULL Handling (IS NULL, ISNULL vs COALESCE)"
Cohesion: 0.20
Nodes (9): 12 — NULL Handling (IS NULL, ISNULL vs COALESCE), 1. Sample table, 2. Examples, 3. Query breakdown (NOT IN wipeout), 4. Edge cases, 5. Interview scenario questions, 6. Catch-all WHERE caution (asked pattern), Cheat recap (+1 more)

### Community 12 - "13 — ORDER BY, TOP, DISTINCT (Ordered, Limited, Unique Lists)"
Cohesion: 0.20
Nodes (9): 13 — ORDER BY, TOP, DISTINCT (Ordered, Limited, Unique Lists), 1. Sample table, 2. Examples, 3. Query breakdown (paging), 4. Edge cases, 5. Interview scenario questions, 6. More list law (asked follow-ups), Cheat recap (+1 more)

### Community 13 - "16 — Window Functions (Rank, Totals, Shifts, Nth Pay)"
Cohesion: 0.20
Nodes (9): 16 — Window Functions (Rank, Totals, Shifts, Nth Pay), 1. Sample table, 2. Examples, 3. Query breakdown (rank trio on Asha/Dev tie), 4. Edge cases, 5. Interview scenario questions, 6. NTILE buckets (asked with the rank trio), Cheat recap (+1 more)

### Community 14 - "18 — Views (Saved Queries as Virtual Tables)"
Cohesion: 0.20
Nodes (9): 18 — Views (Saved Queries as Virtual Tables), 1. Sample tables (demo names — script drops them at the end), 2. Examples, 3. Query breakdown (rights wall), 4. Edge cases, 5. Interview scenario questions, 6. Cousin: synonym (asked with views), Cheat recap (+1 more)

### Community 15 - "Error Handling — TRY/CATCH, ERROR_* Readers, THROW, XACT_STATE"
Cohesion: 0.20
Nodes (9): 1. Shape + readers, 2. RAISERROR vs THROW, 3. XACT_STATE + XACT_ABORT + @@ERROR legacy, 4. Loop construct: WHILE (cursor's set-free cousin), 5. Edge cases, 6. Interview scenario questions, Cheat recap, Definition (say this in the interview) (+1 more)

### Community 16 - "Procs Deep-Dive — System vs User, Params, Where-Usable Matrix"
Cohesion: 0.20
Nodes (9): 1. System vs user vs extended, 2. Parameterized vs non (param shapes), 3. Where-usable matrix (the asked table), 4. Temp tables + procs (nested scope rules), 5. Edge cases, 6. Interview scenario questions, Cheat recap, Definition (say this in the interview) (+1 more)

### Community 17 - "Functions Deep-Dive — Built-ins, Determinism, Where-Usable Matrix"
Cohesion: 0.20
Nodes (9): 1. Built-in library tour (system stock), 2. Param vs non (your shapes), 3. Determinism bars (why some calls fence features), 4. Where-usable matrix (the asked table), 5. Edge cases, 6. Interview scenario questions, Cheat recap, Definition (say this in the interview) (+1 more)

### Community 18 - "21 — Triggers (Auto-Run Rules on Write)"
Cohesion: 0.20
Nodes (9): 1. Sample tables, 21 — Triggers (Auto-Run Rules on Write), 2. Examples (shapes — triggers can't sit on #temp; make in test DB), 3. Query breakdown (audit AFTER), 4. Edge cases, 5. Interview scenario questions, 6. Nesting + TRIGGER_NESTLEVEL (asked follow-ups), Cheat recap (+1 more)

### Community 19 - "22 — Transactions + ACID (Deals, Locks, Deadlocks)"
Cohesion: 0.20
Nodes (9): 1. Sample tables, 22 — Transactions + ACID (Deals, Locks, Deadlocks), 2. Examples, 3. Query breakdown (money move), 4. Edge cases, 5. Interview scenario questions, 6. Ladder explicit + RCSI + lock-vs-latch (asked follow-ups), Cheat recap (+1 more)

### Community 20 - "26 — Query Optimization Basics (Plans, Seeks, Sargability)"
Cohesion: 0.20
Nodes (9): 1. Sample table, 26 — Query Optimization Basics (Plans, Seeks, Sargability), 2. Examples, 3. Query breakdown (seek path), 4. Edge cases, 5. Interview scenario questions, 6. Senior tuning pack (experienced-round asks), Cheat recap (+1 more)

### Community 21 - "27 — Data Types: Numbers, Dates, Specials (IDENTITY, SEQUENCE, XML, Bits)"
Cohesion: 0.20
Nodes (9): 1. Numbers, 27 — Data Types: Numbers, Dates, Specials (IDENTITY, SEQUENCE, XML, Bits), 2. Dates and times, 3. Specials + key-makers, 4. Examples, 5. Edge cases, 6. Interview scenario questions, Cheat recap (+1 more)

### Community 22 - "00 — SQL Comments in T-SQL"
Cohesion: 0.22
Nodes (8): 00 — SQL Comments in T-SQL, 1. The two types, 2. Examples, 3. Query breakdown (how the engine reads them), 4. Edge cases (the traps), 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 23 - "Modern Syntax + Session Settings (T-SQL vs SQL, GO, SET Knobs)"
Cohesion: 0.22
Nodes (8): 1. T-SQL vs standard SQL (one table), 2. Re-runnable deploys (2016+), 3. GO + sqlcmd (tooling law), 4. DECLARE: SET vs SELECT, 5. Session knobs (why atop proc scripts), Cheat recap, Definition (say this in the interview), Modern Syntax + Session Settings (T-SQL vs SQL, GO, SET Knobs)

### Community 24 - "04 — Constraints in SQL Server"
Cohesion: 0.22
Nodes (8): 04 — Constraints in SQL Server, 1. Sample table, 2. Examples, 3. Query breakdown, 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 25 - "06 — WHERE vs HAVING"
Cohesion: 0.22
Nodes (8): 06 — WHERE vs HAVING, 1. Sample table, 2. Examples, 3. Query breakdown, 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 26 - "08 — UNION vs UNION ALL"
Cohesion: 0.22
Nodes (8): 08 — UNION vs UNION ALL, 1. Sample tables, 2. Examples, 3. Query breakdown, 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 27 - "Set Ops Beyond UNION — INTERSECT + EXCEPT"
Cohesion: 0.22
Nodes (8): 1. Sample tables, 2. Examples, 3. Query breakdown (EXCEPT), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview), Set Ops Beyond UNION — INTERSECT + EXCEPT

### Community 28 - "11 — GROUP BY + Aggregate Functions"
Cohesion: 0.22
Nodes (8): 11 — GROUP BY + Aggregate Functions, 1. Sample table, 2. Examples, 3. Query breakdown (dup-spotter), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 29 - "14 — CASE Expression (If-Then in Queries)"
Cohesion: 0.22
Nodes (8): 14 — CASE Expression (If-Then in Queries), 1. Sample table, 2. Examples, 3. Query breakdown (band CASE), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 30 - "15 — EXISTS vs IN (Match Tests + Anti-Joins)"
Cohesion: 0.22
Nodes (8): 15 — EXISTS vs IN (Match Tests + Anti-Joins), 1. Sample tables, 2. Examples, 3. Query breakdown (EXISTS short-circuit), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 31 - "17 — Temp Tables vs Table Variables (vs CTE)"
Cohesion: 0.22
Nodes (8): 17 — Temp Tables vs Table Variables (vs CTE), 1. Sample flow, 2. Comparison, 3. Query breakdown (pick logic), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 32 - "19 — Stored Procedures (Saved Work + Params)"
Cohesion: 0.22
Nodes (8): 19 — Stored Procedures (Saved Work + Params), 1. Sample table, 2. Examples (shape — run in your test DB, #temp shown for shape only), 3. Query breakdown (safe call flow), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 33 - "20 — Functions (Scalar vs Inline TVF vs Multi-Statement TVF)"
Cohesion: 0.22
Nodes (8): 1. Sample table, 20 — Functions (Scalar vs Inline TVF vs Multi-Statement TVF), 2. Examples (shapes — make in your test DB; #temp shown for shape), 3. Query breakdown (inline win), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 34 - "23 — Normalization (1NF → 3NF + When to Break It)"
Cohesion: 0.22
Nodes (8): 1. Sample shapes (0NF → 3NF), 23 — Normalization (1NF → 3NF + When to Break It), 2. Examples, 3. Query breakdown (city rename), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 35 - "24 — LIKE Pattern Matching (%, _, [], ESCAPE)"
Cohesion: 0.22
Nodes (8): 1. Sample table, 24 — LIKE Pattern Matching (%, _, [], ESCAPE), 2. Examples, 3. Query breakdown (seek vs scan), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 36 - "25 — Dynamic SQL + SQL Injection (Build Safe, Block Holes)"
Cohesion: 0.22
Nodes (8): 1. Sample table, 25 — Dynamic SQL + SQL Injection (Build Safe, Block Holes), 2. Examples, 3. Query breakdown (hole anatomy), 4. Edge cases, 5. Interview scenario questions, Cheat recap, Definition (say this in the interview)

### Community 37 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (8): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7a - FalkorDB export (only if --falkordb or --falkordb-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 38 - "T-SQL Study — SQL Server 2019 Interview Prep"
Cohesion: 0.22
Nodes (8): Cheat sheet (the 28 topics), Contributing, How this repo is organized, How to study, Prerequisites, Roadmap — Level 2 (all added ✅), Running the SQL files, T-SQL Study — SQL Server 2019 Interview Prep

### Community 39 - "Audit Options — Triggers vs Temporal Tables vs CDC"
Cohesion: 0.25
Nodes (7): 1. Temporal shape (2016+), 2. Comparison (the asked table), 3. Edge cases, 4. Interview scenario questions, Audit Options — Triggers vs Temporal Tables vs CDC, Cheat recap, Definition (say this in the interview)

### Community 40 - "Contributing to T-SQL Study"
Cohesion: 0.29
Nodes (6): A note on accuracy, Contributing to T-SQL Study, Folder conventions (so PRs stay mergeable), Ground rules, How to send a PR, What you can contribute

### Community 41 - "Opencode Configuration for T-SQL-Material"
Cohesion: 0.33
Nodes (5): Dropped (not relevant here), Kept MCP, Opencode Configuration for T-SQL-Material, Structure, Usage

### Community 42 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): For /graphify explain, For /graphify path, graphify reference: query, path, explain, Step 0 — Constrained query expansion (REQUIRED before traversal), Step 1 — Traversal

### Community 43 - "T-SQL Study Guide"
Cohesion: 0.40
Nodes (4): examples.sql law, Style, T-SQL Study Guide, Topic folders

### Community 44 - "AGENTS.md"
Cohesion: 0.50
Nodes (3): graphify, response style, toolchain installs

### Community 45 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 46 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 47 - "graphify reference: incremental update and cluster-only"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

### Community 56 - "10-indexes/examples.sql"
Cohesion: 0.43
Nodes (7): dbo.Employees_10, dbo.Orders_10, IX_Employees10_Id, IX_Employees10_IdName, IX_Employees10_Name, IX_Employees10_Name_Cover, IX_Orders10_Date

### Community 58 - "23-normalization/examples.sql"
Cohesion: 0.40
Nodes (4): City23, Phone23, Staff23, Team23

### Community 59 - "26-query-optimization/examples.sql"
Cohesion: 0.50
Nodes (4): IX_Ord26_Big, IX_Ord26_Cust, Ord26, INCLUDE

### Community 60 - "03-keys/examples.sql"
Cohesion: 0.67
Nodes (3): dbo.Departments_03, dbo.Employees_03, dbo.Enrollments_03

### Community 61 - "07-joins/examples.sql"
Cohesion: 0.50
Nodes (3): D07, E07, Emp07

### Community 62 - "17-temp-tables-vs-variables/examples.sql"
Cohesion: 0.67
Nodes (3): IX_Stage17_Sal, Share17, Stage17

### Community 63 - "18-views/examples.sql"
Cohesion: 0.83
Nodes (3): dbo.Dept18, dbo.Emp18, dbo.vw_ITStaff18

### Community 87 - "Security Policy"
Cohesion: 0.25
Nodes (7): Ground Rules for Testing, No Secrets in Contributions, Reporting a Vulnerability, Scope, Security Policy, Supported Versions, What happens next

### Community 88 - "bash"
Cohesion: 0.06
Nodes (33): cat *, cd *, chmod 777 *, cut *, date *, docker exec sql2025 *, docker images *, docker logs * (+25 more)

### Community 89 - "run_all.py"
Cohesion: 0.39
Nodes (8): base_cmd(), discover(), main(), Run every <NN-topic>/examples.sql against the SQL Server container, one by one.…, Returns (returncode, stdout, stderr)., reset_db(), run_file(), run_sqlcmd()

### Community 90 - "query-testing — live verification against SQL Server 2025"
Cohesion: 0.33
Nodes (5): Outputs, Prerequisites (run once, manually), query-testing — live verification against SQL Server 2025, Usage, Workflow for doc fixes

## Knowledge Gaps
- **441 isolated node(s):** `$schema`, `instructions`, `edit`, `git *`, `ls *` (+436 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 518 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **30 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `bash` connect `bash` to `opencode.json`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Why does `permission` connect `opencode.json` to `bash`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **What connects `$schema`, `instructions`, `edit` to the rest of the system?**
  _441 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `What You Must Do When Invoked` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `03 — Types of Keys in SQL Server` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `System Functions by Category (MS-Learn Map + Popular Picks)` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `bash` be split into smaller, more focused modules?**
  _Cohesion score 0.06060606060606061 - nodes in this community are weakly interconnected._