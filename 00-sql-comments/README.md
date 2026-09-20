# 00 — SQL Comments in T-SQL

**Goal:** Comment code both ways, and dodge the traps (killed `WHERE`, `5--2`, unclosed blocks, `GO`, plan cache).

> No sample tables here — comments work on plain `SELECT` literals. All snippets below run as-is.

## Definition (say this in the interview)

**What it is:** A comment is text the engine skips — notes for humans, not steps
for the machine. T-SQL has two kinds: `--` hides all text after it till the line
ends, and `/* ... */` hides a block that can run many lines and can sit inside
other blocks.

**Why it was introduced:** Code with no notes rots — six months later nobody
knows why a weird filter sits there. Comments also let you test by hiding half a
query (chop the `WHERE`, run, see what shifts) without deleting work.

**What problem it resolves:** Blind code. Notes say the *why* behind odd logic,
headers say who owns a proc, and hide-and-run lets you cut a bug in half fast —
all with zero change to what the query does.

**Interview-ready answer:** *"T-SQL has two notes. Dash-dash hides all text
after it till the line ends. Star-slash hides a block of many lines, and blocks
can sit in blocks. I use dash-dash for quick notes and star-slash to hide test
code. Two traps I watch: a dash-dash can eat my WHERE by mistake, and a block
with no close eats the full query after it."*

## 1. The two types

| Type (name) | Mark (sign) | Ends at (scope) | Nests (yes/no) | Best for (use) |
|---|---|---|---|---|
| Line note | `--` | Line end | N/A (one line) | Quick notes, kill one line |
| Block hide | `/* ... */` | At `*/` | Yes — blocks in blocks work | Hide test code, proc headers |

```sql
SELECT 1 AS One; -- this note ends with the line

/* Hide full blocks while testing:
   SELECT * FROM Demo_Emp WHERE Salary < 0;
   SELECT * FROM Demo_Dept;
*/
SELECT 2 AS Two;

/* Blocks can sit in blocks in T-SQL (not all databases let you):
   /* inner note */
   SELECT 3 AS Three;
*/
```

## 2. Examples

```sql
-- Note at top: why this odd filter sits here
SELECT EmpId, Name
FROM Demo_Emp
WHERE Salary > 0;   -- junk rows hold -1 from old load

-- Kill one line fast while testing (add/remove the dashes)
/* AND DeptId = 10 */
SELECT COUNT(*) FROM Demo_Emp WHERE 1 = 1 /* AND DeptId = 10 */;

-- Proc header pattern: who, why, when
/* =============================================
   Proc:   usp_GetITStaff
   Owner:  AppTeam
   Why:    List IT staff for the home page
   Date:   2026-09-20
   Change: 2026-09-21 - added JoinDate
============================================= */
```

## 3. Query breakdown (how the engine reads them)

1. The parser scans text left to right. A `--` seen *outside quotes* drops all
   text after it till the new line. A `/*` seen *outside quotes* drops all text
   till its match `*/` — inner `/*` pairs stack, each needs its own close.
2. Text *in quotes* is data, never a note: `'--'` and `'/*'` stay as plain text.
3. Notes still ride to the server with the batch — they are skipped at parse
   time, not stripped by your tool.

## 4. Edge cases (the traps)

- **`SELECT 5--2` gives 5, not 3.** The dashes eat the `2` as a note.
  Need math? Add gaps: `SELECT 5 - -2` → 7.
- **A dash note can eat your filter.** `SELECT * FROM t --WHERE x = 1` skips the
  `WHERE` and reads the full table. In checks, this looks like "too many rows."
- **A block with no close eats all after it** — then throws a syntax error.
  Always close `*/` in the same edit.
- **Dash notes can't span lines.** Each line needs its own `--`. A block can.
- **`GO` must sit alone on its line.** `--GO` is just a note, not a batch split —
  but `/* GO */` is also skipped, which is the neat trick to switch off a `GO`
  while testing a full script as one batch.
- **`//`, `#`, `REM` are NOT T-SQL notes.** They throw errors (those belong to
  C#, MySQL, batch files). In T-SQL only `--` and `/* */` count.
- **Notes count in the plan cache text.** Same query with a new note = a new
  cache row. Small cost, but don't stamp changing dates in hot prod code.
- **Tool keys:** SSMS / ADS hide marked lines with `Ctrl+K, C` and bring them
  back with `Ctrl+K, U`.

## 5. Interview scenario questions

1. **"Two kinds of notes in T-SQL?"** → `--` to line end; `/* */` block, can nest.
2. **"What does `SELECT 5--2` give?"** → 5. The `--2` is a note. For 7, write `5 - -2`.
3. **"Query gives full table, filter looks fine — why?"** → Odds are the `WHERE`
   sits after a `--` on the same line and is skipped. Move it to its own line.
4. **"Can blocks sit in blocks?"** → Yes in T-SQL — each open needs its own
   close. Many other databases fail here, so say "in SQL Server, yes."
5. **"How to switch off a `GO` while testing?"** → Wrap it: `/* GO */`. The batch
   parser skips notes, so the full script runs as one batch.
6. **"Do notes reach the server?"** → Yes, with the batch; the parser skips them.
   Proof: changing only a note makes a new plan-cache row.
7. **"Hide half a slow query to find the bad part — how?"** → Block-hide joins /
   filters one by one and re-run — cut the bug in half each time.

## Cheat recap

```text
--      → hides to line end | one line only
/* */   → hides a block | can sit in blocks | close each open
'--' in quotes → plain text, not a note
5--2 = 5 (note!) | 5 - -2 = 7
--WHERE eats filter | unclosed /* eats all | // # REM are NOT T-SQL notes
/* GO */ switches off a batch split | notes count in plan cache text
Ctrl+K,C hide | Ctrl+K,U bring back
```
