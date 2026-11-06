# ACC — Automatic Cache Cleaner

**A lightweight root module for scheduled Android cache and junk cleanup.**

ACC (Automatic Cache Cleaner) is a Magisk / KernelSU module designed to automatically clean application cache, detect selected leftover folders, and remove specific temporary files from your Android device.

It runs automatically on a schedule you choose (daily by default, or weekly, monthly or every N days) and also supports manual cleaning through your root manager.

**Lightweight · Automated · Configurable**

## Features

- **Automatic Cleaning:** Runs daily at 12:00 AM by default. You can switch to weekly, monthly or a custom number of days.
- **Flexible Schedule:** Pick the weekday, the day of the month, or an interval of 1 to 365 days, and the time of day.
- **Manual Cleaning:** Start cleanup anytime using the module's Action button or the WebUI.
- **App Cache Cleaning:** Removes contents of application cache and code-cache directories. The app currently on screen is skipped so it cannot crash mid-use.
- **Leftover Folder Detection:** Identifies selected folders belonging to uninstalled applications.
- **Junk Cleaning:** Cleans selected logs, thumbnails, and temporary directories.
- **Live Cache Information:** Displays the estimated cleanable app-cache size in the module description.
- **WebUI Settings:** Change every option, edit the exclude list and run a cleanup from a settings page inside your root manager.
- **App Exclusions:** Exclude specific applications from cache and leftover-folder cleaning.
- **OTA Updates:** Supports update metadata for compatible Magisk and KernelSU managers.

## Requirements

- Android device with root access.
- Magisk (recent version with module Action support, 27+), KernelSU, KernelSU Next or APatch.
- WebUI requires KernelSU, KernelSU Next, APatch or MMRL. Magisk's own app cannot open module web pages; edit the config file instead.

## Installation

1. Visit the [Releases](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/releases) page.
2. Download the latest ACC ZIP.
3. Open Magisk or KernelSU.
4. Install the downloaded ZIP.
5. Reboot if requested.

After installation, ACC creates its configuration files automatically.

## How It Works

### Automatic Cleaning

ACC runs in the background and checks the device's local date and time.

By default, cleanup is scheduled for midnight (12:00 AM) every day. Choose a different frequency in the WebUI or with `FREQ` in the configuration file:

| Frequency | `FREQ`    | Extra setting                    | Runs                                         |
|-----------|-----------|----------------------------------|----------------------------------------------|
| Daily     | `daily`   | none                             | Every day                                    |
| Weekly    | `weekly`  | `WEEK_DAY` (0 = Sunday ... 6)    | On that weekday                              |
| Monthly   | `monthly` | `MONTH_DAY` (1-28)               | On that day of the month                     |
| Custom    | `custom`  | `INTERVAL_DAYS` (1-365)          | Every N days after the previous cleanup      |

`RUN_HOUR` sets the time of day after which a scheduled cleanup may start. The WebUI shows when the next cleanup is due.

If your device is asleep or switched off at the scheduled time, cleanup runs once the device wakes up or boots, whatever the frequency.

The first service initialization records the current date, so the scheduled cleaner does not immediately run on the installation day (or right after updating from an older version).

If a manual cleanup is running at the scheduled time, the scheduled run retries automatically instead of being skipped.

### Manual Cleaning

Open your root manager, locate ACC, and tap **Action** to start a cleanup manually. You can also tap **Clean now** in the WebUI. A manual cleanup counts as the latest cleanup for the schedule.

ACC uses the same cleaning process for both automatic and manual runs.

### Cleaning Categories

| Category         | Description                                    |
|------------------|------------------------------------------------|
| App Cache        | Application cache and code-cache contents      |
| Leftover Folders | Selected folders belonging to uninstalled apps |
| System Junk      | Selected logs, thumbnails and temporary files  |
| Logcat           | Clears available Android logcat buffers        |

### Result Message

After each cleanup ACC shows how much was freed. If the *Bellavita Toast* helper app is installed it appears as a toast; otherwise ACC posts a notification. Set `SHOW_TOAST=0` to turn this off.

## WebUI

In KernelSU, KernelSU Next, APatch or MMRL, open the module's **WebUI** page to:

- see the cleanable cache size and run **Clean now** or **Rescan**
- turn each cleaner on or off
- choose how often ACC cleans (daily, weekly, monthly or custom days), the time of day, and the cache-size refresh interval
- see when the next cleanup is due
- edit the list of excluded apps
- view the log of the last run

Changes are saved to the same configuration files described below and apply without a reboot.

## Configuration

ACC stores its configuration outside the module directory:

```
/data/adb/cache_cleaner/
├── config.sh
└── exclude.txt
```

**Default configuration:**

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

| Option            | Default | Description                                         |
|-------------------|--------:|-----------------------------------------------------|
| FREQ              | daily   | Cleaning frequency: `daily`, `weekly`, `monthly` or `custom` |
| WEEK_DAY          | 0       | Weekly: day of the week (0 = Sunday ... 6 = Saturday) |
| MONTH_DAY         | 1       | Monthly: day of the month (1–28)                    |
| INTERVAL_DAYS     | 3       | Custom: clean every N days (1–365)                  |
| RUN_HOUR          | 0       | Hour (0–23) after which a scheduled cleanup may start |
| CLEAN_CACHE       | 1       | Enable application cache cleaning                   |
| CLEAN_CORPSES     | 1       | Enable leftover-folder cleaning                     |
| CLEAN_JUNK        | 1       | Enable selected junk cleaning                       |
| SHOW_TOAST        | 1       | Enable cleanup result toast / notification attempt  |
| SCAN_INTERVAL_MIN | 60      | Cache-size refresh interval in minutes (5–1440)     |

For detailed instructions, see [Configuration Guide](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/docs/CONFIGURATION.md).

**Safety recommendation:** Consider setting `CLEAN_CORPSES=0` until you have reviewed the limitations of leftover-folder detection.

## Excluding Applications

Use the WebUI, or open:

```
/data/adb/cache_cleaner/exclude.txt
```

Add one package name per line:

```
com.example.game
com.example.music
com.example.application
```

Excluded packages are skipped during application-cache and leftover-folder cleaning.

## Safety

ACC uses root permissions to remove files. Deleted files cannot be restored by the module.

- Cache deletion may cause applications to rebuild temporary files.
- Some applications may download cached content again.
- Leftover-folder detection is not guaranteed to be perfect.
- Selected diagnostic logs and crash reports may be permanently removed.
- Always maintain a backup of important files.

Read the [Safety Guide](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/docs/SAFETY.md) before enabling all cleaning options.

## Updating

ACC supports OTA updates. In KernelSU, KernelSU Next, APatch or Magisk, an **Update** button appears on the module when a newer release is published. You can also download the latest ZIP from [Releases](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/releases) and install it over the old version. Your settings and exclude list are kept.

## Versioning

ACC uses simple `major.minor` versions: v1.2, v1.3, v1.4 and so on. Every release has a higher `versionCode` than the one before, which is what lets your root manager offer the update.

## Uninstallation

1. Open Magisk or KernelSU.
2. Find ACC.
3. Select Uninstall (Remove in Magisk).
4. Reboot if requested.

ACC removes its configuration and state directory during uninstallation. Previously deleted files cannot be restored.

## Troubleshooting

**Cache shows "calculating..."**

Wait for the background service to start. The first scan runs about a minute after boot.

**Automatic cleaning did not run**

Check whether ACC is enabled and review `FREQ`, `RUN_HOUR` and the related day setting in the configuration file or WebUI. With weekly, monthly or custom schedules, cleanup only runs on its scheduled day. The WebUI shows the next due date.

**Manual cleaning does not start**

Ensure the module is enabled and that another cleanup session is not already running.

**WebUI does not open or shows a banner**

Use KernelSU, KernelSU Next, APatch or MMRL. Magisk's app cannot open module web pages.

**OTA update does not appear or the download failed**

- `versionCode` in `update.json` must be higher than the installed module's `versionCode`.
- The release tag in `update.json` must match the actual GitHub release tag, including capitalization.
- The ZIP filename in `zipUrl` must match the file uploaded to the release.

## Building from Source

Clone the repository:

```bash
git clone https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner.git
cd ACC-Automatic-Cache-Cleaner
```

**Build:**

```bash
./build.sh
```

The generated ZIP will be available inside `dist/`.

Check `git status` after building because the build script resets the module description before packaging.

## Documentation

- [Configuration Guide](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/docs/CONFIGURATION.md)
- [Safety Guide](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/docs/SAFETY.md)
- [Cleaning and Scheduling](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/docs/BEHAVIOR.md)
- [Contributing Guide](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/CONTRIBUTING.md)
- [Changelog](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/blob/main/changelog.md)

## Disclaimer

ACC is provided "as is", without warranty. Use it at your own risk. The developer is not responsible for data loss, application issues, or device problems resulting from the use of this module.

---

**Developed by [raafi-abir](https://github.com/raafi-abir)**
