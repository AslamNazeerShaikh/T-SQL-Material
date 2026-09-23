## response style

- Answer in tabular form whenever the answer has comparable items, options, steps, or findings — tables first, prose only for what doesn't fit a table. Keep tables detailed (all relevant columns), not terse. Always add metrics notation to the column names of the table if applicable.
- Explanations the user asks for are always given in full; the "short explanation" default does not apply here.

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

### Required Timestamp Format

At every START and END event, always output **both UTC and Local timestamps** on one timestamp line joined by `|` with one space each side. The Local line always reflects the machine's own timezone (offset + abbreviation are dynamic, never hardcoded).

#### UTC

```text
UTC: 2026-09-23T14:54:02Z [UTC]
```

Format:

```text
UTC: YYYY-MM-DDTHH:MM:SSZ [UTC]
```

24-hour, `Z` suffix, `[UTC]` tag.

#### Local

Local with `AM/PM` (machine's own timezone — offset and abbreviation are dynamic):

```text
Local: 2026-09-23 08:24:02 PM +HH:MM [ABBR]
```

Format pattern:

```text
Local: YYYY-MM-DD hh:mm:ss AM/PM +HH:MM [ABBR]
```

| Part | Example | Meaning |
|---|---|---|
| `Local:` | `Local:` | Timezone label (always `Local:`, never a hardcoded zone) |
| `YYYY` | `2026` | 4-digit year |
| `MM` | `09` | 2-digit month |
| `DD` | `23` | 2-digit day |
| `hh` | `08` | 12-hour clock (`%I`) |
| `mm` | `24` | Minutes |
| `ss` | `02` | Seconds |
| `AM/PM` | `PM` | 12-hour indicator (`%p`) |
| `+HH:MM` | `+HH:MM` | Machine's UTC offset (`%z` with colon inserted) |
| `[ABBR]` | `[ABBR]` | Machine's abbreviation (`[%Z]`) |

Timestamp pair (digits are illustrative; offset/abbreviation come from the machine clock):

```text
UTC: 2026-09-23T14:54:02Z [UTC]
Local: 2026-09-23 08:24:02 PM +HH:MM [ABBR]
```

### START: Format

Three lines — header, timestamp line (only timestamps, `|` with one space each side), description:

```text
--- Start ---
UTC: 2026-09-23T14:54:02Z [UTC] | Local: 2026-09-23 08:24:02 PM +HH:MM [ABBR]
<what started>
```

### END: Format

Three lines — header, timestamp line (only timestamps, `|` with one space each side), description + status line:

```text
--- End ---
UTC: 2026-09-23T14:54:10Z [UTC] | Local: 2026-09-23 08:24:10 PM +HH:MM [ABBR]
<what ended> | Status=Ok
```

Use `Status=Fail` instead of `Status=Ok` when the command/task fails. Do NOT append `AM/PM` to 24-hour ISO 8601 times (e.g. `20:24:02` is already 24-hour; `20:24:02 PM` is invalid).

### Obtaining the Timestamps

The implementation must work on **macOS, Linux, and Windows**.

#### macOS / Linux

UTC:

```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

Local timezone (machine's own zone, 12-hour with `AM/PM`):

```bash
date +"%Y-%m-%d %I:%M:%S %p %z [%Z]"
```

Convert the local timezone output from:

```text
2026-09-23 08:24:02 PM +HHMM [ABBR]
```

to:

```text
2026-09-23 08:24:02 PM +HH:MM [ABBR]
```

Render it as:

```text
Local: 2026-09-23 08:24:02 PM +HH:MM [ABBR]
```

Note: macOS BSD `date` does not support `%E`/`%O` modifiers or GNU `%N`; if `%:z` prints literally as `:z` on macOS, use the `%z` form above and insert the colon, or use the Python 3 alternative below. Here `%I` = 12-hour clock and `%p` = `AM`/`PM`.

Alternatively, Python 3 can be used:

```bash
python3 -c "import datetime; print(datetime.datetime.now().astimezone().isoformat(timespec='seconds'))"
```

For example:

```text
2026-09-23T20:24:02+HH:MM
```

Render it as:

```text
Local: 2026-09-23T20:24:02+HH:MM [ABBR]
```

For the Local `AM/PM` line, convert `20:24:02+HH:MM` to `08:24:02 PM +HH:MM [ABBR]` (i.e. `Local: 2026-09-23 08:24:02 PM +HH:MM [ABBR]`).

#### Windows

PowerShell:

```powershell
(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
```

For local time with the numeric UTC offset:

```powershell
$now = Get-Date
$offset = [System.TimeZoneInfo]::Local.GetUtcOffset($now)
$sign = if ($offset -ge [TimeSpan]::Zero) { "+" } else { "-" }
$offset = $offset.Duration().ToString("hh\:mm")
"Local $($now.ToString('yyyy-MM-ddTHH:mm:ss'))$sign$offset [$([System.TimeZoneInfo]::Local.StandardName)]"
```

### Important Rules

* Always log **both UTC and Local timestamps**.
* Always log timestamps at both **START and END**.
* Never fabricate or estimate a timestamp.
* Use the actual system clock.
* The UTC timestamp must end with `Z` and `[UTC]`.
* The Local timestamp must use 12-hour wall-clock with `AM`/`PM`, numeric offset, and bracket tag (`Local: YYYY-MM-DD hh:mm:ss AM/PM +HH:MM [ABBR]`).
* UTC `14:54:02Z` and Local `08:24:02 PM` in the example share the same date (offset applied).
* Do not log timestamps for intermediate tool calls or internal operations.
* If obtaining a timestamp fails, **omit that timestamp rather than guessing or fabricating it**.
* Preserve the same event/action description between START and END where practical.
* END: records must include `Status=Ok` or `Status=Fail` on the description line below the timestamps (never on the timestamp line itself).

### Example

```text
--- Start ---
UTC: 2026-09-23T14:54:02Z [UTC] | Local: 2026-09-23 08:24:02 PM +HH:MM [ABBR]
Running CLI command

--- End ---
UTC: 2026-09-23T14:54:10Z [UTC] | Local: 2026-09-23 08:24:10 PM +HH:MM [ABBR]
CLI command completed | Status=Ok
```
