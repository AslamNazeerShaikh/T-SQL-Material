# Opencode Configuration for T-SQL-Material

Study repo (Markdown + T-SQL scripts) — no build, no LSP, no mobile toolchains.
Adapted from the CollegeAdmissionManagementSystem config; only repo-relevant
pieces kept, the rest dropped.

## Structure

```
.opencode/
├── opencode.json              # Main configuration (schema-valid)
├── agents/                    # Agent definitions
│   ├── tsql-topic-writer.md   # New topic folders in house format
│   └── sql-reviewer.md        # T-SQL + doc accuracy reviews
├── skills/                    # Skill definitions
│   ├── tsql-study-guide/      # Repo conventions (SKILL.md)
│   └── graphify/              # Knowledge-graph skill (copied as-is)
├── commands/                  # Custom commands
│   └── verify-topic.md        # Validate a topic folder (/verify-topic 11-...)
├── permissions/               # Permission policy (docs; opencode.json enforces)
│   └── default.md
└── plugins/
    └── graphify.js            # Graphify plugin (copied as-is, auto-discovered)
```

## Dropped (not relevant here)

All .NET/Flutter/Gradle/Java/Kotlin agents, commands, skills, `lsp/`,
the college-domain assistant, the ponytail plugin, and the ui-skills MCP.

## Kept MCP

`github` (remote) — repo ops; needs `GITHUB_PERSONAL_ACCESS_TOKEN` in env.

## Usage

```
> skill tsql-study-guide
> /verify-topic 16-window-functions
```

Config loads at startup — quit and restart opencode after changing anything here.
