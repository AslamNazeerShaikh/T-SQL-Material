-- 02 — Character data types. Self-contained.
IF OBJECT_ID('dbo.DemoStrings_02', 'U') IS NOT NULL DROP TABLE dbo.DemoStrings_02;
CREATE TABLE dbo.DemoStrings_02
(
    Code    CHAR(6),
    Name    VARCHAR(100),
    UniName NVARCHAR(100)
);

INSERT INTO dbo.DemoStrings_02 (Code, Name, UniName)
VALUES ('EMP001', 'John', N'John'),
       ('EMP002', 'Sara', N'अस्लम');

SELECT Code, Name, UniName FROM dbo.DemoStrings_02;

-- N-prefix matters
DECLARE @Good NVARCHAR(100) = N'अस्लम';
DECLARE @Bad  VARCHAR(100)  = 'अस्लम';
SELECT @Good AS Unicode_OK, @Bad AS NonUnicode_Mangled;

-- CHAR padding behavior
SELECT DATALENGTH(Code) AS CodeBytes, LEN(Code) AS CodeLen
FROM dbo.DemoStrings_02;

-- MAX types for large payloads
DECLARE @Json VARCHAR(MAX) = '{"id":1,"tags":["a","b"]}';
SELECT DATALENGTH(@Json) AS JsonBytes;

-- Collation: case-sharp hunt vs blur default
SELECT * FROM dbo.DemoStrings_02 WHERE Name = 'sara' COLLATE Latin1_General_CS_AS;  -- zero (Sara ≠ sara)
SELECT * FROM dbo.DemoStrings_02 WHERE Name = 'sara' COLLATE Latin1_General_CI_AS;  -- Sara row

DROP TABLE dbo.DemoStrings_02;
