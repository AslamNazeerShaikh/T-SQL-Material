## response style

- Answer in tabular form whenever the answer has comparable items, options, steps, or findings — tables first, prose only for what doesn't fit a table. Keep tables detailed (all relevant columns), not terse. Always add metrics notation to the column names of the table if applicable. Make sure dont overexploitation usage of tables.
- Explanations the user asks for are always given in full & detailed; the "short explanation" default does not apply here.

## toolchain installs

- Never install toolchains, packages, libraries, or tools automatically (no `brew install`, `npm i -g`, `rustup`, `pip install`, SDK downloads, etc. on your own).
- Instead, give copy-pasteable commands the user can run manually, with the exact names/versions needed.
- Exception: the user explicitly grants permission in a prompt reply (e.g. "yes, install it" or "proceed", etc.) — then you may install, and report what was installed with versions.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

## Execution Timestamps (UTC + Local)

For every **CLI/Terminal command or query execution** and every **prompt output/response**, log timestamps at both the **start** and **end**.

### Scope

Timestamp logging applies only to:

1. Query/CLI/Terminal execution **START and END**
2. Prompt output/response **START and END**

Do **NOT** log timestamps for every intermediate tool call, internal operation, or harness/tool step. This avoids unnecessary verbosity.

Here is a compact version that keeps the important rules and cross-platform commands:

### Required Timestamp Format

At every **START** and **END**, output both UTC and machine-local timestamps on **one line**, separated by `|`.

```text
UTC: 2026-09-23T14:54:02Z [UTC] | Local: 2026-09-23 08:24:02 PM +05:30 [IST]
```

**UTC format:**

```text
UTC: YYYY-MM-DDTHH:MM:SSZ [UTC]
```

24-hour ISO 8601, `Z` suffix, `[UTC]`.

**Local format:**

```text
Local: YYYY-MM-DD hh:mm:ss AM/PM +HH:MM [ABBR]
```

Use the **machine's own timezone**; offset and abbreviation are dynamic and must never be hardcoded. Use 12-hour time with `AM/PM`.

### START

```text
--- Start ---
UTC: 2026-09-23T14:54:02Z [UTC] | Local: 2026-09-23 08:24:02 PM +05:30 [IST]
<what started>
```

### END

```text
--- End ---
UTC: 2026-09-23T14:54:10Z [UTC] | Local: 2026-09-23 08:24:10 PM +05:30 [IST]
<what ended> | Status=Ok
```

Use `Status=Fail` when the task fails. Do not put status on the timestamp line.

### Getting Timestamps

**macOS / Linux:**

```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
date +"%Y-%m-%d %I:%M:%S %p %z [%Z]"
```

The second command returns the offset as `+HHMM`; insert `:` to produce `+HH:MM`.

**Windows PowerShell:**

```powershell
(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$now=Get-Date; $offset=[System.TimeZoneInfo]::Local.GetUtcOffset($now); $sign=if($offset -ge [TimeSpan]::Zero){"+"}else{"-"}; $off=$offset.Duration().ToString("hh\:mm"); "Local: $($now.ToString('yyyy-MM-dd hh:mm:ss tt')) $sign$off [$([System.TimeZoneInfo]::Local.StandardName)]"
```

### Rules

* Always log both UTC and Local at **START and END**.
* Prompt output/response **START** = first-action time of the turn: the system clock captured on the first tool/CLI action of the turn, reused verbatim in the final `--- Start ---` line. **END** = system clock at response completion.
* Use the actual system clock; never guess or fabricate timestamps.
* Local timezone, offset, and abbreviation must come from the machine.
* Do not log intermediate tool calls or internal operations.
* If timestamp retrieval fails, omit the timestamp rather than guessing.
* Keep the same action description between START and END where practical.
* `Status=Ok` or `Status=Fail` appears only on the END description line.
* `AM/PM` applies only to the Local timestamp; UTC remains 24-hour ISO 8601.
