---
name: remind
description: Create a timed local reminder using the remindme CLI. Use when the user says "remind me to…", "set a reminder for…", "remind me about…", or "remind me of…".
disable-model-invocation: false
allowed-tools: Bash(remindme *)
argument-hint: "[what to remember and when, e.g. 'review the deploy PR monday 9am']"
---

## Task

Create a reminder by running the `remindme` CLI at `~/.local/bin/remindme`.

## Steps

### 1. Parse the request

From $ARGUMENTS, extract:
- **title**: 3–6 word label for the reminder
- **description**: one sentence summarising what to remember
- **content**: all relevant details; if sparse, same as description
- **at**: when to trigger — preserve the user's phrasing (e.g. `monday 9am`, `tomorrow 2pm`, `in 2 hours`) or use absolute form `2026-05-26 09:00`

If no time is given, ask before proceeding.

### 2. Run the command

remindme -t "<title>" -d "<description>" -c "<content>" -a "<at>"

### 3. Confirm

Report back what was set and when, in plain language. Example: "Reminder set for Monday, May 26 at 9:00 AM — 'Review deploy PR'"
