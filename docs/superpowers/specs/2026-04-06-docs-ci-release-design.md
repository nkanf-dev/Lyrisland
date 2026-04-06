# Docs, CI, and Release Packaging Design

## Goal

Bring repository documentation and automation in line with the current product state, then package the existing uncommitted code, docs updates, and workflow fixes into a clean commit that can be pushed to `origin/main`.

## Scope

This work covers:

- Updating all shipped README variants so they accurately describe the current app behavior and supported players
- Auditing and correcting the existing GitHub Actions workflows instead of introducing a second CI system
- Adding explicit release packaging documentation for local `.dmg` and `.zip` generation
- Verifying the project still builds and tests after the documentation and workflow changes
- Committing the current working tree changes and pushing them if remote auth allows it

This work does not cover:

- Adding notarization or code signing infrastructure that requires new Apple credentials or repository secrets
- Refactoring the playback feature implementation beyond what is necessary to keep docs and CI accurate
- Rewriting product marketing copy beyond factual alignment with the current app

## Current State

The repository already contains:

- Five README variants: English, Simplified Chinese, Traditional Chinese, Japanese, and Korean
- A `ci.yml` workflow that builds, formats, lints, and tests on macOS
- A `release.yml` workflow that builds release artifacts, creates a DMG and ZIP, publishes a GitHub Release, and updates the Homebrew tap

The main mismatch is factual drift:

- The codebase now includes Apple Music playback support and related tests
- The README variants still describe the app as Spotify-only
- Release packaging exists in workflow form, but there is no concise developer-facing document explaining the local packaging path and the assumptions behind the workflow

## Design

### Documentation updates

All README variants will be updated with the same factual structure:

- Product summary updated from Spotify-only to Spotify + Apple Music support
- Feature list aligned with current playback, lyrics, artwork, controls, and settings behavior
- Getting started and requirements text updated to reflect either supported player
- FAQ updated to remove stale “Spotify only” messaging
- Developer-facing sections added or tightened where useful: local build/test command(s), release pointer, and automation permission expectations

Translation quality will be kept concise and functional. The goal is parity of meaning, not copywriting polish.

### Release packaging documentation

A dedicated release document will be added under `docs/` describing:

- Tool prerequisites such as `xcodegen` and `create-dmg`
- Project generation and Release build commands
- Where the built `.app` is located
- How the repository’s DMG background script is used
- How to create both `.dmg` and `.zip` artifacts locally
- The boundary between local unsigned packaging and credential-backed distribution steps

This document is the canonical answer to “how do I package a DMG locally?”

### CI and release workflow updates

The existing workflows will be corrected rather than replaced.

For `ci.yml`:

- Confirm the project generation step matches the repo’s XcodeGen setup
- Ensure build and test invocations use the right project and scheme targets for the current workspace layout
- Preserve formatting and lint checks, but fix ordering or invocation details if they are currently brittle
- Keep the workflow runnable without signing credentials

For `release.yml`:

- Confirm the Release build path matches the actual generated product path
- Keep DMG + ZIP packaging as the release outputs
- Preserve Homebrew tap update behavior
- Avoid adding notarization or signing requirements that would block current maintainers

Low-risk ergonomics such as artifact upload or clearer step names are acceptable if they improve observability without changing release policy.

## Files Expected To Change

- `README.md`
- `README.zh-CN.md`
- `README.zh-TW.md`
- `README.ja.md`
- `README.ko.md`
- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `docs/` release packaging document

In addition, the already modified product/source files in the working tree will be included in the final commit after verification, but they are not the subject of this design document.

## Validation

Before claiming success:

- Build the project with the Xcode toolchain
- Run the relevant test suite
- Inspect workflow YAML for syntax and command correctness
- Review each README for stale Spotify-only language
- Confirm the release doc commands match repository scripts and paths
- Check `git status` before commit to ensure all intended changes are included

## Risks and Mitigations

### Risk: documentation overstates support

Mitigation:

- Phrase support claims around playback detection and current shipped behavior only
- Cross-check wording against `PlayerKind`, onboarding/settings UI, and existing tests

### Risk: CI changes become speculative

Mitigation:

- Limit workflow edits to mismatches that can be defended from repository structure and local verification
- Do not add secret-dependent steps to normal CI

### Risk: push may fail due to auth or branch protection

Mitigation:

- Complete all local changes and create the commit regardless
- Attempt push once
- If blocked, report the exact blocker and leave the branch in a clean committed state

## Testing Strategy

- Use fast diagnostics where possible during editing
- Run a full project build before completion
- Run tests relevant to the playback changes and any impacted shared suites
- Treat workflow changes as configuration changes that must be inspected and, where feasible, mirrored by local commands
