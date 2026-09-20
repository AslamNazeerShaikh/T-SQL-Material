# Security Policy

## Supported Versions

| Version (scope) | Supported (status) |
|---|---|
| `main` branch (latest study content) | ✅ Supported — security fixes applied here |
| Older commits / forks / copies | ❌ Not supported — please re-test on latest `main` before reporting |

This is a **static study-content repo** (Markdown + self-contained T-SQL `examples.sql` for SQL Server 2019 interview prep). There is no hosted service, no backend, no auth system, and no package to patch — so "supported" means we will correct or remove insecure content on `main`.

## Reporting a Vulnerability

**Please do not open a public issue for a suspected vulnerability.**

Report it privately via GitHub:

1. Go to **Security → Report a vulnerability** on this repo:
   `https://github.com/AslamNazeerShaikh/T-SQL-Material/security/advisories/new`
2. Include:
   - File / folder path and commit SHA where you saw the problem
   - What you expected vs. what happens (steps to reproduce)
   - Your SQL Server version, SSMS / Azure Data Studio version, and collation if relevant
   - Suggested fix, if you have one

### What happens next

| Step (stage) | Timeline (target) | Detail |
|---|---|---|
| Acknowledge (triage start) | Within 7 days | We confirm receipt and whether we can reproduce |
| Fix / decision (resolution) | Within 30 days | Fix on `main`, or explanation if not a vulnerability |
| Disclosure (follow-up) | After fix lands | We will credit you if you want credit — just say so in the report |

If you get no reply within 7 days, please open a minimal public issue titled `Security report follow-up (no details)` so we can re-establish contact without disclosing details.

## Scope

| In scope (reviewed) | Out of scope (not tracked here) |
|---|---|
| Dangerous T-SQL guidance (e.g. dynamic SQL / injection-bypass patterns in `25-dynamic-sql-injection/`, unsafe `EXEC`, missing `QUOTENAME` / parameterization) | Bugs in SQL Server / SSMS / Azure Data Studio themselves — report those to Microsoft |
| Malicious or exfiltrating content hidden in `.sql` / `.md` / hooks / configs (`.opencode/`, `graphify-out/`, workflows if added) | Vulnerabilities in your own fork, clone, or downstream copy |
| Credential / secret leaks committed to this repo (connection strings, passwords, tokens) | Social-engineering / phishing reports unrelated to this repo's content |
| Supply-chain risk in this repo (e.g. a contributed script that drops/alters user data beyond its documented `#Temp` / uniquely-named-table sandbox) | General T-SQL correctness issues (wrong query, bad definition) — send those as a normal PR per `CONTRIBUTING.md`, not a security report |

`examples.sql` files are documented as self-contained sandbox scripts (F5-clean, `#Temp` or uniquely named tables). Anything that breaks that promise (persistent schema changes, network/file-system access like `xp_cmdshell`, `OPENROWSET(BULK...)`, telemetry) is in scope for a security report.

## Ground Rules for Testing

- Do **not** run untrusted scripts against production or shared databases — use a local SQL Server 2019 Developer / Express instance.
- Do **not** exfiltrate data, disrupt GitHub Actions (if any), or brute-force anything.
- Keep reports minimal: redact connection strings, hostnames, and personal data.

## No Secrets in Contributions

Per `CONTRIBUTING.md`, never commit:

- Connection strings, SQL logins/passwords, service-principal secrets, or tokens
- `.env` files, publish profiles, or machine-specific SSMS connection files
- Copyrighted books / paid courses / exam dumps

If you spot a committed secret, report it privately (see above) so it can be purged from history, rather than quoting it in a public issue or PR.
