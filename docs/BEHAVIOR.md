# Cleaning and Scheduling Behavior

This document explains how ACC performs automatic and manual cleaning.

## 1. Startup

After Android finishes booting, ACC waits for an additional 60 seconds before starting its background service loop.

The service then initializes its schedule state and updates the module description.

## 2. Automatic Schedule

By default, ACC schedules cleanup for 12:00 AM.

The service periodically checks:

- Current local date.
- Current local hour.
- Previously recorded cleaning date.

A scheduled cleanup can start when the date changes and the configured `RUN_HOUR` has been reached.

### Device Sleep Behavior

If the device is asleep at midnight, the service can detect the date change after the device wakes up.

The cleanup can then run once the configured hour has been reached.

### First Installation

When the service first initializes, it records the current date.

Therefore, ACC does not immediately run the scheduled cleanup on the installation day.

## 3. Manual Cleaning

ACC supports manual cleaning through the Action button in Magisk or KernelSU.

Manual cleaning executes the same script used by the automatic service.

A lock directory prevents multiple cleanup sessions from running simultaneously.

## 4. Cleaning Sequence

The current cleaning process has four stages.

### Stage 1: Application Cache

ACC searches supported application cache and code-cache directories.

It skips packages listed in `exclude.txt`.

### Stage 2: Leftover Folders

If enabled, ACC collects installed package lists and checks selected external-storage folders.

Folders whose package names are missing from the collected list may be deleted.

See [SAFETY.md](SAFETY.md) for important limitations.

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

\`\`\`text
Cache: 125.4 MB
\`\`\`

This number represents supported application-cache locations.

It does not represent every file that may be removed by all cleanup stages.

## 6. Logs

Scheduled cleanup output is written to:

\`\`\`
/data/adb/cache_cleaner/last_run.log
\`\`\`

Manual cleanup output is displayed through the module manager's Action interface.

## 7. Notifications

When `SHOW_TOAST=1`, ACC attempts to display a cleanup result.

The notification method depends on available Android components and ROM behavior.

A missing notification does not necessarily mean the cleaning operation failed.
