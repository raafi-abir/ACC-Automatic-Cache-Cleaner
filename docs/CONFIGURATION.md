# Configuration Guide

ACC provides a simple configuration system that allows users to customize automatic cleaning behavior. You can change every option in the module's **WebUI** (KernelSU, KernelSU Next, APatch, MMRL) or by editing the files below.

All configuration files are stored in:

```
/data/adb/cache_cleaner/
```

Directory structure:

```
cache_cleaner/
├── config.sh
├── exclude.txt
├── last_run.log
└── last_run_daynum
```

`last_run.log` and `last_run_daynum` are written by ACC. Do not edit them.

## 1. Configuration File

Open:

```
/data/adb/cache_cleaner/config.sh
```

Default configuration:

```bash
FREQ=daily
WEEK_DAY=0
MONTH_DAY=1
INTERVAL_DAYS=3
RUN_HOUR=0
CLEAN_CACHE=1
CLEAN_CORPSES=1
CLEAN_JUNK=1
SHOW_TOAST=1
SCAN_INTERVAL_MIN=60
```

### Available Options

| Variable          | Default | Description                                                    |
|-------------------|--------:|----------------------------------------------------------------|
| FREQ              | daily   | How often cleaning runs: `daily`, `weekly`, `monthly`, `custom` |
| WEEK_DAY          | 0       | Weekly: day of the week (0 = Sunday ... 6 = Saturday)          |
| MONTH_DAY         | 1       | Monthly: day of the month (1-28)                               |
| INTERVAL_DAYS     | 3       | Custom: clean every N days (1-365)                             |
| RUN_HOUR          | 0       | Hour after which a scheduled cleanup may start (0-23)          |
| CLEAN_CACHE       | 1       | Enables application cache cleaning                             |
| CLEAN_CORPSES     | 1       | Enables leftover-folder detection                              |
| CLEAN_JUNK        | 1       | Enables selected junk cleaning                                 |
| SHOW_TOAST        | 1       | Enables cleanup result notification attempts                   |
| SCAN_INTERVAL_MIN | 60      | Cache-size refresh interval in minutes (5-1440)                |

The file is read as plain `KEY=VALUE` lines (nothing in it is ever executed). Comments after `#`, blank lines and Windows line endings are fine.

Invalid or out-of-range values fall back to a safe value (for example an unknown `FREQ` becomes `daily`, and `MONTH_DAY=40` becomes `28`).

### FREQ

Controls how often the automatic cleanup runs.

| Value     | Behavior                                                                  |
|-----------|---------------------------------------------------------------------------|
| `daily`   | Every day                                                                 |
| `weekly`  | Once a week, on `WEEK_DAY`                                                |
| `monthly` | Once a month, on `MONTH_DAY`                                              |
| `custom`  | Every `INTERVAL_DAYS` days, counted from the previous cleanup             |

Examples:

```bash
# every Sunday
FREQ=weekly
WEEK_DAY=0

# the 15th of every month
FREQ=monthly
MONTH_DAY=15

# every 10 days
FREQ=custom
INTERVAL_DAYS=10
```

`MONTH_DAY` is limited to 1-28 so that the day exists in every month.

If a scheduled cleanup is missed because the device was off or asleep, it runs as soon as the device is awake again. A manual cleanup (Action button or WebUI) counts as the latest cleanup, which matters most for `custom`, because the next run is counted from it.

### RUN_HOUR

Controls the earliest hour of the scheduled day at which cleanup may start.

Uses the device's local 24-hour clock.

| Value | Time     |
|------:|----------|
| 0     | 12:00 AM |
| 6     | 6:00 AM  |
| 12    | 12:00 PM |
| 18    | 6:00 PM  |
| 23    | 11:00 PM |

Example:

```bash
RUN_HOUR=2
```

This allows the scheduled cleanup to run from 2:00 AM onward.

### CLEAN_CACHE

Controls application cache cleaning.

```bash
CLEAN_CACHE=1
```

- `1` — Enabled
- `0` — Disabled

The app currently on screen is skipped.

### CLEAN_CORPSES

Controls leftover-folder detection and removal.

```bash
CLEAN_CORPSES=0
```

- `1` — Enabled
- `0` — Disabled

**Warning:** The current detection mechanism uses a basic package-list completeness check. Disabling this option is recommended if you are unsure about its behavior.

### CLEAN_JUNK

Controls cleaning of selected temporary files and logs.

```bash
CLEAN_JUNK=1
```

- `1` — Enabled
- `0` — Disabled

### SHOW_TOAST

Controls whether ACC attempts to display a cleanup result notification.

```bash
SHOW_TOAST=1
```

- `1` — Enabled
- `0` — Disabled

Notification behavior depends on Android and ROM support.

### SCAN_INTERVAL_MIN

Controls how frequently ACC refreshes the estimated cleanable cache size shown in the module description.

```bash
SCAN_INTERVAL_MIN=120
```

The value is measured in minutes.

## 2. Application Exclusions

Open:

```
/data/adb/cache_cleaner/exclude.txt
```

Add package names, one per line.

Example:

```text
# Important applications
com.example.game
com.example.music
com.example.browser
```

Rules:

- One package name per line.
- Blank lines are ignored.
- Lines beginning with `#` are comments.
- Package matching is exact and case-sensitive.

The exclusion list applies to application-cache cleaning and leftover-folder cleaning.

It does not exclude files from general junk cleanup or prevent logcat from being cleared.

## 3. Recommended Configuration

For users who prefer a conservative setup:

```bash
FREQ=weekly
WEEK_DAY=0
RUN_HOUR=3
CLEAN_CACHE=1
CLEAN_CORPSES=0
CLEAN_JUNK=1
SHOW_TOAST=1
SCAN_INTERVAL_MIN=120
```

This cleans cache and selected junk once a week at 3:00 AM or later while disabling leftover-folder deletion.

## 4. Applying Changes

Using the WebUI: change the options and tap **Save changes**.

Using the file:

1. Open the configuration file using a root-capable file manager.
2. Edit the desired values.
3. Save the file.
4. ACC reloads its settings every minute during normal service operation and when a cleanup begins.

Always keep a backup of your configuration before making changes.
