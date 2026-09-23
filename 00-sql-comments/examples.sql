-- 00 — SQL Comments. Self-contained. Runs F5 clean on SQL Server 2019+.
-- (Error-case demos stay as notes on purpose — an unclosed block would break the batch.)

-- 1. Line note: all text after -- is skipped till line end
SELECT 1 AS One; -- this note ends with the line

-- 2. Block hide: many lines, then close
/* Hide full blocks while testing:
   SELECT 'hidden1';
   SELECT 'hidden2';
*/
SELECT 2 AS Two;

-- 3. Blocks nest in T-SQL (each open needs its own close)
SELECT 3 AS Three;
/* outer open
   /* inner note */
   outer still open till here */

-- 4. The 5--2 trap: dashes eat the 2, answer is 5, not 3
SELECT 5--2 AS TrapResult;   -- returns 5
SELECT 5 - -2 AS RealMath;   -- returns 7 (gaps = minus negative two)

-- 5. Notes in quotes are plain text, NOT notes
SELECT
    '--' AS DashText,
    '/*' AS BlockText;

-- 6. Kill one filter fast while testing (toggle the dashes)
SELECT COUNT(*) AS EmpCount
FROM (
    SELECT 1 AS x
    UNION ALL
    SELECT 2
) t
WHERE 1 = 1 /* AND 1 = 2 */;

-- 7. Trailing-note trap demo: WHERE is skipped, full set comes back
SELECT 'full-set' AS What; -- WHERE 1 = 2  <- this filter never runs

-- 8. UNCLOSED BLOCK DEMO (text only — never run an unclosed /* live):
-- /* oops, no close below — all text after this point is eaten, then error
-- SELECT 'never runs';

-- 9. Switch off GO while testing (kept live: it is just a note, batch stays one)
/* GO */

-- 10. Proc header pattern
/* =============================================
   Proc:   usp_Demo
   Owner:  AppTeam
   Why:    Sample header kept in code
============================================= */
SELECT 'header-ok' AS Header;
