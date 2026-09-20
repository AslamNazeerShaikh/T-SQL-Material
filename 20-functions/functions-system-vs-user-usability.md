# Functions Deep-Dive — Built-ins, Determinism, Where-Usable Matrix

Companion to `README.md` (scalar vs inline vs multi-step). Answers: the shipped
library, param vs non, determinism bars, and exactly where each shape may run.

## Definition (say this in the interview)

**What it is:** Two stocks. Shipped (system) calls — string, date, math,
convert, and `@@` state calls — free in any query. Yours (user) — scalar one
value, inline one-SELECT table, multi-step staged table — with or without
inputs (parameterless shapes allowed all three).

**Interview-ready answer:** *"Shipped calls split five ways: string like LEN
and SUBSTRING, date like DATEADD, convert like TRY-CAST that gives NULL not
blasts, math, and state like ROWCOUNT. Mine are scalar one value, inline one
SELECT table, staged multi-step — inputs or none. Scalar and inline run most
query spots; table shapes join via APPLY; none may write, run dynamic, or call
procs."*

## 1. Built-in library tour (system stock)

| Family (kind) | Calls (names) | One-line job (use) |
|---|---|---|
| String | LEN, LEFT/RIGHT, SUBSTRING, CHARINDEX, CONCAT/_WS, TRIM/LTRIM/RTRIM, UPPER/LOWER, REPLACE, STRING_SPLIT, STRING_AGG | cut, find, glue, split, group-glue |
| Date/time | GETDATE, SYSDATETIME, DATEADD, DATEDIFF(_BIG), DATENAME, DATEPART, EOMONTH, SWITCHOFFSET | stamp, shift, span, month-end |
| Convert | CAST, CONVERT (styles), TRY_CAST, TRY_CONVERT, TRY_PARSE | TRY_ twins give NULL on rot, never blast |
| Math | ABS, ROUND, CEILING, FLOOR, POWER, SQUARE, SQRT, RAND | ROUND banker's? No — half-up, note it |
| Null/logic | ISNULL, COALESCE, NULLIF, IIF, CHOOSE | NULLIF(a,0) shields divide-by-zero |
| State/system | @@ROWCOUNT, @@ERROR, @@TRANCOUNT, @@IDENTITY vs SCOPE_IDENTITY, DB_NAME, OBJECT_ID, NEWID | SCOPE_ beats @@ (trigger-skew) |

```sql
SELECT LEN('Asha') AS L, SUBSTRING('Asha',2,2) AS Mid,            -- 4, sh
       CONCAT('Hi ','',NULL) AS Glue, 'Hi ' + NULL AS Poison,    -- Glue lives, + dies
       TRY_CAST('abc' AS INT) AS Soft,                            -- NULL, no blast
       NULLIF(10,10) AS Shield,                                   -- NULL (divide guard)
       DATEADD(MONTH, 1, '2026-01-31') AS Nxt, EOMONTH(GETDATE()) AS ME;
SELECT value FROM STRING_SPLIT('a,b,c', ',');                    -- split rows, order NOT promised
```

## 2. Param vs non (your shapes)

- Parameterless allowed all three shapes (`RETURNS ... AS BEGIN RETURN 1 END`
  with `()`; TVFs with `()` too) — fixed rules, config reads.
- Inputs sharpen reuse; inline TVF + input is the parameterized-view pattern.
- Defaults allowed on scalar/TVF inputs (`@D INT = 10`).

## 3. Determinism bars (why some calls fence features)

| Call (name) | Deterministic (yes/no) | Barred in UDF body (yes/no) | Note (detail) |
|---|---|---|---|
| LEN, DATEADD, ABS, ISNULL | Yes | No | persisted-computed + indexed-view safe |
| GETDATE, SYSDATETIME | No | No (allowed) | allowed in body, kills persist/index use |
| RAND, NEWID | No | Yes (direct) | wrap in a view, call the view (stock dodge) |
| Dynamic EXEC, side writes, TRY/CATCH, #temp make | — | Yes | funcs are read-math only |

## 4. Where-usable matrix (the asked table)

| Context (place) | Scalar (yes/no) | Inline TVF (yes/no) | Multi TVF (yes/no) | Note (detail) |
|---|---|---|---|---|
| SELECT list, WHERE, JOIN ON, ORDER BY, GROUP BY, HAVING | Yes | No (table, not value) | No | bread-and-butter scalar spots |
| FROM (+ JOIN) | No | Yes | Yes | TVFs are tables — `CROSS/OUTER APPLY` for param joins |
| CROSS APPLY param join | — | Yes (star use) | Yes | `FROM Emp e CROSS APPLY dbo.fn_Team(e.DeptId)` |
| View body | Yes | Yes | Yes | views love funcs (procs barred) |
| Proc / trigger body | Yes | Yes | Yes | all shapes callable |
| CTE / subquery / derived | Yes | Yes | Yes | query-land accepts all |
| CHECK constraint | Yes (care) | No | No | per-row check; keep pure + schemabind |
| DEFAULT constraint | Yes | No | No | scalar fills on omit |
| Computed column | Yes | No | No | PERSISTED needs deterministic |
| Call a proc / EXEC dynamic / write tables | No | No | No | read-math only, all shapes |

```sql
-- Star pattern: parameterized join without a real join key
-- SELECT e.Name, t.Salary FROM dbo.Emp e CROSS APPLY dbo.fn_Team(e.DeptId) t;
```

## 5. Edge cases

- Scalar in 1M-row SELECT pre-2019 = row tax; 2019 inlines worthy ones — check plans.
- `+` concat dies on NULL, CONCAT skips NULLs — pick per need.
- `CAST` blasts on rot; `TRY_CAST` returns NULL — imports want TRY_.
- `@@IDENTITY` catches trigger-made ids — `SCOPE_IDENTITY()` keeps yours.
- STRING_SPLIT promises no order — need ranked splits? Key it yourself.
- FORMAT is handy, slow — hot paths use CONVERT styles.
- Multi TVF joins guess blind (no stats) — big builds prefer inline or #temp.

## 6. Interview scenario questions

1. "Join staff to per-team table func with input?" → `CROSS APPLY dbo.fn_Team(e.DeptId)`.
2. "NEWID in func — blocked?" → Yes direct; view-wrap dodge.
3. "Default stamp via func?" → Scalar in DEFAULT, allowed.
4. "Persisted computed with GETDATE func?" → No — non-deterministic bars persist.
5. "Import '12x' to INT sans blast?" → `TRY_CAST` → NULL, scrub after.
6. "GUID per row in SELECT?" → `NEWID()` inline in query (not inside func body).

## Cheat recap

```text
Shipped: string/date/convert/math/state | TRY_ soft, CONCAT null-safe, SCOPE_ beats @@
Yours: scalar value | inline 1-SELECT table (+APPLY) | staged multi (stats-blind)
Determinism gates persist/index | barred: NEWID/RAND direct, dynamic, writes, TRY/CATCH, #temp
Runs: most query spots + views/procs/triggers/checks/defaults/computed | never procs/dynamic
```
