# Contributing to ACC

Thank you for your interest in contributing to ACC — Automatic Cache Cleaner.

Repository: https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner

## Project Goals

ACC aims to remain:

- Lightweight.
- Safe.
- Reliable.
- Transparent.
- Easy to configure.

The project focuses on Android cache and selected temporary-file cleanup.

Safety and reliability are more important than adding aggressive cleaning features.

## Development

Clone the repository:

\`\`\`bash
git clone https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner.git
cd ACC-Automatic-Cache-Cleaner
\`\`\`

Build the module:

\`\`\`bash
./build.sh
\`\`\`

The generated ZIP is placed inside:

\`\`\`
dist/
\`\`\`

## Development Guidelines

- Use Android-compatible shell commands.
- Keep scripts lightweight.
- Avoid unnecessary background processes.
- Quote shell variables where practical.
- Validate command output before destructive operations.
- Handle missing commands and permission errors safely.
- Prefer skipping uncertain files over deleting them.
- Keep documentation synchronized with actual behavior.

## Testing

Before submitting changes, test:

- Manual cleanup.
- Automatic scheduling.
- Application exclusions.
- Each cleaning category independently.
- Empty or missing directories.
- Package Manager command failures.
- Multiple Android users where possible.
- Overlapping cleanup attempts.

Never test destructive operations against important personal data.

## Pull Requests

A contribution should include:

1. Description of the problem.
2. Explanation of the proposed solution.
3. Files modified.
4. Testing performed.
5. Any new configuration options.
6. Documentation updates when necessary.

Keep changes focused and easy to review.

## Release Process

1. Update `version` in `module/module.prop`.
2. Increment `versionCode`.
3. Update `changelog.md`.
4. Run `./build.sh`.
5. Inspect the generated ZIP.
6. Create a GitHub release.
7. Upload the generated ZIP.
8. Update `update.json`.
9. Verify the release download URL.

### OTA Update Important Note

The GitHub release tag in `update.json` must match the actual release tag exactly.

GitHub release tag URLs are case-sensitive.

For example:

\`\`\`json
{
  "version": "v1.2.0",
  "versionCode": 4,
  "zipUrl": "https://github.com/raafi-abir/ACC-Automatic-Cache-Cleaner/releases/download/v1.2.0/ACC-Automatic-Cache-Cleaner-v1.2.0.zip",
  "changelog": "https://raw.githubusercontent.com/raafi-abir/ACC-Automatic-Cache-Cleaner/main/changelog.md"
}
\`\`\`

The example above is for a hypothetical release. Do not publish it until that release and asset actually exist.

## Documentation

When changing functionality, update the relevant documentation:

- `README.md`
- `docs/CONFIGURATION.md`
- `docs/SAFETY.md`
- `docs/BEHAVIOR.md`
- `changelog.md`

Thank you for helping improve ACC.
