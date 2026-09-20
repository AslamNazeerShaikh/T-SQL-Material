-- 19b — Error handling demos. All blasts caught; F5 clean.
-- 1. Full ERROR_* readout on divide-by-zero
BEGIN TRY
  SELECT 10/0 AS Boom;
END TRY
BEGIN CATCH
  SELECT ERROR_NUMBER() AS Num, ERROR_SEVERITY() AS Sev, ERROR_STATE() AS St,
         ERROR_LINE() AS Ln, ERROR_PROCEDURE() AS Proc, ERROR_MESSAGE() AS Msg;
END CATCH;
GO
-- 2. RAISERROR custom, caught
BEGIN TRY
  RAISERROR('Pay below floor.', 16, 1);
END TRY
BEGIN CATCH
  SELECT ERROR_MESSAGE() AS CaughtRaise;
END CATCH;
GO
-- 3. THROW custom, caught (true line kept on re-throw)
BEGIN TRY
  THROW 50001, 'Custom boom.', 1;
END TRY
BEGIN CATCH
  SELECT ERROR_NUMBER() AS Num, ERROR_MESSAGE() AS Msg;
END CATCH;
GO
-- 4. XACT_STATE in a deal: blast inside TRY, CATCH reads state, rolls back
IF OBJECT_ID('tempdb..#E19b') IS NOT NULL DROP TABLE #E19b;
CREATE TABLE #E19b (Id INT);
BEGIN TRY
  BEGIN TRANSACTION;
    INSERT INTO #E19b VALUES (1);
    SELECT 1/0 AS Boom;
  COMMIT;
END TRY
BEGIN CATCH
  SELECT XACT_STATE() AS State, ERROR_MESSAGE() AS Msg;  -- 1 here: sealable
  IF XACT_STATE() <> 0 ROLLBACK;
END CATCH;
SELECT COUNT(*) AS RowsKept FROM #E19b;  -- 0: rolled back
DROP TABLE #E19b;
GO
-- 5. @@ERROR legacy: read NEXT line or it resets (prints 0: PRINT is clean)
PRINT 'hi';
SELECT @@ERROR AS LegacyZero;
GO
-- 6. WHILE loop with CONTINUE + BREAK
DECLARE @i INT = 1;
WHILE @i <= 5
BEGIN
  IF @i = 3 BEGIN SET @i += 1; CONTINUE; END
  PRINT @i;
  IF @i = 4 BREAK;
  SET @i += 1;
END;
