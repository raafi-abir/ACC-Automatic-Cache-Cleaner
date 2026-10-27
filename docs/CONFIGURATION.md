# Configuration Guide

ACC provides a simple configuration system that allows users to customize automatic cleaning behavior.

All configuration files are stored in:

\`\`\`
/data/adb/cache_cleaner/
\`\`\`

Directory structure:

\`\`\`
cache_cleaner/
├── config.sh
└── exclude.txt
\`\`\`

## 1. Configuration File

Open:

\`\`\`
/data/adb/cache_cleaner/config.sh
\`\`\`

Default configuration:

\`\`\`bash
RUN_HOUR=0
CLEAN_CACHE=1
CLEAN_CORPSES=1
CLEAN_JUNK=1
SHOW_TOAST=1
SCAN_INTERVAL_MIN=5
\`\`\`

### Available Options

| Variable | Default | Description |
|---|---:|---|
| RUN_HOUR | 0 | Hour when daily cleaning is allowed |
| CLEAN_CACHE | 1 | Enables application cache cleaning |
| CLEAN_CORPSES | 1 | Enables leftover-folder detection |
| CLEAN_JUNK | 1 | Enables selected junk cleaning |
| SHOW_TOAST | 1 | Enables cleanup result notification attempts |
| SCAN_INTERVAL_MIN | 5 | Cache-size refresh interval |

### RUN_HOUR

Controls the hour of the daily cleaning schedule.

Uses the device's local 24-hour clock.

| Value | Time |
|---:|---|
| 0 | 12:00 AM |
| 6 | 6:00 AM |
| 12 | 12:00 PM |
| 18 | 6:00 PM |
| 23 | 11:00 PM |

Example:

\`\`\`bash
RUN_HOUR=2
\`\`\`

This allows the daily cleanup to run from 2:00 AM onward.

### CLEAN_CACHE

Controls application cache cleaning.

\`\`\`bash
CLEAN_CACHE=1
\`\`\`

- `1` — Enabled
- `0` — Disabled

### CLEAN_CORPSES

Controls leftover-folder detection and removal.

\`\`\`bash
CLEAN_CORPSES=0
\`\`\`

- `1` — Enabled
- `0` — Disabled

**Warning:** The current detection mechanism uses a basic package-list completeness check. Disabling this option is recommended if you are unsure about its behavior.

### CLEAN_JUNK

Controls cleaning of selected temporary files and logs.

\`\`\`bash
CLEAN_JUNK=1
\`\`\`

- `1` — Enabled
- `0` — Disabled

### SHOW_TOAST

Controls whether ACC attempts to display a cleanup result notification.

\`\`\`bash
SHOW_TOAST=1
\`\`\`

- `1` — Enabled
- `0` — Disabled

Notification behavior depends on Android and ROM support.

### SCAN_INTERVAL_MIN

Controls how frequently ACC refreshes the estimated cleanable cache size shown in the module description.

\`\`\`bash
SCAN_INTERVAL_MIN=10
\`\`\`

The value is measured in minutes.

## 2. Application Exclusions

Open:

\`\`\`
/data/adb/cache_cleaner/exclude.txt
\`\`\`

Add package names, one per line.

Example:

\`\`\`text
# Important applications
com.example.game
com.example.music
com.example.browser
\`\`\`

Rules:

- One package name per line.
- Blank lines are ignored.
- Lines beginning with `#` are comments.
- Package matching is exact and case-sensitive.

The exclusion list applies to application-cache cleaning and leftover-folder cleaning.

It does not exclude files from general junk cleanup or prevent logcat from being cleared.

## 3. Recommended Configuration

For users who prefer a conservative setup:

\`\`\`bash
RUN_HOUR=0
CLEAN_CACHE=1
CLEAN_CORPSES=0
CLEAN_JUNK=1
SHOW_TOAST=1
SCAN_INTERVAL_MIN=10
\`\`\`

This enables normal cache and selected junk cleaning while disabling leftover-folder deletion.

## 4. Applying Changes

1. Open the configuration file using a root-capable file manager.
2. Edit the desired values.
3. Save the file.
4. ACC reloads its settings during normal service operation and when a cleanup begins.

Always keep a backup of your configuration before making changes.
