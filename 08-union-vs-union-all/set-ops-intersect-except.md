# Set Ops Beyond UNION — INTERSECT + EXCEPT

Companion to `README.md` (UNION vs UNION ALL). Covers the other two set
operators interviewers love: INTERSECT (common rows) and EXCEPT (missing rows).

## Definition (say this in the interview)

**What it is:** Three set words for two same-shape lists. UNION stacks all
(deduped). INTERSECT keeps only rows living in both. EXCEPT keeps rows of the
first list missing from the second. (Oracle calls EXCEPT "MINUS" — same job.)

**Why it was introduced:** UNION answers "all together," but checks need "both
have" (paid + shipped = clean orders) and "first lacks" (staff with zero
training). Set words say that straight, no join gymnastics.

**What problem it resolves:** Match/miss checks in one clean read instead of
JOIN + NULL-test piles — with dedupe built in.

**Interview-ready answer:** *"UNION stacks lists. INTERSECT keeps rows living
in both lists. EXCEPT keeps first-list rows missing from the second. Same-shape
rule all three — same count, matching types. I use INTERSECT for both-have
checks and EXCEPT for missing-row checks, like staff with zero training done."*

## 1. Sample tables

```sql
CREATE TABLE #Paid (Id INT, Name VARCHAR(20));
CREATE TABLE #Shipped (Id INT, Name VARCHAR(20));
INSERT INTO #Paid VALUES (1,'Asha'),(2,'Dev'),(3,'Ravi');
INSERT INTO #Shipped VALUES (2,'Dev'),(3,'Ravi'),(4,'Tom');
```

## 2. Examples

```sql
-- Both-have: paid AND shipped (Dev, Ravi)
SELECT Id, Name FROM #Paid
INTERSECT
SELECT Id, Name FROM #Shipped;

-- Missing: paid but NOT shipped (Asha)
SELECT Id, Name FROM #Paid
EXCEPT
SELECT Id, Name FROM #Shipped;

-- Flip it: shipped never paid (Tom)
SELECT Id, Name FROM #Shipped
EXCEPT
SELECT Id, Name FROM #Paid;

-- UNION recap: all one-of-a-kind (Asha, Dev, Ravi, Tom)
SELECT Id, Name FROM #Paid
UNION
SELECT Id, Name FROM #Shipped;
```

## 3. Query breakdown (EXCEPT)

Left list (Paid: 1,2,3) minus right list (Shipped: 2,3,4) → keeps 1 (Asha).
Dedupe rides free — repeats in left collapse to one. Order flips answer
(right EXCEPT left = Tom), so first-list choice is the full call.

## 4. Edge cases

- Same-shape rule all three ops — count + types must match, names ride the first list.
- NULLs count as same for dedupe — two NULL rows melt to one.
- EXCEPT/INTERSECT dedupe always — need dupes kept? That's UNION ALL town only.
- EXCEPT is one-way — flip lists, flip answer. Say which side is "first" in checks.
- Big lists pay sort/hash like UNION — index the match fields, filter early.
- Anti-joins (`15`) do the same job row-wise — set ops read cleaner for full-row checks.

## 5. Interview scenario questions

1. "Orders paid AND shipped?" → INTERSECT on order keys.
2. "Staff with zero training done?" → `Staff EXCEPT Trained`.
3. "Oracle MINUS in T-SQL?" → EXCEPT — same job, T-SQL name.
4. "UNION vs INTERSECT vs EXCEPT one line each?" → Stack all / keep both-have / keep first-missing.
5. "Dupes kept through EXCEPT?" → No — dedupe rides free. UNION ALL keeps dupes.

## Cheat recap

```text
UNION stacks (deduped) | INTERSECT both-have | EXCEPT first-missing
Same shape all three | names ride first | flip EXCEPT sides, flip answer
```
