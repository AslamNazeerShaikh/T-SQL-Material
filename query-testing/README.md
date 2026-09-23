# query-testing — live verification against SQL Server 2025

Runs every `<NN-topic>/examples.sql` against a real server, one file at a
time, and captures full input/output in `results/`. Used to prove the
Input/Output tables in each topic `README.md` match actual engine behavior
(SQL Server 2025, `mcr.microsoft.com/mssql/server:2025-latest` under Rosetta).

Our queries target SQL Server 2019 syntax. Policy: keep 2019 queries as-is;
only if something is deprecated/removed on 2025 do we switch that spot to the
latest stable equivalent (and note it in the topic README).

## Prerequisites (run once, manually)

```bash
# 1. Docker Desktop on Apple Silicon needs Rosetta for the amd64 SQL image:
#    Docker Desktop → Settings → General → "Use Rosetta for x86_64/amd64 emulation"
#    (or flip UseVirtualizationFrameworkRosetta in settings-store.json + restart)

# 2. Start SQL Server 2025:
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Str0ng!Passw0rd" \
  -e "MSSQL_PID=Evaluation" -p 1433:1433 \
  --name sql2025 --hostname sql2025 \
  -d mcr.microsoft.com/mssql/server:2025-latest

# 3. Wait for "Recovery is complete", then sanity check:
docker exec sql2025 /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'Str0ng!Passw0rd' -No \
  -Q "SELECT SERVERPROPERTY('ProductMajorVersion')"
```

No Python packages needed — `run_all.py` is stdlib only.

## Usage

```bash
# all 28 topics, fresh isolated DB per file
python3 query-testing/run_all.py

# one topic only
python3 query-testing/run_all.py --only 07-joins

# skip the drop+recreate (debug only — risks cross-file pollution)
python3 query-testing/run_all.py --only 07-joins --no-reset
```

Env knobs: `QTEST_RUNTIME` (default `docker`), `QTEST_CONTAINER`
(default `sql2025`), `QTEST_USER` (default `sa`), `QTEST_PASSWORD`
(default `Str0ng!Passw0rd`), `QTEST_DB` (default `TsqlStudyTest`),
`QTEST_TIMEOUT_S` (default `180`).

```bash
QTEST_PASSWORD='Str0ng!Passw0rd' python3 query-testing/run_all.py
```

## Outputs

| Path | Content |
|---|---|
| `results/<topic>.log` | Full sqlcmd stdout+stderr per `examples.sql` (exit code on line 2) |
| `results/summary.md` | Pass/fail table for the run |

## Workflow for doc fixes

1. Run the harness, open `results/summary.md`.
2. For each `FAIL`, read its log — fix the query or the doc, whichever is wrong.
3. For each `PASS`, spot-check result sets against the README Input/Output
   tables (row counts, NULL handling, ordering) and correct the README.
4. Re-run `--only <topic>` until green, then update `results/summary.md`.
