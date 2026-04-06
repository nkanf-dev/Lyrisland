# Release Packaging

## Prerequisites

- Xcode 16 or later
- Homebrew
- `xcodegen`
- `create-dmg`

Install the packaging tools:

```bash
brew install xcodegen create-dmg
```

## Generate the Xcode project

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

The built app will be available at `build/Build/Products/Release/Lyrisland.app`.

## Generate the DMG background

```bash
swift Scripts/generate-dmg-background.swift /tmp/dmg-background.png 660 400
```

## Create a local DMG

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

`create-dmg` may exit with code `2` when signing is skipped. The command above treats that case as expected.

## Create a ZIP

```bash
ditto -c -k --keepParent "build/Build/Products/Release/Lyrisland.app" "Lyrisland-local.zip"
```

## Notes

- The commands above produce unsigned, unnotarized artifacts suitable for local verification and GitHub Releases.
- The repository release workflow uses the same XcodeGen, Release build, DMG background, DMG, and ZIP packaging path.
- If you need a production-ready notarized DMG, add Apple signing and notarization credentials separately. The current repository automation does not require them for local packaging.
