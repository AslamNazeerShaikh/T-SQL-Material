# 03 — Types of Keys in SQL Server

**Goal:** Define every key type cold and create PK / FK / UNIQUE / composite keys.

## 1. Sample tables

```sql
CREATE TABLE Departments
(
    Id INT PRIMARY KEY,
    DeptName VARCHAR(50)
);

CREATE TABLE Employees
(
    EmployeeId INT PRIMARY KEY,
    Email VARCHAR(200) UNIQUE,
    DepartmentId INT
        FOREIGN KEY REFERENCES Departments(Id)
);
```

Seed:

Departments:

| Id | DeptName |
|---:|----------|
| 10 | IT |
| 20 | HR |

Employees:

| EmployeeId | Email | DepartmentId |
|---:|---|---:|
| 1 | a@x.com | 10 |
| 2 | b@x.com | 20 |

## 2. The six keys

### Primary Key — uniquely identifies every row

```sql
EmployeeId INT PRIMARY KEY
```

- Unique + NOT NULL, one per table, can span multiple columns.

### Foreign Key — relationship + referential integrity

```sql
FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
```

- Blocks orphan rows: can't insert `DepartmentId = 99` if no department 99.

### Unique Key — no duplicates, but ≠ PK

```sql
Email VARCHAR(200) UNIQUE
```

- One table: `1 PRIMARY KEY`, many `UNIQUE` constraints.
- UNIQUE allows one NULL (single NULL semantics nuance) — PK allows zero NULLs.

### Candidate Key — *could* be the PK

If both `EmployeeId` and `Email` are guaranteed unique → both are candidate keys.

### Alternate Key — candidate key not chosen as PK

```text
EmployeeId → Primary Key
Email      → Alternate Key (enforced via UNIQUE)
```

### Composite Key — multi-column key

```sql
-- Enrollment: one student × one course is unique
CREATE TABLE Enrollments
(
    StudentId INT,
    CourseId INT,
    PRIMARY KEY (StudentId, CourseId)
);
```

Neither column alone is unique; the combination is.

## 3. Query breakdown

```sql
FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
```

1. Child column `Employees.DepartmentId` may only hold values present in `Departments.Id` (or NULL if nullable).
2. Insert/update on child is checked; delete/update on parent is checked (blocked or cascaded).
3. Add `ON DELETE CASCADE` / `ON UPDATE CASCADE` only deliberately — cascades can wipe data.

## 4. Edge cases

- Composite PK column order matters for seeking (`(A,B)` seeks well on `A`, poorly on `B` alone).
- UNIQUE + NULL: SQL Server allows a single NULL by default (consider filtered unique index if you need many/few NULLs).
- FK without supporting index on child column → deletes on parent + joins can be slow; add nonclustered index on FK.
- Natural vs surrogate PK: `Email` (natural) changes → all FKs churn. `INT IDENTITY` surrogate is stable.
- One PK per table max — extra uniqueness goes to UNIQUE constraints.

## 5. Interview scenario questions

1. "PK vs UNIQUE?" → PK: one/table, NOT NULL, identifies row. UNIQUE: many/table, allows NULL (single), alternate keys.
2. "Email must be unique but Id is PK — model it?" → `EmployeeId INT PRIMARY KEY, Email VARCHAR(200) UNIQUE`.
3. "Student–Course enrollment, no duplicate pairs?" → `PRIMARY KEY (StudentId, CourseId)`.
4. "Delete department still referenced — what happens?" → Blocked by FK (or cascade if defined). Must delete/reassign employees first.
5. "Define candidate vs alternate vs composite in one line each." → Candidate: could-be-PK. Alternate: candidate not chosen. Composite: multi-column key.

## Cheat recap

```text
Primary → unique + NOT NULL, 1/table
Foreign → referential integrity
Unique → no dupes, many/table, ≠ PK
Candidate → could-be-PK | Alternate → not-chosen candidate | Composite → multi-col
```
