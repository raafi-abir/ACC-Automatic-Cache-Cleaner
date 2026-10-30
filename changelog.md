## v1.1.3
- Added a WebUI settings page (KernelSU, KernelSU Next, APatch, MMRL): live cache size, Clean now and Rescan buttons, toggles for each cleaner, daily run time, scan interval, and an exclude list for apps
- Fixed: tapping Action at the same moment as the scheduled run could cause that day's cleanup to be skipped. It now retries automatically.
- The app currently on screen is skipped when clearing cache, so it can't crash mid-use.
- Default cache scan interval is now 60 min

## v1.1.2
- Changed cache scan interval to 60 min to save battery and minimise background processes

## v1.1.1
- Module card now shows just "Cache: <size>"
- Cleaner output no longer repeats the title/author lines

## v1.1.0
- Live cache size shown in the module description
- Module renamed to ACC - Automatic Cache Cleaner, author raafi-abir
- OTA updates through the Magisk / KernelSU manager

## v1.0.0
- Daily 12:00 AM cleanup of app cache, leftover folders and junk
- Action button for manual runs
