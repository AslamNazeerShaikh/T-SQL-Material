---
name: default
description: Default permissions for the T-SQL-Material study repo
version: 1.0.0
# NOTE: opencode.json > permission is the enforced mechanism.
# This file documents the intended policy for humans.
allow:
  # File operations
  - tool: read
    description: Read any file in the project
  - tool: write
    description: Write new files
  - tool: edit
    description: Edit existing files
  - tool: glob
    description: Find files by pattern
  - tool: grep
    description: Search file contents

  # Task operations
  - tool: task
    description: Launch sub-agents for complex tasks

  # Bash operations (safe, read-only + git)
  - tool: bash
    args:
      - git status
      - git diff
      - git log *
      - git branch
      - git show *
      - ls *

  # Web operations
  - tool: webfetch
    description: Fetch documentation and resources

deny:
  # Dangerous bash commands
  - tool: bash
    args:
      - rm -rf *
      - rm -rf /
      - sudo *
      - chmod 777 *
      - chown -R *
      - git push --force *
      - git reset --hard HEAD~*
      - curl * | bash
      - wget * | bash

  # Toolchain installs are never automatic (see AGENTS.md):
  # no brew install, npm i -g, pip install, SDK downloads, etc.
  - tool: bash
    args:
      - brew install *
      - npm i -g *
      - pip install *
      - apt * install *

  # File operations on sensitive files
  - tool: write
    args:
      - ".env*"
      - "*.key"
      - "*.pem"
      - "*.p12"
      - "secrets.*"
      - "credentials.*"

  - tool: read
    args:
      - ".env*"
      - "*.key"
      - "*.pem"
      - "*.p12"
      - "secrets.*"
      - "credentials.*"
