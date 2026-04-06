<p align="center">
  <img src="Assets/icon.png" width="128" height="128" alt="Lyrisland Icon">
</p>

<h1 align="center">Lyrisland</h1>

<p align="center">
  <em>/ˈlɪrɪslænd/</em> — Lyrics + Island
</p>

<p align="center">
  Real-time lyrics for Spotify and Apple Music in a Dynamic Island style overlay for macOS
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0%2B-blue" alt="macOS 14.0+">
  <img src="https://img.shields.io/badge/Spotify-Desktop-1DB954?logo=spotify&logoColor=white" alt="Spotify">
  <img src="https://img.shields.io/badge/Apple%20Music-supported-fa243c?logo=applemusic&logoColor=white" alt="Apple Music">
</p>

<p align="center">
  <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-TW.md">繁體中文</a> | <strong>English</strong> | <a href="README.ja.md">日本語</a> | <a href="README.ko.md">한국어</a>
</p>

---

## What is Lyrisland?

Lyrisland displays synced lyrics at the top of your screen in a Dynamic Island style overlay. It automatically detects playback from supported local players, keeps lyrics aligned with progress, and stays lightweight in the macOS menu bar.

## Features

- **Spotify + Apple Music** — Detects playback from the local Spotify desktop app and the built-in Music app
- **Dynamic Island Modes** — Compact, Expanded, and Full layouts with animated transitions and optional playback controls
- **Real-time Sync** — Highlights lyrics line by line in sync with playback progress
- **Album Artwork** — Shows artwork across all island sizes, with cached artwork for smooth transitions
- **Dual-line Lyrics** — Displays the current and upcoming lyric lines together for karaoke-style reading
- **Multiple Lyrics Sources** — Searches across multiple providers with reorderable priority and per-provider enable/disable controls
- **Flexible Positioning** — Attach to the menu bar or detach and drag freely, with the window position restored on launch
- **Background Styles** — Solid, album gradient, frosted glass, and dynamic gradient backgrounds
- **Customizable Shortcuts** — Rebind, disable, reset, and validate keyboard shortcuts in Settings
- **RTL Support** — Adapts alignment and marquee behavior for right-to-left lyrics
- **Multilingual UI** — English, 简体中文, 繁體中文, 日本語, 한국어
- **Menu Bar Utility** — Runs without a Dock icon and focuses on minimal desktop footprint

## Installation

### Homebrew

```bash
brew tap EurFelux/lyrisland
brew install --cask lyrisland

# Update to the latest version
brew upgrade lyrisland
```

### Manual Download

Download the latest `.dmg` from [GitHub Releases](https://github.com/EurFelux/Lyrisland/releases), open it, and drag Lyrisland to Applications.

## Preview

#### Compact
![Compact](Assets/screenshots/attached.png)

#### Expanded
![Expanded](Assets/screenshots/expanded.png)

#### Full
![Full](Assets/screenshots/full.png)

### Background Styles

#### Solid
![Solid](Assets/screenshots/bg-solid.png)

#### Album Gradient
![Gradient](Assets/screenshots/bg-album-gradient.png)

#### Frosted Glass
![Glass](Assets/screenshots/bg-glass.png)

#### Dynamic Gradient
![Dynamic](Assets/screenshots/bg-dynamic-gradient.png)

### Position Modes

#### Attached to Menu Bar
![Attached](Assets/screenshots/attached.png)

#### Free Floating
![Detached](Assets/screenshots/detached-compact.png)

## Getting Started

1. Install either [Spotify Desktop](https://www.spotify.com/download/) or the built-in Apple Music app.
2. Open Lyrisland.
3. On first launch, allow the macOS Automation permission prompt so Lyrisland can read playback state.
4. Start playback in Spotify or Apple Music and lyrics will appear automatically.

## Requirements

- macOS 14.0 (Sonoma) or later
- Spotify Desktop and/or Apple Music

## Development

```bash
xcodegen generate
xcodebuild -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS' build
xcodebuild test -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS'
```

For local `.dmg` and `.zip` packaging, see [docs/release-packaging.md](docs/release-packaging.md).

## FAQ

**Q: Do I need to sign in to a streaming account?**
No. Lyrisland reads playback information from supported local apps through Automation permissions.

**Q: Why are there no lyrics for some songs?**
Lyrics come from third-party public databases. Some tracks, regional releases, or instrumentals may not be available.

**Q: What if the lyrics are out of sync?**
Use the offset adjustment from the menu bar icon with `[` and `]` to move timing by `±0.5s`.

**Q: Which players are supported?**
Spotify Desktop and Apple Music on macOS.

## Credits

- [Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper) — Musixmatch and Netease API reference

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
