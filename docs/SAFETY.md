# Safety and Data Handling

ACC is a root-level Android cleaning module. It can permanently delete files from protected directories.

Understanding what the module removes is important before enabling automatic cleaning.

## Important Recommendation

For a conservative setup, disable leftover-folder cleaning:

\`\`\`bash
CLEAN_CORPSES=0
\`\`\`

The current implementation uses a basic package-list count threshold. This does not guarantee that Android returned a complete list of installed applications.

## 1. Application Cache

ACC can clean contents of supported directories:

- `/data/user/*/*/cache`
- `/data/user/*/*/code_cache`
- `/data/user_de/*/*/cache`
- `/data/user_de/*/*/code_cache`
- `/data/media/*/Android/data/*/cache`

The cache directory itself is retained.

Cache files are generally temporary, but some applications may use them to store offline resources or downloaded content.

After cleaning, applications may:

- Rebuild temporary files.
- Download cached resources again.
- Take longer to launch initially.
- Use additional data while rebuilding cache.

## 2. Leftover Folder Detection

ACC can inspect selected folders under:

- `Android/data`
- `Android/obb`

It compares folder names with package names returned by Android's Package Manager.

Folders not found in the collected package list may be considered leftovers.

### Known Limitations

The current implementation has important limitations:

- It checks whether the package list contains at least 20 entries.
- This threshold cannot guarantee that the list is complete.
- Package Manager errors or partial results can affect detection.
- Multiple Android users and work profiles may complicate package detection.
- A legitimate folder could potentially be mistaken for an abandoned folder.

**This feature should be treated as potentially destructive.**

Keep it disabled if you do not fully understand these limitations.

## 3. Selected Junk Cleaning

When enabled, ACC clears contents of selected directories:

- `/data/tombstones`
- `/data/anr`
- `/data/system/dropbox`
- Thumbnail directories
- `LOST.DIR`

It also attempts to clear Android logcat buffers.

These directories may contain useful diagnostic information.

Deleting their contents can make troubleshooting application crashes or system problems more difficult.

## 4. Application Exclusions

The exclusion list helps protect specific package names during cache and leftover-folder cleanup.

However, exclusions do not protect files inside the general junk directories.

## 5. Important Precautions

Before using ACC:

1. Back up important files.
2. Review your configuration.
3. Consider disabling leftover-folder cleanup.
4. Understand which diagnostic files are removed.
5. Check manual cleanup output before relying on the automatic schedule.

## 6. What ACC Does Not Do

ACC is not designed to:

- Kill background applications.
- Clear RAM aggressively.
- Force-stop applications.
- Improve battery life through process killing.
- Guarantee a specific amount of recovered storage.
- Restore deleted files.

ACC focuses on cache and selected temporary-file cleanup.

## 7. Disclaimer

Use ACC at your own risk.

The developer is not responsible for data loss, application malfunction, or device problems resulting from the use of this module.
