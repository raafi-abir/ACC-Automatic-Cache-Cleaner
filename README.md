# ACC - Automatic Cache Cleaner
KernelSU / Magisk module by [raafi-abir](https://github.com/raafi-abir).

- Cleans app cache, leftover (corpse) folders and junk daily at 12:00 AM
- Shows the cache that can be cleaned right now in the module card
- Action button runs the cleanup on demand
- OTA updates via `update.json`

Config: `/data/adb/cache_cleaner/config.sh` - Exclude list: `/data/adb/cache_cleaner/exclude.txt`

## Releasing an update
1. Bump `version` / `versionCode` in `module/module.prop`
2. Run `./build.sh`
3. Create a GitHub release tagged with the version and upload the zip from `dist/`
4. Update `update.json` and `changelog.md`, then push to `main`
