# 26 — Query Optimization Basics (Plans, Seeks, Sargability)

**Goal:** Read a plan, turn scans into seeks, and kill the top slow-query habits.

## Definition (say this in the interview)

**What it is:** Optimization = give the engine a cheap path: right indexes,
seek-friendly filters (sargable = can ride an index), tight column lists, fresh
stats. The execution plan (SSMS `Ctrl+M`) shows the picked path — seek/scan,
join shapes, fat pipes — so fixes aim true, not blind.

**Why it was introduced:** Right SQL can still crawl — full scans on 100M rows,
funcs fencing indexes, star-dragging blobs. Data grows, patience shrinks. Plans
expose the true cost so one index or rewrite buys 100x.

**What problem it resolves:** Blind tuning. Guess-fixes (more RAM, reboots)
miss; plan-led fixes (index the filter, un-wrap the column, kill the star) hit.
Habits below stop most slow queries before birth.

**Interview-ready answer:** *"Slow query first gets its plan read — I hunt full
scans, fat pipes, and wrong join shapes. Top fixes: index the WHERE-JOIN-ORDER
fields, keep filters seek-friendly with bare columns — no funcs on indexed
fields, no head percent — name tight columns not star, and keep stats fresh.
I prove with plan before and after, and park hot-path wins in Query Store."*

## 1. Sample table

```sql
CREATE TABLE #Ord (Id INT PRIMARY KEY, CustId INT, Amt INT, ODate DATE);
INSERT INTO #Ord VALUES (1,1,100,'2026-01-05'),(2,1,200,'2026-02-05'),(3,2,150,'2026-01-20');
CREATE NONCLUSTERED INDEX IX_Ord_Cust ON #Ord(CustId) INCLUDE (Amt);
```

## 2. Examples

Input `#Ord` used by every example below (+ `IX_Ord_Cust(CustId) INCLUDE(Amt)`):

| Id | CustId | Amt | ODate |
|---:|---:|---:|---|
| 1 | 1 | 100 | 2026-01-05 |
| 2 | 1 | 200 | 2026-02-05 |
| 3 | 2 | 150 | 2026-01-20 |

Example 1 — seek-friendly:

```sql
SELECT CustId, SUM(Amt) AS Total FROM #Ord
WHERE CustId = 1 AND ODate >= '2026-01-01' AND ODate < '2026-03-01'
GROUP BY CustId;
```

Input: 3 rows above.

Output (1 row):

| CustId | Total |
|---:|---:|
| 1 | 300 |

Example 2 — fenced twins (same logic, full scan):

```sql
-- WHERE YEAR(ODate) = 2026
-- WHERE Name LIKE '%sh%'
-- SELECT *
```

Input: same 3 rows.

Output: same logical rows, but full scan + per-row converts (slow).

| Result |
|---|
| Same rows, higher cost (scan vs seek) |

Example 3 — type-matched seek:

```sql
SELECT * FROM #Ord WHERE CustId = 1;
```

Input: 3 rows above.

Output (2 rows):

| Id | CustId | Amt | ODate |
|---:|---:|---:|---|
| 1 | 1 | 100 | 2026-01-05 |
| 2 | 1 | 200 | 2026-02-05 |

```sql
-- SELECT * FROM #Ord WHERE CustId = '1';
```

Input: same.

Output (2 rows — same data, convert fence + plan warning):

| Id | CustId | Amt | ODate |
|---:|---:|---:|---|
| 1 | 1 | 100 | 2026-01-05 |
| 2 | 1 | 200 | 2026-02-05 |

## 3. Query breakdown (seek path)

`WHERE CustId = 1` bare on indexed field → B-tree seek to CustId=1 run → INCLUDE
Amt read off leaf (no table trip) → GROUP sums few rows. Wrapped twin
(`YEAR()`, text type, head-%) voids the seek → full scan + convert per row.

## 4. Edge cases

- Fresh index + stale stats = blind plans — update stats past big loads.
- One more index speeds reads, taxes writes — index hot filters, drop the dead (usage DMVs).
- OR across fields oft splits seeks — UNION ALL twins or covering indexes help.
- Param sniff: first-call plan misfits next values — test odd inputs.
- Implicit converts hide in plans as warnings — match app types to column types.
- NOLOCK "speed" is dirt, not a fix (see `22`) — fix the path, not the lock.

## 5. Interview scenario questions

1. "Report crawls past 10M rows — first steps?" → Plan read, hunt scans, index filter/join/order fields.
2. "`WHERE YEAR(d)=2025` slow — rewrite?" → Ranged dates `>= '2025-01-01' AND < '2026-01-01'`.
3. "Added index, still scans — why?" → Func/type fence, stale stats, star-drag lookups, or sniffed plan.
4. "Star in prod view — harm?" → Blob drag + lookup bloats; name tight columns + covering INCLUDE.
5. "Prove the win?" → Plan before/after (cost %, seeks), Query Store trend.

## 6. Senior tuning pack (experienced-round asks)

- Sniff fixes: copy params to locals, `OPTION (OPTIMIZE FOR (@p = 5))`,
  `OPTION (RECOMPILE)` per-call plan (CPU tax), plan guides last resort.
- Stats + fragments: `UPDATE STATISTICS dbo.T;` past big loads;
  `sys.dm_db_index_physical_stats` reads rot — REORGANIZE light mess, REBUILD
  heavy mess (needs ONLINE to dodge locks).
- Filtered index: `CREATE NONCLUSTERED INDEX IX ON T(A) WHERE A IS NOT NULL;`
  — small, sharp, used only when the query matches the filter.
- Partitioning: split giants by date/id — prune scans, swap loads, archive per
  partition. Columnstore (`CLUSTERED COLUMNSTORE INDEX`) squeezes DW scans ~10x.
- Plans: estimated (guess, no run) vs actual (run + true rows) — skew between
  them screams stale stats/data skew. Shifting text bloats plan cache → params.
  Query Store parks regressions.
- Minimal logging: SELECT INTO / BULK INSERT / TABLOCK loads skip row-logs.
- BETWEEN datetime trap: `BETWEEN '2026-01-01' AND '2026-01-31'` misses Jan-31
  PM rows — half-open ranges (`>=` + `< next`) always.
- INDEX hints override the optimizer — rarely, briefly, with a comment why.
- Modern tools: SSMS plans + Query Store + Extended Events (Profiler is dead road).
- Spills (short memory grants → tempdb), CXPACKET (parallel waits), MAXDOP caps —
  read the warnings, fix shapes first, knobs last.

## Cheat recap

```text
Plan first (Ctrl+M) | index WHERE-JOIN-ORDER | bare columns seek, funcs fence
No head-% | no star | match types | fresh stats | prove before/after
sniff→locals/RECOMPILE | BETWEEN half-open | hints rare | Query Store parks wins.
```
