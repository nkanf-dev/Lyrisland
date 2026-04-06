# Docs, CI, and Release Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align repository docs and GitHub Actions workflows with the current Lyrisland feature set, add local packaging documentation, then verify, commit, and push the resulting work.

**Architecture:** Keep the existing repository structure and release flow. Update the five README variants for factual parity, tighten the current `ci.yml` and `release.yml` instead of replacing them, and add one focused packaging guide under `docs/`. Validation uses the existing XcodeGen + Xcode build path so the documented commands and workflow commands stay consistent.

**Tech Stack:** Swift/macOS app project, XcodeGen, GitHub Actions, shell tooling, Markdown documentation

---

### Task 1: Baseline the current repository state

**Files:**
- Inspect: `README.md`
- Inspect: `README.zh-CN.md`
- Inspect: `README.zh-TW.md`
- Inspect: `README.ja.md`
- Inspect: `README.ko.md`
- Inspect: `.github/workflows/ci.yml`
- Inspect: `.github/workflows/release.yml`
- Inspect: `project.yml`
- Inspect: `Lyrisland/Sources/Playback/PlayerKind.swift`
- Inspect: `Lyrisland/Sources/Views/OnboardingView.swift`
- Inspect: `Lyrisland/Sources/Views/HelpView.swift`

- [ ] **Step 1: Review the current player support surface**

```bash
sed -n '1,200p' Lyrisland/Sources/Playback/PlayerKind.swift
sed -n '1,260p' Lyrisland/Sources/Views/OnboardingView.swift
sed -n '1,220p' Lyrisland/Sources/Views/HelpView.swift
```

Expected: repository code explicitly references both Spotify and Apple Music.

- [ ] **Step 2: Review current docs and workflow baselines**

```bash
sed -n '1,260p' README.md
sed -n '1,260p' README.zh-CN.md
sed -n '1,260p' README.zh-TW.md
sed -n '1,260p' README.ja.md
sed -n '1,260p' README.ko.md
sed -n '1,240p' .github/workflows/ci.yml
sed -n '1,320p' .github/workflows/release.yml
sed -n '1,220p' project.yml
```

Expected: README files still contain stale Spotify-only messaging, while workflows already exist and need correction rather than replacement.

- [ ] **Step 3: Confirm the working tree before edits**

```bash
git status --short --branch
```

Expected: existing source/test modifications are present and must be preserved during the doc/CI work.

### Task 2: Update all README variants for current product behavior

**Files:**
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `README.zh-TW.md`
- Modify: `README.ja.md`
- Modify: `README.ko.md`

- [ ] **Step 1: Edit the English README structure and copy**

```markdown
- Update the centered product summary from Spotify-only to Spotify + Apple Music
- Update badges or requirement text if it implies a single player
- Update Features, Installation, Getting Started, Requirements, FAQ, and a short Development section
- Keep release download and Homebrew guidance intact
```

Expected: `README.md` becomes the canonical current-state reference.

- [ ] **Step 2: Mirror the same factual changes into Simplified Chinese**

```markdown
- Translate the updated summary, features, getting started, requirements, FAQ, and development/release notes
- Keep terminology stable across the file: Apple Music, Spotify, 自动化权限, 本地构建/测试, DMG
```

Expected: `README.zh-CN.md` matches the English meaning without stale Spotify-only text.

- [ ] **Step 3: Mirror the same factual changes into Traditional Chinese**

```markdown
- Translate the same sections with consistent wording for Apple Music support, permissions, local build/test, and release packaging
```

Expected: `README.zh-TW.md` is meaningfully aligned with the English README.

- [ ] **Step 4: Mirror the same factual changes into Japanese**

```markdown
- Translate the same sections with concise technical wording and no unsupported claims
```

Expected: `README.ja.md` is factually aligned with the English README.

- [ ] **Step 5: Mirror the same factual changes into Korean**

```markdown
- Translate the same sections with concise technical wording and no unsupported claims
```

Expected: `README.ko.md` is factually aligned with the English README.

- [ ] **Step 6: Check for stale Spotify-only phrasing**

```bash
grep -RIn "Currently only Spotify is supported\|目前仅支持 Spotify\|Spotifyのみ\|Spotify만" README*
```

Expected: no matches for the old unsupported phrasing.

### Task 3: Add explicit local packaging and release docs

**Files:**
- Create: `docs/release-packaging.md`
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `README.zh-TW.md`
- Modify: `README.ja.md`
- Modify: `README.ko.md`

- [ ] **Step 1: Write the packaging guide**

```markdown
# Release Packaging

## Prerequisites

- Xcode 16 or later
- Homebrew
- `xcodegen`
- `create-dmg`

```bash
brew install xcodegen create-dmg
```

## Generate the project

```bash
xcodegen generate
```

## Build the Release app

```bash
xcodebuild -project Lyrisland.xcodeproj \
  -scheme Lyrisland \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  build
```

The built app will be at `build/Build/Products/Release/Lyrisland.app`.

## Build the DMG background

```bash
swift Scripts/generate-dmg-background.swift /tmp/dmg-background.png 660 400
```

## Create a DMG

```bash
APP_PATH="build/Build/Products/Release/Lyrisland.app"
create-dmg \
  --volname "Lyrisland" \
  --background /tmp/dmg-background.png \
  --window-pos 200 120 \
  --window-size 660 400 \
  --icon-size 80 \
  --icon "Lyrisland.app" 170 190 \
  --app-drop-link 490 190 \
  --hide-extension "Lyrisland.app" \
  --no-internet-enable \
  "Lyrisland-local.dmg" \
  "$APP_PATH" \
|| test $? -eq 2
```

## Create a ZIP for GitHub Releases or Homebrew

```bash
ditto -c -k --keepParent "build/Build/Products/Release/Lyrisland.app" "Lyrisland-local.zip"
```

## Notes

- These commands produce unsigned, unnotarized artifacts suitable for local verification
- The GitHub Actions release workflow uses the same build and packaging path
```

Expected: `docs/release-packaging.md` becomes the source of truth for local packaging.

- [ ] **Step 2: Link the packaging guide from each README**

```markdown
- Add a short Development or Release section pointing to `docs/release-packaging.md`
- Keep the link wording concise and language-appropriate
```

Expected: every README points maintainers to the local packaging instructions.

### Task 4: Correct and strengthen CI and release workflows

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/release.yml`
- Inspect: `project.yml`

- [ ] **Step 1: Adjust CI commands to match the current project layout**

```yaml
- Keep `actions/checkout@v4`
- Keep Homebrew installation of `xcodegen`, `swiftformat`, and `swiftlint`
- Keep `xcodegen generate`
- Build the app scheme with `xcodebuild -project Lyrisland.xcodeproj -scheme Lyrisland`
- Run tests against the generated project with a valid test action for the current schemes
- Preserve unsigned builds in CI
```

Expected: `ci.yml` matches the generated project and does not rely on speculative scheme names.

- [ ] **Step 2: Add low-risk workflow improvements**

```yaml
- Use clearer step names
- Upload build logs or artifacts only if the change is low-risk and does not require new secrets
- Keep concurrency and triggers intact
```

Expected: workflow readability improves without changing release policy.

- [ ] **Step 3: Correct the release workflow where repository facts require it**

```yaml
- Keep the tag trigger `v*`
- Keep XcodeGen project generation
- Keep Release build into `build/Build/Products/Release/Lyrisland.app`
- Keep DMG + ZIP creation
- Keep GitHub Release publication
- Keep Homebrew tap update flow
- Fix only path, command, or resilience issues justified by local verification
```

Expected: `release.yml` remains compatible with current distribution behavior.

### Task 5: Validate the updated docs and workflows against the project

**Files:**
- Validate: `README.md`
- Validate: `README.zh-CN.md`
- Validate: `README.zh-TW.md`
- Validate: `README.ja.md`
- Validate: `README.ko.md`
- Validate: `docs/release-packaging.md`
- Validate: `.github/workflows/ci.yml`
- Validate: `.github/workflows/release.yml`

- [ ] **Step 1: Build the project**

```bash
xcodegen generate
xcodebuild -project Lyrisland.xcodeproj \
  -scheme Lyrisland \
  -destination 'platform=macOS' \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  build
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 2: Run tests**

```bash
xcodebuild test \
  -project Lyrisland.xcodeproj \
  -scheme Lyrisland \
  -destination 'platform=macOS' \
  CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

Expected: test action completes successfully for the generated project.

- [ ] **Step 3: Lint and format verification**

```bash
swiftformat --lint Sources Tests
swiftlint lint --strict Sources Tests
```

Expected: no formatting or lint failures in tracked source files.

- [ ] **Step 4: Review packaging doc commands against actual repo assets**

```bash
test -f Scripts/generate-dmg-background.swift
test -f .github/workflows/release.yml
```

Expected: both checks succeed, confirming the doc references real repository assets.

- [ ] **Step 5: Review final working tree**

```bash
git status --short
```

Expected: only intended source/test/doc/workflow changes are present.

### Task 6: Commit the completed work and push

**Files:**
- Commit: all intended modified files

- [ ] **Step 1: Create the final commit**

```bash
git add README.md README.zh-CN.md README.zh-TW.md README.ja.md README.ko.md \
  docs/release-packaging.md .github/workflows/ci.yml .github/workflows/release.yml \
  Lyrisland/Sources Lyrisland/Tests
git commit -m "feat: add apple music docs and release workflow updates"
```

Expected: a single commit captures the implementation after validation.

- [ ] **Step 2: Push the branch**

```bash
git push origin main
```

Expected: push succeeds, or returns a clear auth/permission error that can be reported.
