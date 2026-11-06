## v1.2
- Added a WebUI settings page (KernelSU, KernelSU Next, APatch, MMRL): live cache size, Clean now and Rescan buttons, toggles for each cleaner, schedule, scan interval and an app exclude list
- Added a cleaning frequency selector: daily, weekly (pick the weekday), monthly (pick the day, 1-28) or custom (every N days). The WebUI shows when the next cleanup is due
- A cleanup missed while the phone was off or asleep still runs when it wakes, for every frequency. A manual cleanup counts as the latest cleanup
- The app on screen is skipped when clearing cache and when counting the live cache size
- Fixed: tapping Action at the same moment as the scheduled run could cause that run to be skipped. It now retries automatically
- Fixed: a cleanup killed mid-run could leave a stale lock that blocked every later cleanup until reboot
- Fixed: `config.sh` is now read as plain `KEY=VALUE` lines (nothing in it is executed). Windows line endings, trailing comments and invalid values are handled safely
- Lower background activity: settings are re-read only when a file changes
- Updated the README and the Configuration, Behavior and Safety guides

## v1.1.2
- Changed cache scan interval to 60 min to save battery and minimise background processes

## v1.1.1
- Module card now shows just `Cache: <size>`
- Cleaner output no longer repeats the title/author lines

## v1.1.0
- Live cache size shown in the module description
- Module renamed to ACC - Automatic Cache Cleaner, author raafi-abir
- OTA updates through the Magisk / KernelSU manager

## v1.0.0
- Daily 12:00 AM cleanup of app cache, leftover folders and junk
- Action button for manual runs
