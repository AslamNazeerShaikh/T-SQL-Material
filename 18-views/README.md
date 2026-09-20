# 18 — Views (Saved Queries as Virtual Tables)

**Goal:** Wrap messy queries in named views for clean reads + tight rights, and know their limits.

## Definition (say this in the interview)

**What it is:** A view is a saved SELECT with a table name — no rows stored,
runs fresh each read. It hides join mess, shows only safe fields, and can carry
tight rights (read the view, never the base tables).

**Why it was introduced:** Apps kept pasting the same 8-table join, each copy
rotting apart — plus raw tables showed pay fields to all eyes. Views fix both:
one saved shape for all readers, and a rights wall round sore fields.

**What problem it resolves:** Copy-paste query rot and over-wide access. One
view = one truth for "IT staff list"; grants on the view alone keep base tables
shut. Change the join once, all readers move together.

**Interview-ready answer:** *"A view is a saved SELECT with a table name. No
rows stored — runs fresh each read. I use views to hide join mess and to show
only safe fields, giving rights on the view, not the base tables. Limits: no
stored rows, writes only on plain one-table views, and deep views on views turn
slow and hard to trace."*

## 1. Sample tables (demo names — script drops them at the end)

```sql
CREATE TABLE dbo.Dept18 (Id INT PRIMARY KEY, Name VARCHAR(20));
CREATE TABLE dbo.Emp18 (Id INT PRIMARY KEY, Name VARCHAR(20), Salary INT, DeptId INT);
INSERT INTO dbo.Dept18 VALUES (10,'IT'),(20,'HR');
INSERT INTO dbo.Emp18 VALUES (1,'Asha',90000,10),(2,'Dev',80000,10),(3,'Ravi',45000,20);
-- (Views can't sit on #temp tables, hence real demo tables + cleanup.)
```

## 2. Examples

```sql
-- View: IT staff, pay hidden from readers
CREATE VIEW vw_ITStaff AS
SELECT e.Id, e.Name, d.Name AS Dept
FROM dbo.Emp18 e JOIN dbo.Dept18 d ON d.Id = e.DeptId WHERE e.DeptId = 10;
SELECT * FROM vw_ITStaff;   -- reads like a table

-- Rights wall: readers get the view only
-- GRANT SELECT ON vw_ITStaff TO ReportLogin;

-- Change once, all move: add field in one place
ALTER VIEW vw_ITStaff AS
SELECT e.Id, e.Name, d.Name AS Dept, e.Salary
FROM dbo.Emp18 e JOIN dbo.Dept18 d ON d.Id = e.DeptId WHERE e.DeptId = 10;

DROP VIEW vw_ITStaff;
```

## 3. Query breakdown (rights wall)

Reader hits `vw_ITStaff` → engine runs the saved join → base `Emp18` pay field
never named, never seen. GRANT sits on the view; base tables stay shut. This is
the cheapest field-level shield before masks/row-locks.

## 4. Edge cases

- Views hold no rows — each read re-runs the query; slow base = slow view.
- Writes only through plain one-table views (no totals, DISTINCT, GROUP BY, UNION).
  Need writes on joins? INSTEAD OF trigger (see `21`).
- View-on-view piles hide true cost — three deep and plans go murky; cap depth.
- `SELECT *` in a view freezes fields at make time — new base fields stay unseen
  till ALTER. Name fields, never star.
- ALTER keeps rights; DROP + CREATE wipes them — prefer ALTER.
- Indexed views DO store rows (fast totals, tight rules, edition notes) — rare
  use; default to plain views.

## 5. Interview scenario questions

1. "Same 8-table join in ten reports — fix?" → One view, all reports read it.
2. "Clerks must see staff, never pay?" → View sans pay + GRANT on view only.
3. "Base table gained a field, view hides it — why?" → Star frozen at make. ALTER with named fields.
4. "View on view on view — risk?" → Hidden cost, murky plans. Flatten to one or two.
5. "View vs CTE vs temp?" → View: saved + shared + rights. CTE: one-query step. Temp: staged rows + indexes (`09`, `17`).

## Cheat recap

```text
View = saved SELECT, no rows, fresh each read | hides joins + shields fields
Rights on view, base shut | ALTER keeps rights | name fields, cap depth
Writes: plain one-table only | indexed views store rows (rare, ruled)
```
