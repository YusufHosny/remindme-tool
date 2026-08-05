---
name: remind
description: Create a timed local reminder using the remindme CLI, or fire one instantly to notify the user that a task has finished. Use when the user says "remind me to…", "set a reminder for…", "remind me about…", "remind me of…", or asks to be reminded/notified/pinged when something is done or finishes.
disable-model-invocation: false
allowed-tools: Bash(remindme *)
argument-hint: "[what to remember and when, e.g. 'review the deploy PR monday 9am']"
---

## Task

Create a reminder by running the `remindme` CLI at `~/.local/bin/remindme`.

Two modes:

- **Scheduled** (`-a`) — fires at a future time. The default.
- **Instant** (`--now`) — pops the dialog immediately. Use this to tell the user that work
  they asked about has finished.

## Steps

### 1. Pick the mode

Use **instant** (`--now`) when the reminder is about something that has just happened rather
than a future clock time — the user asked to be told when a task, build, deploy, or run
completes. Signals: "remind me when it's done", "ping me when the build finishes", "let me
know once the tests pass", "tell me when you're finished".

In that case do the work first and fire the reminder as the last step, so the notification
means the task is genuinely complete.

Use **scheduled** (`-a`) for anything anchored to a future time.

If the request is scheduled but names no time, ask before proceeding — do not substitute
`--now` for a missing time, they mean different things.

### 2. Parse the request

From $ARGUMENTS, extract:
- **title**: 3–6 word label for the reminder
- **description**: one sentence summarising what to remember. For instant reminders state the
  outcome — "migration finished, 3 tables updated" beats "task done".
- **content**: all relevant details; if sparse, same as description. For instant reminders put
  the results the user will want here: what ran, what passed or failed, paths, next step.
- **at** (scheduled only): when to trigger — preserve the user's phrasing (e.g. `monday 9am`,
  `tomorrow 2pm`, `in 2 hours`) or use absolute form `2026-05-26 09:00`

### 3. Run the command

Scheduled:

    remindme -t "<title>" -d "<description>" -c "<content>" -a "<at>"

Instant:

    remindme -t "<title>" -d "<description>" -c "<content>" --now

`--at` and `--now` are mutually exclusive. `--now` returns immediately — the dialog runs in a
detached process and never blocks you. Fire it and finish your turn; do not wait on or poll
the dialog.

### 4. Confirm

Report back in plain language.

- Scheduled: "Reminder set for Monday, May 26 at 9:00 AM — 'Review deploy PR'"
- Instant: "Popped a reminder just now — 'Migration finished'"
