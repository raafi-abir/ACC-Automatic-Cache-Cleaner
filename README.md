# ACC — Automatic Cache Cleaner

**A lightweight, configurable root module for automated Android cache and junk cleanup.**

ACC (Automatic Cache Cleaner) is a Magisk / KernelSU module designed to clean application cache, detect selected leftover folders, and remove specific temporary files from your Android device.

It runs automatically once per day and also supports manual cleaning whenever you need it.

<p align="center">
  <b>Lightweight · Automated · Configurable</b>
</p>

## ✨ Features

- **Automatic Cleaning:** Runs daily at 12:00 AM by default.
- **Manual Cleaning:** Start cleanup anytime using the module's Action button.
- **App Cache Cleaning:** Cleans supported application cache and code-cache directories.
- **Leftover Folder Detection:** Identifies selected folders belonging to uninstalled applications.
- **Junk Cleaning:** Removes selected logs, thumbnails, and temporary files.
- **Logcat Cleaning:** Clears available Android logcat buffers.
- **Live Cache Information:** Displays the estimated cleanable application-cache size directly in the module card.
- **Toast Notifications:** Attempts to display a notification after cleanup.
- **WebUI Configuration:** Configure supported settings through compatible root-manager WebUI interfaces.
- **App Exclusions:** Exclude specific applications from application-cache and leftover-folder cleaning.
- **Custom Schedule:** Change the daily cleaning hour.
- **Configurable Scanning:** Adjust how frequently the estimated cleanable cache size is refreshed.
- **OTA Updates:** Supports update metadata through `update.json` for compatible module managers.

## 📱 Requirements

- An Android device with root access.
- Magisk, KernelSU, KernelSU Next, APatch, or another compatible environment, subject to module-manager support.
- A compatible module installation mechanism.

**Note:** WebUI availability depends on your root manager and its support for module WebUI interfaces. Magisk's standard app does not provide the same module WebUI functionality as supported managers.

## 📥 Installation

1. Visit the [Releases](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/releases) page.
2. Download the latest ACC ZIP package.
3. Open your supported root manager.
4. Select the option to install a module from storage.
5. Choose the downloaded ZIP file.
6. Follow the installation instructions and reboot if requested.

After installation, ACC creates its configuration files automatically.

## ⚙️ How It Works

### Automatic Cleaning

ACC runs a background service that checks the device's local date and time.

By default, the cleaner is scheduled to run at **12:00 AM (midnight)**.

- The cleaning schedule uses the device's local time.
- If the device is asleep at the scheduled time, cleanup can run after the device wakes up.
- The first service initialization records the current date, preventing the scheduled cleaner from immediately running on the installation day.
- The service tracks its daily execution to avoid repeatedly running the scheduled cleanup.

Actual execution depends on the device's state and the module's service behavior.

### Manual Cleaning

Want to clean your cache immediately?

1. Open your root manager.
2. Find ACC in the installed modules list.
3. Tap the **Action** button.
4. Wait for the cleanup process to finish.

ACC uses the same cleaning process for automatic and manual runs.

### Cleaning Categories

| Category | Description |
|---|---|
| App Cache | Cleans supported application-cache and code-cache contents. |
| Leftover Folders | Detects and removes selected folders associated with uninstalled applications. |
| System Junk | Removes selected logs, thumbnails, and temporary files. |
| Logcat | Clears available Android logcat buffers. |

**Important:** The module does not indiscriminately delete every file on your device. Its cleaning behavior depends on the supported directories and configured cleaning options.

## 🖥️ WebUI and Configuration

ACC supports a WebUI settings page in compatible environments, including supported configurations of KernelSU, KernelSU Next, APatch, and MMRL.

Depending on the available interface, settings include:

- Enabling or disabling individual cleaning categories.
- Changing the scheduled cleaning hour.
- Adjusting the cache-size scan interval.
- Managing application exclusions.
- Triggering cleanup manually.

If your root manager does not support the module's WebUI, you can configure ACC by editing its configuration files directly.

### Configuration Files

ACC stores its configuration outside the module directory:

```text
/data/adb/cache_cleaner/
├── config.sh
└── exclude.txt
```

- `config.sh` contains the cleaning settings.
- `exclude.txt` contains the application package names to exclude.

### Default Configuration

The default configuration is:

```bash
RUN_HOUR=0
CLEAN_CACHE=1
CLEAN_CORPSES=1
CLEAN_JUNK=1
SHOW_TOAST=1
SCAN_INTERVAL_MIN=5
```

### Available Options

| Option | Default | Description |
|---|---:|---|
| `RUN_HOUR` | `0` | Daily cleaning hour, from 0 to 23. |
| `CLEAN_CACHE` | `1` | Enables application-cache cleaning. |
| `CLEAN_CORPSES` | `1` | Enables leftover-folder detection and cleaning. |
| `CLEAN_JUNK` | `1` | Enables selected junk cleaning. |
| `SHOW_TOAST` | `1` | Enables attempts to display cleanup result notifications. |
| `SCAN_INTERVAL_MIN` | `5` | Cache-size refresh interval in minutes. |

A value of `1` enables an option, while `0` disables it.

### Changing the Cleaning Schedule

The `RUN_HOUR` setting uses the device's local 24-hour clock.

| Value | Time |
|---:|---|
| `0` | 12:00 AM |
| `6` | 6:00 AM |
| `12` | 12:00 PM |
| `18` | 6:00 PM |
| `23` | 11:00 PM |

For example, to schedule cleaning from 2:00 AM onward:

```bash
RUN_HOUR=2
```

The scheduled cleaner uses this value to determine when daily cleaning is allowed.

### Recommended Conservative Configuration

If you want to avoid automatically deleting potentially important leftover folders, consider the following configuration:

```bash
RUN_HOUR=0
CLEAN_CACHE=1
CLEAN_CORPSES=0
CLEAN_JUNK=1
SHOW_TOAST=1
SCAN_INTERVAL_MIN=10
```

This keeps application-cache cleaning and selected junk cleaning enabled while disabling leftover-folder cleaning.

For more information, read the [Configuration Guide](docs/CONFIGURATION.md).

## 🚫 Excluding Applications

ACC allows you to exclude specific applications from application-cache and leftover-folder cleaning.

Open:

```text
/data/adb/cache_cleaner/exclude.txt
```

Add one application package name per line.

For example:

```text
# Important applications
com.example.game
com.example.music
com.example.browser
```

### Exclusion Rules

- Use one package name per line.
- Blank lines are ignored.
- Lines beginning with `#` are comments.
- Package matching is exact and case-sensitive.
- Exclusions apply to application-cache and leftover-folder cleaning.

**Note:** The exclusion list does not exclude files from general junk cleaning or prevent logcat buffers from being cleared.

## 🔔 Cache Information and Notifications

### Live Cache Information

ACC displays the estimated cleanable application-cache size in the module description.

The displayed value is refreshed periodically according to `SCAN_INTERVAL_MIN`.

After installation or service startup, the module may initially display:

```text
Cache: calculating...
```

This is expected while the initial cache scan is being performed.

### Cleanup Notifications

When `SHOW_TOAST=1`, ACC attempts to display a notification after cleanup.

Notification behavior depends on Android, ROM restrictions, and the device's environment.

## 🛡️ Safety and Limitations

ACC uses root permissions to remove files. Deleted files cannot be restored by the module.

Please understand the following limitations before enabling all cleaning options:

- **Cache deletion:** Applications may need to rebuild temporary files or download cached content again.
- **Leftover-folder detection:** Detection is not guaranteed to be perfect. Some folders may be incorrectly identified.
- **Diagnostic logs:** Selected logs and crash reports may be permanently removed.
- **System compatibility:** Cleaning behavior can vary between Android versions, ROMs, and applications.
- **Backups:** Always maintain a backup of important files.

### Recommended Safety Practice

If you are unsure about leftover-folder detection, disable it first:

```bash
CLEAN_CORPSES=0
```

Read the [Safety Guide](docs/SAFETY.md) before enabling all cleaning options.

## 🗑️ Uninstallation

To uninstall ACC:

1. Open your root manager.
2. Locate ACC in the installed modules list.
3. Select **Uninstall**.
4. Reboot if requested.

ACC removes its configuration and state directory during uninstallation.

Previously deleted files cannot be restored by uninstalling the module.

## 🔧 Troubleshooting

### Cache shows "calculating..."

Wait for the background service to start and perform its initial scan.

If the value does not update, check whether the module is enabled and its service is running correctly.

### Automatic cleaning did not run

- Check whether ACC is enabled.
- Verify the `RUN_HOUR` value in `config.sh`.
- Consider whether the device was asleep at the scheduled time.
- Check the module's service logs if available.

### Manual cleaning does not start

- Ensure ACC is enabled.
- Check whether another cleanup session is already running.
- Verify that the module installed correctly.

### WebUI is unavailable

- Check whether your root manager supports module WebUI interfaces.
- Verify that ACC's WebUI files were included in the installed package.
- Try editing `/data/adb/cache_cleaner/config.sh` directly if your manager does not support WebUI.

### OTA update download failed

- Verify that the release tag in `update.json` matches the actual GitHub release tag, including capitalization.
- Check that the ZIP filename matches the published release asset.
- Confirm that the update metadata points to the correct release.

## 🧑‍💻 Building from Source

You can build ACC yourself using the source code.

### 1. Clone the Repository

```bash
git clone https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner.git
cd ACC-Automatic-Cache-Cleaner
```

### 2. Build the Module

Run:

```bash
./build.sh
```

The generated ZIP package will be available inside the `dist/` directory.

### Important Build Note

Check the output of:

```bash
git status
```

The build script resets the module description before packaging. Review any resulting changes before committing them to your repository.

## 📚 Documentation

Explore the additional documentation:

- [Configuration Guide](docs/CONFIGURATION.md) — Customize cleaning settings and exclusions.
- [Safety Guide](docs/SAFETY.md) — Understand cleaning risks and limitations.
- [Cleaning and Scheduling](docs/BEHAVIOR.md) — Learn about cleaning behavior and scheduling.
- [Contributing Guide](CONTRIBUTING.md) — Guidelines for contributing to the project.
- [Changelog](changelog.md) — Review project changes.
- [Releases](https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/releases) — Download available releases.

## 📦 OTA Updates

ACC includes an `update.json` file for update metadata.

Compatible root managers can use this metadata to identify and retrieve published module updates, depending on their implementation and configuration.

When publishing a new version:

1. Update the `version` and `versionCode` fields in `module/module.prop`.
2. Run `./build.sh`.
3. Create a GitHub release with the appropriate version tag.
4. Upload the generated ZIP from `dist/`.
5. Update `update.json` and `changelog.md`.
6. Push the changes to the `main` branch.

Ensure the release tag, download filename, and update metadata remain consistent.

## ⚠️ Disclaimer

ACC is provided "as is", without warranty.

Use it at your own risk. The developer is not responsible for data loss, application issues, or device problems resulting from the use of this module.

---

**Developed by [raafi-abir](https://github.com/raafi-abir)**

If you find ACC useful, consider starring the repository on GitHub!
