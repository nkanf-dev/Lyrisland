<p align="center">
  <img src="Assets/icon.png" width="128" height="128" alt="Lyrisland Icon">
</p>

<h1 align="center">Lyrisland</h1>

<p align="center">
  <em>/ˈlɪrɪslænd/</em> — Lyrics + Island
</p>

<p align="center">
  macOS 灵动岛风格的 Spotify 与 Apple Music 实时歌词显示
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0%2B-blue" alt="macOS 14.0+">
  <img src="https://img.shields.io/badge/Spotify-Desktop-1DB954?logo=spotify&logoColor=white" alt="Spotify">
  <img src="https://img.shields.io/badge/Apple%20Music-supported-fa243c?logo=applemusic&logoColor=white" alt="Apple Music">
</p>

<p align="center">
  <strong>简体中文</strong> | <a href="README.zh-TW.md">繁體中文</a> | <a href="README.md">English</a> | <a href="README.ja.md">日本語</a> | <a href="README.ko.md">한국어</a>
</p>

---

## 什么是 Lyrisland？

Lyrisland 会在屏幕顶部以灵动岛（Dynamic Island）样式显示同步歌词。它会自动检测本地受支持播放器的播放状态，将歌词与进度对齐，并以轻量菜单栏应用的方式常驻桌面。

## 功能

- **支持 Spotify + Apple Music** — 可检测本地 Spotify 桌面客户端与系统自带音乐 App 的播放状态
- **灵动岛形态** — 紧凑、展开、完整三种布局，带有流畅动画过渡和可选播放控制
- **实时同步** — 逐行高亮歌词，与播放进度保持同步
- **专辑封面** — 在不同岛屿尺寸中展示封面，并缓存封面以获得更平滑的切换体验
- **双行歌词** — 同时显示当前行与下一行，适合卡拉 OK 式阅读
- **多歌词源** — 支持多个歌词源搜索，可拖拽调整优先级，并可单独启用或禁用
- **灵活定位** — 可吸附在菜单栏，也可自由拖拽，启动后恢复上次位置
- **背景样式** — 支持纯色、专辑渐变、毛玻璃和动态渐变背景
- **快捷键自定义** — 可在设置中重新绑定、禁用、重置并检测快捷键冲突
- **RTL 支持** — 针对从右到左语言自动调整对齐方式与跑马灯行为
- **多语言界面** — English、简体中文、繁體中文、日本語、한국어
- **菜单栏常驻** — 不显示 Dock 图标，尽量减少桌面打扰

## 安装

### Homebrew

```bash
brew tap EurFelux/lyrisland
brew install --cask lyrisland

# 更新到最新版本
brew upgrade lyrisland
```

### 手动下载

从 [GitHub Releases](https://github.com/EurFelux/Lyrisland/releases) 下载最新的 `.dmg` 文件，打开后将 Lyrisland 拖入“应用程序”文件夹。

## 预览

#### Compact
![Compact](Assets/screenshots/attached.png)

#### Expanded
![Expanded](Assets/screenshots/expanded.png)

#### Full
![Full](Assets/screenshots/full.png)

### 背景样式

#### 纯色
![Solid](Assets/screenshots/bg-solid.png)

#### 专辑渐变
![Gradient](Assets/screenshots/bg-album-gradient.png)

#### 毛玻璃
![Glass](Assets/screenshots/bg-glass.png)

#### 动态渐变
![Dynamic](Assets/screenshots/bg-dynamic-gradient.png)

### 定位模式

#### 吸附菜单栏
![Attached](Assets/screenshots/attached.png)

#### 自由浮动
![Detached](Assets/screenshots/detached-compact.png)

## 快速开始

1. 安装 [Spotify 桌面客户端](https://www.spotify.com/download/) 或直接使用系统自带的 Apple Music。
2. 打开 Lyrisland。
3. 首次启动时，允许 macOS 的自动化权限请求，以便读取播放状态。
4. 在 Spotify 或 Apple Music 中开始播放，歌词会自动出现。

## 系统要求

- macOS 14.0（Sonoma）或更高版本
- Spotify Desktop 和/或 Apple Music

## 开发

```bash
xcodegen generate
xcodebuild -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS' build
xcodebuild test -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS'
```

本地打包 `.dmg` 与 `.zip` 的步骤见 [docs/release-packaging.md](docs/release-packaging.md)。

## FAQ

**Q: 需要登录流媒体账号吗？**
不需要。Lyrisland 通过自动化权限从受支持的本地播放器读取播放信息。

**Q: 为什么有些歌曲没有歌词？**
歌词来自第三方公开数据库，部分歌曲、地区版本或纯音乐可能暂时没有收录。

**Q: 歌词不同步怎么办？**
可在菜单栏图标中使用 `[` 与 `]` 快捷键，每次按 `±0.5s` 调整偏移。

**Q: 支持哪些播放器？**
macOS 上的 Spotify Desktop 与 Apple Music。

## Credits

- [Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper) — Musixmatch 与网易云相关 API 参考

## 许可证

本项目基于 [GNU General Public License v3.0](LICENSE) 开源。
