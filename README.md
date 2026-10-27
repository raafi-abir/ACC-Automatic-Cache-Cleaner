# ACC — Automatic Cache Cleaner

**A lightweight root module for scheduled Android cache and junk cleanup.**

ACC (Automatic Cache Cleaner) is a Magisk / KernelSU module designed to automatically clean application cache, detect selected leftover folders, and remove specific temporary files from your Android device.

It runs automatically once per day and also supports manual cleaning through your root manager.

<p align="center">
  <b>Lightweight · Automated · Configurable</b>
</p>

## Features

- **Automatic Cleaning:** Runs daily at 12:00 AM by default.
- **Manual Cleaning:** Start cleanup anytime using the module's Action button.
- **App Cache Cleaning:** Removes contents of supported application cache and code-cache directories.
- **Leftover Folder Detection:** Identifies selected folders belonging to uninstalled applications.
- **Junk Cleaning:** Cleans selected logs, thumbnails, and temporary directories.
- **Live Cache Information:** Displays the estimated cleanable app-cache size in the module description.
- **App Exclusions:** Exclude specific applications from cache and leftover-folder cleaning.
- **OTA Updates:** Supports update metadata for compatible Magisk and KernelSU managers.

## Requirements

- Android device with root access.
- Magisk or KernelSU.
- Compatible module installation support.

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

By default, cleanup is scheduled for midnight (12:00 AM).

If your device is asleep at the scheduled time, cleanup can run after the device wakes up.

The first service initialization records the current date, so the scheduled cleaner does not immediately run on the installation day.

### Manual Cleaning

Open your root manager, locate ACC, and tap **Action** to start a cleanup manually.

ACC uses the same cleaning process for both automatic and manual runs.

### Cleaning Categories

| Category | Description |
|---|---|
| App Cache | Application cache and code-cache contents |
| Leftover Folders | Selected folders belonging to uninstalled apps |
| System Junk | Selected logs, thumbnails and temporary files |
| Logcat | Clears available Android logcat buffers |

## Configuration

ACC stores its configuration outside the module directory:


/data/adb/cache_cleaner/
├── config.sh
└── exclude.txt

Default configuration:

\`\`\`bash
RUN_HOUR=0
CLEAN_CACHE=1
CLEAN_CORPSES=1
CLEAN_JUNK=1
SHOW_TOAST=1
SCAN_INTERVAL_MIN=5
\`\`\`

| Option | Default | Description |
|---|---:|---|
| RUN_HOUR | 0 | Daily cleaning hour (0–23) |
| CLEAN_CACHE | 1 | Enable application cache cleaning |
| CLEAN_CORPSES | 1 | Enable leftover-folder cleaning |
| CLEAN_JUNK | 1 | Enable selected junk cleaning |
| SHOW_TOAST | 1 | Enable cleanup result notification attempt |
| SCAN_INTERVAL_MIN | 5 | Cache-size refresh interval in minutes |

For detailed instructions, see [Configuration Guide](docs/CONFIGURATION.md).

**Safety recommendation:** Consider setting `CLEAN_CORPSES=0` until you have reviewed the limitations of leftover-folder detection.

## Excluding Applications

Open:

\`\`\`
/data/adb/cache_cleaner/exclude.txt
\`\`\`

Add one package name per line:

\`\`\`
com.example.game
com.example.music
com.example.application
\`\`\`

Excluded packages are skipped during application-cache and leftover-folder cleaning.

## Safety

ACC uses root permissions to remove files. Deleted files cannot be restored by the module.

- Cache deletion may cause applications to rebuild temporary files.
- Some applications may download cached content again.
- Leftover-folder detection is not guaranteed to be perfect.
- Selected diagnostic logs and crash reports may be permanently removed.
- Always maintain a backup of important files.

Read the [Safety Guide](docs/SAFETY.md) before enabling all cleaning options.

## Uninstallation

1. Open Magisk or KernelSU.
2. Find ACC.
3. Select Uninstall.
4. Reboot if requested.

ACC removes its configuration and state directory during uninstallation. Previously deleted files cannot be restored.

## Troubleshooting

**Cache shows "calculating..."**

Wait for the background service to start and perform its first scan.

**Automatic cleaning did not run**

Check whether ACC is enabled and review `RUN_HOUR` in the configuration file.

**Manual cleaning does not start**

Ensure the module is enabled and that another cleanup session is not already running.

**OTA update download failed**

Verify that the release tag in `update.json` matches the actual GitHub release tag, including capitalization. Also verify the ZIP filename.

## Building from Source

Clone the repository:

\`\`\`bash
git clone https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner.git
cd ACC-Automatic-Cache-Cleaner
\`\`\`

Build:

\`\`\`bash
./build.sh
\`\`\`

The generated ZIP will be available inside `dist/`.

Check `git status` after building because the build script resets the module description before packaging.

## Documentation

- [Configuration Guide](docs/CONFIGURATION.md)
- [Safety Guide](docs/SAFETY.md)
- [Cleaning and Scheduling](docs/BEHAVIOR.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Changelog](changelog.md)

## Disclaimer

ACC is provided "as is", without warranty. Use it at your own risk. The developer is not responsible for data loss, application issues, or device problems resulting from the use of this module.

---

**Developed by [raafi-abir](https://github.com/raafi-abir)**
