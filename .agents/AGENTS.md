# GitHub Release Rule

Whenever a change is committed and pushed to the GitHub repository for this workspace, you MUST automatically create a new GitHub release using the `gh release create` command.

**Process:**
1. Determine the next logical version number (e.g., bump from `v1.0.0` to `v1.0.1` for bug fixes, or `v1.1.0` for features).
2. Use the command: `gh release create v<VERSION> --title "<TITLE>" --notes "<CHANGELOG>"`
3. Do this proactively without waiting for the user to explicitly ask, so that the latest source code is always easily downloadable by end users.
