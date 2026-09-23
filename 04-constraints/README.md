# 04 — Constraints in SQL Server

**Goal:** Enforce data rules declaratively: PK, FK, UNIQUE, NOT NULL, CHECK, DEFAULT.

## Definition (say this in the interview)

**What it is:** A constraint is a rule declared on a table that SQL Server enforces on every INSERT and UPDATE — no application code needed. `NOT NULL` demands a value, `UNIQUE` forbids duplicates, `CHECK` enforces a condition like `Age >= 18`, `DEFAULT` supplies a value when none is given, and PK/FK constraints enforce identity and relationships.

**Why it was introduced:** Application code changes, gets bypassed (bulk loads, ad-hoc scripts, new services), and has bugs. The database needed a last line of defense that holds no matter which client writes the data — so integrity rules moved into the engine itself, declared once alongside the schema.

**What problem it resolves:** Without constraints, invalid data accumulates silently — negative ages, duplicate emails, orders for nonexistent customers — and every report becomes suspect. Constraints reject bad writes at the gate, so the data is trustworthy regardless of which app wrote it.

**Interview-ready answer:** *"A constraint is a rule the database checks on each write. PRIMARY KEY and UNIQUE stop repeats. FOREIGN KEY checks the parent row is there. NOT NULL means a value is a must. CHECK tests a rule, like age 18 or more. DEFAULT fills a value, like today's date. I like them more than app-side checks. Data lives more than app code — and all ways to add data face the same rules."*

## 1. Sample table

```sql
CREATE TABLE dbo.Employees
(
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(200) UNIQUE,
    Age INT CHECK (Age >= 18),
    DepartmentId INT FOREIGN KEY REFERENCES dbo.Departments (Id),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
```

Seed:

| EmployeeId | Name | Email | Age | CreatedDate |
|---:|---|---|---:|---|
| 1 | John | j@x.com | 30 | auto-filled |

## 2. Examples

Input `dbo.Employees`:

| EmployeeId | Name | Email | Age | DepartmentId | CreatedDate |
|---:|---|---|---:|---:|---|
| 1 | John | j@x.com | 30 | 10 | auto-filled (SYSUTCDATETIME at INSERT) |

Example 1 — `PRIMARY KEY`:

```sql
EmployeeId INT PRIMARY KEY
```

Input:

| EmployeeId | Name |
|---:|---|
| 1 | John |

Duplicate `1` output:

| Result |
|---|
| Msg 2627 PK violation, rejected |

Example 2 — `FOREIGN KEY`:

```sql
FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(Id)
```

Input `dbo.Departments`:

| Id | DeptName |
|---:|---|
| 10 | IT |

`INSERT Dept 99` output:

| Result |
|---|
| Msg 547 FK conflict, rejected |

Example 3 — `UNIQUE`:

```sql
Email VARCHAR(200) UNIQUE
```

Input: `j@x.com` taken.

`INSERT j@x.com` output:

| Result |
|---|
| Msg 2627 UNIQUE violation, rejected |

Example 4 — `NOT NULL`:

```sql
Name VARCHAR(100) NOT NULL
```

`INSERT (3) NULL Name` output:

| Result |
|---|
| Msg 515 NULL into Name, rejected |

Example 5 — `CHECK`:

```sql
Age INT CHECK (Age >= 18)
```

`INSERT (2,'Kid',15)` output:

| Result |
|---|
| Msg 547 CHECK Age>=18, rejected |

Example 6 — `DEFAULT`:

```sql
CreatedDate DATETIME2 DEFAULT SYSUTCDATETIME()
INSERT INTO dbo.Employees (EmployeeId, Name) VALUES (1, 'John');
```

Input: `(1, John, Age 30)`.

Output (1 row):

| EmployeeId | Name | CreatedDate |
|---:|---|---|
| 1 | John | <non-NULL current UTC> |

## 3. Query breakdown

`Age INT CHECK (Age >= 18)`

1. Every INSERT/UPDATE evaluates `Age >= 18`.
2. Violation → statement fails, no row written.
3. Existing bad rows block adding the constraint unless `WITH NOCHECK` (avoid — creates untrusted constraint, hurts optimizer).

`CreatedDate DATETIME2 DEFAULT GETDATE()`

1. If INSERT omits the column (or uses `DEFAULT` keyword), `GETDATE()` fills it.
2. Explicit NULL still inserts NULL (unless column is NOT NULL) — DEFAULT only fires on omission.

## 4. Edge cases

- Adding CHECK to a dirty table fails — clean data or fix rows first; prefer `WITH CHECK` (trusted).
- `WITH NOCHECK` constraints are ignored by the optimizer for simplification — can hurt plans.
- DEFAULT with `GETDATE()` vs `SYSUTCDATETIME()`: local vs UTC — pick UTC for distributed/full-stack apps.
- UNIQUE vs CHECK for "no dupes": use UNIQUE (index-backed); CHECK can't see other rows.
- FK + cascade: `ON DELETE CASCADE` is convenient but dangerous — prefer explicit deletes in app/SP.
- NOT NULL on existing nullable column with NULLs → must backfill first.

## 5. Interview scenario questions

1. "Ensure Age ≥ 18 at DB level?" → `CHECK (Age >= 18)`, not app-only validation.
2. "Auto-stamp row creation?" → `DEFAULT GETDATE()` / `SYSUTCDATETIME()`.
3. "Email unique + Name mandatory?" → `UNIQUE` + `NOT NULL` together.
4. "Legacy table has bad rows, new CHECK fails — fix?" → Clean/backfill rows, add with `WITH CHECK`; never ship `WITH NOCHECK` silently.
5. "Where to enforce: app or constraint?" → Both, but constraint is the last line of defense — data outlives app code.

## Cheat recap

```text
PRIMARY KEY → unique + NOT NULL
FOREIGN KEY → integrity | UNIQUE → no dupes
NOT NULL → required | CHECK → rule | DEFAULT → auto value
```
