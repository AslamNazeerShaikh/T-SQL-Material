# 15 — EXISTS vs IN (Match Tests + Anti-Joins)

**Goal:** Pick EXISTS / IN / JOIN right, stay NULL-safe, and write anti-joins three ways.

## Definition (say this in the interview)

**What it is:** Three ways to ask "does a match live in that set": `IN` tests a
value round a list (stops late), `EXISTS` asks "one or more rows?" and stops at
the first hit (loves linked subqueries), and a JOIN keeps matched rows inline.
`NOT EXISTS` is the NULL-safe "no match" test; `NOT IN` breaks on NULLs.

**Why it was introduced:** Filters need set tests — staff in Pune teams, buyers
with zero orders. IN suits still lists; EXISTS suits row-by-row linked checks
and quits early on big sets instead of building full lists.

**What problem it resolves:** Wrong or slow match tests. `NOT IN` plus one NULL
wipes answers (see `12`); IN on huge sets drags; linked EXISTS short-circuits.
Right pick = right answer at low cost.

**Interview-ready answer:** *"IN tests a value round a list. EXISTS asks if one
or more rows live there, and stops at the first hit — best for linked checks on
big sets. For no-match tests I use NOT EXISTS, never NOT IN, as one NULL in the
list kills all NOT IN rows. Buyers with zero orders is my stock anti-join show:
NOT EXISTS, or LEFT JOIN with IS NULL."*

## 1. Sample tables

```sql
CREATE TABLE #Cust (Id INT, Name VARCHAR(20));
CREATE TABLE #Ord (Id INT, CustId INT NULL);
INSERT INTO #Cust VALUES (1,'Asha'),(2,'Dev'),(3,'Ravi');
INSERT INTO #Ord VALUES (101,1),(102,NULL);  -- NULL row arms the trap
```

## 2. Examples

Input used below:

`#Cust`:

| Id | Name |
|---:|---|
| 1 | Asha |
| 2 | Dev |
| 3 | Ravi |

`#Ord`:

| Id | CustId |
|---:|---:|
| 101 | 1 |
| 102 | NULL |

Example 1 — `IN` match:

```sql
SELECT * FROM #Cust WHERE Id IN (SELECT CustId FROM #Ord WHERE CustId IS NOT NULL);
```

Input: 3 cust + list `{1}`.

Output (1 row):

| Id | Name |
|---:|---|
| 1 | Asha |

Example 2 — `EXISTS` match:

```sql
SELECT c.* FROM #Cust c WHERE EXISTS (SELECT 1 FROM #Ord o WHERE o.CustId = c.Id);
```

Input: 3 cust + 2 ord.

Output (1 row):

| Id | Name |
|---:|---|
| 1 | Asha |

Example 3 — `NOT EXISTS` anti-join (safe):

```sql
SELECT * FROM #Cust c
WHERE NOT EXISTS (SELECT 1 FROM #Ord o WHERE o.CustId = c.Id);
```

Input: 3 cust + 2 ord.

Output (2 rows):

| Id | Name |
|---:|---|
| 2 | Dev |
| 3 | Ravi |

Example 4 — `LEFT JOIN + IS NULL` anti-join:

```sql
SELECT c.* FROM #Cust c LEFT JOIN #Ord o ON o.CustId = c.Id
WHERE o.Id IS NULL;
```

Input: same.

Output (2 rows):

| Id | Name |
|---:|---|
| 2 | Dev |
| 3 | Ravi |

Example 5 — `NOT IN` trap:

```sql
SELECT * FROM #Cust WHERE Id NOT IN (SELECT CustId FROM #Ord);
```

Input: list `{1, NULL}`.

Output: 0 rows.

| Id | Name |
|---|---|
| *(no rows)* | |

Example 6 — still-list `IN`:

```sql
SELECT * FROM #Cust WHERE Id IN (1, 3);
```

Input: 3 cust.

Output (2 rows):

| Id | Name |
|---:|---|
| 1 | Asha |
| 3 | Ravi |

## 3. Query breakdown (EXISTS short-circuit)

`WHERE EXISTS (SELECT 1 ... o.CustId = c.Id)` per Cust row: engine seeks one
Ord hit and stops — no full list built. On big sets this beats IN's
build-then-test. The `SELECT 1` is a hint to readers: values don't count, rows do.

## 4. Edge cases

- `NOT IN` + NULL list = empty answer, always. Fix: `NOT EXISTS` or scrub NULLs.
- `x IN (1, NULL)`: true on hit, else UNKNOWN (not false) — soft trap in OR chains.
- EXISTS linked checks run per outer row — index the inner link field or joins win.
- Dup inner rows: IN/EXISTS don't dup outer rows; JOINs can fan out (see `07`).
- `SELECT 1` vs `SELECT *` in EXISTS: same plan — `1` just reads clean.
- Semi vs anti: EXISTS keeps hits, NOT EXISTS keeps misses — name them in checks.

## 5. Interview scenario questions

1. "Staff in Pune teams?" → `IN` on team-id list, or EXISTS linked form.
2. "Buyers, zero orders?" → NOT EXISTS (safe) / LEFT JOIN + IS NULL.
3. "NOT IN gives empty — data looks fine?" → NULL in subquery list. Prove with `SELECT ... WHERE CustId IS NULL`.
4. "EXISTS vs IN on 100M rows?" → EXISTS short-circuits per row; IN builds full set first.
5. "JOIN instead of EXISTS?" → Same hits, but JOIN dups outer rows on multi-hits and can't anti directly.

## Cheat recap

```text
IN tests list | EXISTS one-or-more + stops early | JOIN keeps matched rows
NOT EXISTS NULL-safe anti | NOT IN + NULL = empty, never use on dirty lists
Index inner link field | SELECT 1 in EXISTS reads clean
```
