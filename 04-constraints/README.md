# 04 — Constraints in SQL Server

**Goal:** Enforce data rules declaratively: PK, FK, UNIQUE, NOT NULL, CHECK, DEFAULT.

## Definition (say this in the interview)

**What it is:** A constraint is a rule declared on a table that SQL Server enforces on every INSERT and UPDATE — no application code needed. `NOT NULL` demands a value, `UNIQUE` forbids duplicates, `CHECK` enforces a condition like `Age >= 18`, `DEFAULT` supplies a value when none is given, and PK/FK constraints enforce identity and relationships.

**Why it was introduced:** Application code changes, gets bypassed (bulk loads, ad-hoc scripts, new services), and has bugs. The database needed a last line of defense that holds no matter which client writes the data — so integrity rules moved into the engine itself, declared once alongside the schema.

**What problem it resolves:** Without constraints, invalid data accumulates silently — negative ages, duplicate emails, orders for nonexistent customers — and every report becomes suspect. Constraints reject bad writes at the gate, so the data is trustworthy regardless of which app wrote it.

**Interview-ready answer:** *"Constraints are declarative integrity rules the engine enforces on every write: PRIMARY KEY and UNIQUE guarantee uniqueness, FOREIGN KEY guarantees the parent row exists, NOT NULL mandates a value, CHECK enforces a condition such as Age >= 18, and DEFAULT auto-fills values like GETDATE. I prefer them over app-only validation because data outlives application code — bulk imports and future services hit the same enforcement."*

## 1. Sample table

```sql
CREATE TABLE Employees
(
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(200) UNIQUE,
    Age INT CHECK (Age >= 18),
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
```

Seed:

| EmployeeId | Name | Email | Age | CreatedDate |
|---:|---|---|---:|---|
| 1 | John | j@x.com | 30 | auto-filled |

## 2. Examples

```sql
EmployeeId INT PRIMARY KEY          -- unique + NOT NULL
FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)  -- integrity
Email VARCHAR(200) UNIQUE           -- no dupes
Name VARCHAR(100) NOT NULL          -- value required
Age INT CHECK (Age >= 18)           -- rule
CreatedDate DATETIME2 DEFAULT GETDATE()  -- auto value

INSERT INTO Employees (EmployeeId, Name) VALUES (1, 'John');
-- CreatedDate auto-supplied by DEFAULT
```

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
