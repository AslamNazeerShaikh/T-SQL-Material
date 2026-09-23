# 23 — Normalization (1NF → 3NF + When to Break It)

**Goal:** Split tables to kill repeats (1NF/2NF/3NF) and know when to join them back for speed.

## Definition (say this in the interview)

**What it is:** House rules for split tables. 1NF: one value per cell, own key
per row, no repeat clubs. 2NF: past 1NF plus no field leans on half a key.
3NF: past 2NF plus no field leans on a non-key field. De-split (denormalize)
glues back for read speed when joins drag.

**Why it was introduced:** Flat tables repeat city-per-order and rot on edit —
fix one copy, miss three. Split-by-need kills repeats so each fact lives once,
with keys rejoining the truth on reads.

**What problem it resolves:** Add/edit/drop weirdness (can't add a city with no
order; rename city in nine spots; drop last order, lose the city). Split tables
hold each fact once; joins rebuild views cheap.

**Interview-ready answer:** *"First form: one value per cell, own key, no
repeat clubs. Second: past first, plus no field leans on half a key — team name
moves out of a task-staff keyed table. Third: past second, plus no field leans
on a non-key — city moves out of staff to a city table keyed by city id. I
break the rules back for read speed — star shapes for reports — when joins
drag and writes are rare."*

## 1. Sample shapes (0NF → 3NF)

```sql
-- 0NF flat rot: city + team name repeat per staff row
-- StaffFlat(Name, TeamName, City, CityPin)

-- 3NF split: each fact once
CREATE TABLE #City (CityId INT PRIMARY KEY, City VARCHAR(30), Pin VARCHAR(10));
CREATE TABLE #Team (TeamId INT PRIMARY KEY, TeamName VARCHAR(30), CityId INT);
CREATE TABLE #Staff (StaffId INT PRIMARY KEY, Name VARCHAR(30), TeamId INT);
```

## 2. Examples

Input `#City`:

| CityId | City | Pin |
|---:|---|---|
| 1 | Pune | 411001 |
| 2 | Mumbai | 400001 |

Input `#Team`:

| TeamId | TeamName | CityId |
|---:|---|---:|
| 10 | IT | 1 |
| 20 | HR | 2 |

Input `#Staff`:

| StaffId | Name | TeamId |
|---:|---|---:|
| 1 | Asha | 10 |
| 2 | Dev | 10 |
| 3 | Ravi | 20 |

Input `#Phone` (1NF child):

| StaffId | Phone |
|---:|---|
| 1 | 98111 |
| 1 | 98222 |
| 2 | 98333 |

Example 1 — 1NF child table:

```sql
CREATE TABLE #Phone (
    StaffId INT, Phone VARCHAR(15),
    PRIMARY KEY (StaffId, Phone)
);
```

Input: Asha 2 phones, Dev 1, Ravi 0.

Output `#Phone` (3 rows): same as input table above.

Example 2 — 2NF (no half-key lean):

```sql
-- TaskStaff(TaskId, StaffId, Hours) + #Team(TeamId, TeamName) + #Staff(StaffId, TeamId)
```

Input: flat repeat `TeamName` per task.

Output `#Team` (2 rows): same as input table above.

Example 3 — 3NF rebuild + edit-once:

```sql
INSERT INTO #City VALUES (1, 'Pune', '411001');
UPDATE #City SET City = 'Pune City' WHERE CityId = 1;
SELECT
    s.Name,
    t.TeamName,
    c.City,
    c.Pin,
    p.Phone
FROM #Staff s JOIN #Team t ON t.TeamId = s.TeamId
JOIN #City c ON c.CityId = t.CityId LEFT JOIN #Phone p ON p.StaffId = s.StaffId;
```

Input: tables above.

Output (4 rows):

| Name | TeamName | City | Pin | Phone |
|---|---|---|---|---|
| Asha | IT | Pune City | 411001 | 98111 |
| Asha | IT | Pune City | 411001 | 98222 |
| Dev | IT | Pune City | 411001 | 98333 |
| Ravi | HR | Mumbai | 400001 | NULL |

## 3. Query breakdown (city rename)

Flat: `UPDATE StaffFlat SET City='Pune'...` must hit all rows — miss one, rot.
3NF: one row in `#City` shifts — all joins show new name next read. Edit-once
is the full payoff.

## 4. Edge cases

- Over-split (BCNF+ zeal) turns simple reads into 9-join crawls — stop at 3NF mostly.
- Surrogate Id keys ease links; natural keys (mail) rot on change — link by Id.
- De-split needs a refresh tale (job, view, trigger) or reads go stale.
- 1NF "atomic" bends per need — JSON blobs trade query-ability for ship speed.
- Keys first: no PK, no form counts — keyless piles can't prove dup-free.

## 5. Interview scenario questions

1. "City repeats per order row — form break?" → Not 3NF (city leans on non-key). City table + key.
2. "Team name in task-staff keyed table — break?" → Not 2NF (leans on half-key). Team table.
3. "Phones as comma list — break?" → Not 1NF. Child phone table.
4. "Report joins 8 tables, crawls — move?" → De-split hot path (star/view), keep writes split.
5. "Add city with zero orders — flat pain?" → Add anomaly; split tables add freely.

## Cheat recap

```text
1NF atomic cells + key | 2NF no half-key lean | 3NF no non-key lean
Each fact once → edit once | joins rebuild views
De-split for read speed (star) with a refresh tale
```
