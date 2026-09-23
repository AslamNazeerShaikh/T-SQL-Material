#!/usr/bin/env python3
"""Run every <NN-topic>/examples.sql against the SQL Server container, one by one.

Stdlib only — no pip packages needed. Talks to the server through
`docker exec <container> /opt/mssql-tools18/bin/sqlcmd`, piping each
examples.sql file on stdin so GO batch separators work natively.

Isolation: the test database is dropped + recreated before each file, so
leftover objects from a failed run can never pollute the next file.

Outputs:
  query-testing/results/<topic>.log   full sqlcmd output per file
  query-testing/results/summary.md    pass/fail table

Env knobs (all optional):
  QTEST_RUNTIME    docker | podman            (default docker)
  QTEST_CONTAINER  container name             (default sql2025)
  QTEST_USER       login                      (default sa)
  QTEST_PASSWORD   sa password                (default Str0ng!Passw0rd)
  QTEST_DB         test database              (default TsqlStudyTest)
  QTEST_TIMEOUT_S  per-file timeout seconds   (default 180)

Usage:
  python3 query-testing/run_all.py
  python3 query-testing/run_all.py --only 07-joins
  python3 query-testing/run_all.py --only 07-joins --no-reset
"""

import argparse
import datetime
import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
RESULTS = HERE / "results"

RUNTIME = os.environ.get("QTEST_RUNTIME", "docker")
CONTAINER = os.environ.get("QTEST_CONTAINER", "sql2025")
USER = os.environ.get("QTEST_USER", "sa")
PASSWORD = os.environ.get("QTEST_PASSWORD", "Str0ng!Passw0rd")
DB = os.environ.get("QTEST_DB", "TsqlStudyTest")
TIMEOUT = int(os.environ.get("QTEST_TIMEOUT_S", "180"))
SQLCMD = "/opt/mssql-tools18/bin/sqlcmd"


def base_cmd(*extra):
    return [
        RUNTIME, "exec", "-i", CONTAINER, SQLCMD,
        "-S", "localhost", "-U", USER, "-P", PASSWORD, "-No",
        *extra,
    ]


def run_sqlcmd(query=None, db="master", stdin_bytes=None):
    """Returns (returncode, stdout, stderr)."""
    cmd = base_cmd("-d", db, "-b", "-m1")
    if query is not None:
        cmd += ["-Q", query]
    try:
        p = subprocess.run(cmd, input=stdin_bytes,
                           capture_output=True, timeout=TIMEOUT)
        return (p.returncode,
                p.stdout.decode("utf-8", "replace"),
                p.stderr.decode("utf-8", "replace"))
    except subprocess.TimeoutExpired:
        return 124, "", f"TIMEOUT after {TIMEOUT}s"
    except FileNotFoundError as e:
        return 127, "", f"runtime not found: {e}"


def reset_db():
    q = (
        f"IF DB_ID('{DB}') IS NOT NULL BEGIN "
        f"ALTER DATABASE [{DB}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; "
        f"DROP DATABASE [{DB}]; END; "
        f"CREATE DATABASE [{DB}];"
    )
    return run_sqlcmd(query=q, db="master")


def discover(only=None):
    files = sorted(ROOT.glob("??-*/examples.sql"))
    if only:
        files = [f for f in files if f.parent.name == only or f.parent.name.startswith(only)]
    return files


def run_file(path, reset=True):
    if reset:
        rc, out, err = reset_db()
        if rc != 0:
            return ("DB-RESET-FAILED", rc, out, err)
    data = path.read_bytes()
    rc, out, err = run_sqlcmd(db=DB, stdin_bytes=data)
    return ("PASS" if rc == 0 else "FAIL", rc, out, err)


def main():
    ap = argparse.ArgumentParser(description="Run all topic examples.sql files.")
    ap.add_argument("--only", help="run one topic, e.g. --only 07-joins")
    ap.add_argument("--no-reset", action="store_true",
                    help="skip drop+recreate of the test DB before each file")
    args = ap.parse_args()

    RESULTS.mkdir(exist_ok=True)
    files = discover(args.only)
    if not files:
        print(f"no examples.sql matched (only={args.only})")
        return 1

    print(f"runtime={RUNTIME} container={CONTAINER} db={DB} files={len(files)}")
    rows = []
    for path in files:
        topic = path.parent.name
        status, rc, out, err = run_file(path, reset=not args.no_reset)
        log = RESULTS / f"{topic}.log"
        log.write_text(
            f"# {topic}/examples.sql\n# exit={rc} status={status}\n\n"
            f"--- stdout ---\n{out}\n--- stderr ---\n{err}\n",
            encoding="utf-8",
        )
        rows.append((topic, status, rc))
        print(f"[{status}] {topic} (exit={rc}) -> results/{topic}.log")

    stamp = datetime.datetime.now().isoformat(timespec="seconds")
    lines = [f"# query-testing results — {stamp}",
             f"runtime={RUNTIME} container={CONTAINER} db={DB}", "",
             "| Topic | Status | Exit | Log |",
             "|---|---|---:|---|"]
    for topic, status, rc in rows:
        lines.append(f"| {topic} | {status} | {rc} | results/{topic}.log |")
    passed = sum(1 for _, s, _ in rows if s == "PASS")
    lines += ["", f"{passed}/{len(rows)} files passed."]
    (RESULTS / "summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"{passed}/{len(rows)} passed. summary: results/summary.md")
    return 0 if passed == len(rows) else 2


if __name__ == "__main__":
    sys.exit(main())
