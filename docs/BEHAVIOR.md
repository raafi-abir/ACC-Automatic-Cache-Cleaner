# Cleaning and Scheduling Behavior

This document explains how ACC performs automatic and manual cleaning.

## 1. Startup

After Android finishes booting, ACC waits for an additional 60 seconds before starting its background service loop.

The service then initializes its schedule state and updates the module description.

## 2. Automatic Schedule

By default, ACC schedules cleanup for 12:00 AM every day. The frequency is set with `FREQ`:

| `FREQ`    | Scheduled day                                              |
|-----------|------------------------------------------------------------|
| `daily`   | Every day                                                  |
| `weekly`  | The weekday given by `WEEK_DAY` (0 = Sunday ... 6 = Saturday) |
| `monthly` | The day of the month given by `MONTH_DAY` (1-28)           |
| `custom`  | `INTERVAL_DAYS` days after the previous cleanup            |

Once a minute the service checks:

- Current local date and hour.
- The day of the last recorded cleanup (`last_run_daynum`).
- The configured frequency, day settings and `RUN_HOUR`.

A cleanup is due when the most recent scheduled day has not been cleaned yet and either that day has already passed, or it is today and `RUN_HOUR` has been reached.

The WebUI shows the next due date using the same rules.

### Device Sleep and Power-Off Behavior

If the device is asleep or switched off on the scheduled day, the service notices once the device is awake again and runs the cleanup then, for every frequency. A missed cleanup is not skipped. It runs once, not once per missed day.

### First Installation and Updates

When the service first initializes, it records the current date as the last cleanup.

Therefore, ACC does not immediately run a scheduled cleanup on the installation day, or right after updating from a version before v1.2 (which stored the date in a different file).

### Clock Changes

If the recorded last cleanup is in the future (for example, the system clock was set back), ACC treats today as the last cleanup date.

## 3. Manual Cleaning

ACC supports manual cleaning through the Action button in Magisk, KernelSU, KernelSU Next and APatch, and through **Clean now** in the WebUI.

Manual cleaning executes the same script used by the automatic service, and counts as the latest cleanup for the schedule.

A lock directory prevents multiple cleanup sessions from running simultaneously. The lock records the process that owns it. If that process was killed, the next run takes the lock over, so a crashed cleanup cannot block later ones.

If a scheduled cleanup finds another cleanup running, it does not mark the day as done and retries on the next check.

## 4. Cleaning Sequence

The current cleaning process has four stages.

### Stage 1: Application Cache

ACC searches supported application cache and code-cache directories.

It skips packages listed in `exclude.txt` and the app currently on screen.

### Stage 2: Leftover Folders

If enabled, ACC collects installed package lists and checks selected external-storage folders.

Folders whose package names are missing from the collected list may be deleted.

See [SAFETY.md](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/docs/SAFETY.md) for important limitations.

### Stage 3: Selected Junk

ACC clears contents of selected directories containing:

- Tombstones.
- ANR traces.
- DropBox logs.
- Thumbnails.
- LOST.DIR contents.

It also attempts to clear logcat buffers.

### Stage 4: Report

ACC calculates approximate cleaned sizes and displays a report.

The report contains:

- Cache cleaned.
- Leftover folders removed.
- Junk cleaned.
- Total estimated amount.

## 5. Live Cache Information

ACC periodically calculates the estimated cleanable application-cache size.

The result is displayed in the module description.

Example:

```text
Cache: 125.4 MB
```

This number represents supported application-cache locations.

It does not represent every file that may be removed by all cleanup stages.

## 6. Logs

Scheduled cleanup output is written to:

```
/data/adb/cache_cleaner/last_run.log
```

Manual cleanup output is displayed through the module manager's Action interface and the WebUI.

## 7. Notifications

When `SHOW_TOAST=1`, ACC attempts to display a cleanup result.

The notification method depends on available Android components and ROM behavior.

A missing notification does not necessarily mean the cleaning operation failed.
