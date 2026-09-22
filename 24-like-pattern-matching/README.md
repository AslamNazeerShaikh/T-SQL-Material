# 24 — LIKE Pattern Matching (%, _, [], ESCAPE)

**Goal:** Find text by shape with LIKE wildcards — and keep seeks alive (sargability).

## Definition (say this in the interview)

**What it is:** LIKE tests text by shape, not full match. `%` stands for any
run (even empty), `_` for one letter, `[abc]` / `[a-z]` for one of a set,
`[^a]` for not-a. `ESCAPE` frees a mark to mean itself (`\%` for real percent).

**Why it was introduced:** Users recall halves — "starts with Ash," "mail ends
.com." Full-match `=` can't serve halves; wildcards turn half-memory into
findable shapes.

**What problem it resolves:** Shape search without app-side scans. One LIKE
with a tail `%` still seeks an index; wrapped app loops can't.

## 1. Sample table

```sql
CREATE TABLE #Emp (Id INT, Name VARCHAR(30), Mail VARCHAR(50));
INSERT INTO #Emp VALUES (1,'Asha','asha@x.com'),(2,'Ashok','ashok@y.com'),
 (3,'Dev','dev@x.com'),(4,'100%Sure','s@z.com');
```

**Interview-ready answer:** *"LIKE tests text by shape. Percent is any run.
Underscore is one letter. Box brackets pick one of a set, cap-box means not.
ESCAPE frees a mark to mean itself. Speed rule: tail percent like Ash-percent
still seeks; head percent like percent-ash scans all — I flip shapes or add
full-text for those."*

## 2. Examples

Input `#Emp` used by every example below:

| Id | Name | Mail |
|---:|---|---|
| 1 | Asha | asha@x.com |
| 2 | Ashok | ashok@y.com |
| 3 | Dev | dev@x.com |
| 4 | 100%Sure | s@z.com |

Example 1 — starts `Ash%` (seeks):

```sql
SELECT * FROM #Emp WHERE Name LIKE 'Ash%';
```

Input: 4 rows above.

Output (2 rows):

| Id | Name | Mail |
|---:|---|---|
| 1 | Asha | asha@x.com |
| 2 | Ashok | ashok@y.com |

Example 2 — holds `%sh%` (scans):

```sql
SELECT * FROM #Emp WHERE Name LIKE '%sh%';
```

Input: 4 rows above.

Output (2 rows):

| Id | Name | Mail |
|---:|---|---|
| 1 | Asha | asha@x.com |
| 2 | Ashok | ashok@y.com |

Example 3 — exactly 3 `___`:

```sql
SELECT * FROM #Emp WHERE Name LIKE '___';
```

Input: 4 rows above.

Output (1 row):

| Id | Name | Mail |
|---:|---|---|
| 3 | Dev | dev@x.com |

Example 4 — `Ash_k`:

```sql
SELECT * FROM #Emp WHERE Name LIKE 'Ash_k';
```

Input: 4 rows above.

Output (1 row):

| Id | Name | Mail |
|---:|---|---|
| 2 | Ashok | ashok@y.com |

Example 5 — `[AD]%`:

```sql
SELECT * FROM #Emp WHERE Name LIKE '[AD]%';
```

Input: 4 rows above.

Output (3 rows):

| Id | Name | Mail |
|---:|---|---|
| 1 | Asha | asha@x.com |
| 2 | Ashok | ashok@y.com |
| 3 | Dev | dev@x.com |

Example 6 — `[^A]%`:

```sql
SELECT * FROM #Emp WHERE Name LIKE '[^A]%';
```

Input: 4 rows above.

Output (2 rows):

| Id | Name | Mail |
|---:|---|---|
| 3 | Dev | dev@x.com |
| 4 | 100%Sure | s@z.com |

Example 7 — `%.com`:

```sql
SELECT * FROM #Emp WHERE Mail LIKE '%.com';
```

Input: 4 rows above.

Output (4 rows):

| Id | Name | Mail |
|---:|---|---|
| 1 | Asha | asha@x.com |
| 2 | Ashok | ashok@y.com |
| 3 | Dev | dev@x.com |
| 4 | 100%Sure | s@z.com |

Example 8 — escaped `%`:

```sql
SELECT * FROM #Emp WHERE Name LIKE '100\%%' ESCAPE '\';
```

Input: 4 rows above.

Output (1 row):

| Id | Name | Mail |
|---:|---|---|
| 4 | 100%Sure | s@z.com |

Example 9 — `NOT LIKE 'A%'`:

```sql
SELECT * FROM #Emp WHERE Name NOT LIKE 'A%';
```

Input: 4 rows above.

Output (2 rows):

| Id | Name | Mail |
|---:|---|---|
| 3 | Dev | dev@x.com |
| 4 | 100%Sure | s@z.com |

## 3. Query breakdown (seek vs scan)

`'Ash%'` pins the head — engine seeks the index run Ash…→Ashz. `'%sh%'`
floats — no head to pin, full scan checks all rows. Same marks, ten-times cost
gap on big tables (see `26`).

## 4. Edge cases

- Case follows the column's collation — `ash%` may or may not catch `Asha`; check it.
- `_` needs exact spots — `'___'` is 3-letter only; `'__K%'` is K-third.
- `%` also matches empty — `'Ash%'` catches plain 'Ash'.
- Brackets are T-SQL-only sugar — `%`/`_` travel alltown, `[]` don't.
- `NOT LIKE` + NULLs: NULL rows fall out (UNKNOWN) — add `OR x IS NULL` if needed.
- Wildcards in user input (`%` typed as name) match wild — ESCAPE or scrub input.

## 5. Interview scenario questions

1. "Names starting Ash?" → `LIKE 'Ash%'` (seek-friendly).
2. "Mails ending .com?" → `LIKE '%.com'`.
3. "Find real 100% in names?" → `LIKE '100\%%' ESCAPE '\'`.
4. " holds-search crawls on 10M rows — fix?" → Head-pin shape, full-text index, or trigram/cache table.
5. "Case surprise — ash% missed Asha?" → Collation case-sensitivity; force with COLLATE or UPPER both sides (kills seek — note it).

## Cheat recap

```text
% any run | _ one letter | [ab] one of | [^a] not-a | ESCAPE frees mark
Head-pinned seeks | head-% scans | case = collation | NULL falls out of NOT LIKE
big-text hunts → full-text CONTAINS/FREETEXT (own index, not LIKE).
```
