<p align="center">
  <img src="Assets/icon.png" width="128" height="128" alt="Lyrisland Icon">
</p>

<h1 align="center">Lyrisland</h1>

<p align="center">
  <em>/ˈlɪrɪslænd/</em> — Lyrics + Island
</p>

<p align="center">
  macOS 靈動島風格的 Spotify 與 Apple Music 即時歌詞顯示
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0%2B-blue" alt="macOS 14.0+">
  <img src="https://img.shields.io/badge/Spotify-Desktop-1DB954?logo=spotify&logoColor=white" alt="Spotify">
  <img src="https://img.shields.io/badge/Apple%20Music-supported-fa243c?logo=applemusic&logoColor=white" alt="Apple Music">
</p>

<p align="center">
  <a href="README.zh-CN.md">简体中文</a> | <strong>繁體中文</strong> | <a href="README.md">English</a> | <a href="README.ja.md">日本語</a> | <a href="README.ko.md">한국어</a>
</p>

---

## 什麼是 Lyrisland？

Lyrisland 會在螢幕頂部以靈動島（Dynamic Island）樣式顯示同步歌詞。它會自動偵測本機受支援播放器的播放狀態，讓歌詞與進度保持對齊，並以輕量的選單列應用形式常駐桌面。

## 功能

- **支援 Spotify + Apple Music** — 可偵測本機 Spotify 桌面版與系統內建 Music App 的播放狀態
- **靈動島形態** — 緊湊、展開、完整三種版型，具備流暢動畫過渡與可選播放控制
- **即時同步** — 逐行高亮歌詞，與播放進度同步
- **專輯封面** — 在不同島嶼尺寸中顯示封面，並快取封面以獲得更平滑的切換體驗
- **雙行歌詞** — 同時顯示目前行與下一行，方便卡拉 OK 式閱讀
- **多歌詞來源** — 可跨多個歌詞來源搜尋，支援拖曳調整優先順序與個別啟用/停用
- **靈活定位** — 可吸附在選單列，也可自由拖曳，重新啟動後會恢復上次位置
- **背景樣式** — 支援純色、專輯漸層、毛玻璃與動態漸層背景
- **快捷鍵自訂** — 可在設定中重新綁定、停用、重設並檢查快捷鍵衝突
- **RTL 支援** — 針對由右至左語言自動調整對齊方式與跑馬燈行為
- **多語言介面** — English、简体中文、繁體中文、日本語、한국어
- **選單列常駐** — 不顯示 Dock 圖示，盡量降低桌面干擾

## 安裝

### Homebrew

```bash
brew tap EurFelux/lyrisland
brew install --cask lyrisland

# 更新至最新版本
brew upgrade lyrisland
```

### 手動下載

從 [GitHub Releases](https://github.com/EurFelux/Lyrisland/releases) 下載最新的 `.dmg` 檔案，開啟後將 Lyrisland 拖入「應用程式」資料夾。

## 預覽

#### Compact
![Compact](Assets/screenshots/attached.png)

#### Expanded
![Expanded](Assets/screenshots/expanded.png)

#### Full
![Full](Assets/screenshots/full.png)

### 背景樣式

#### 純色
![Solid](Assets/screenshots/bg-solid.png)

#### 專輯漸層
![Gradient](Assets/screenshots/bg-album-gradient.png)

#### 毛玻璃
![Glass](Assets/screenshots/bg-glass.png)

#### 動態漸層
![Dynamic](Assets/screenshots/bg-dynamic-gradient.png)

### 定位模式

#### 吸附選單列
![Attached](Assets/screenshots/attached.png)

#### 自由浮動
![Detached](Assets/screenshots/detached-compact.png)

## 快速開始

1. 安裝 [Spotify 桌面版](https://www.spotify.com/download/) 或直接使用系統內建的 Apple Music。
2. 開啟 Lyrisland。
3. 首次啟動時，允許 macOS 的自動化權限要求，以便讀取播放狀態。
4. 在 Spotify 或 Apple Music 中開始播放，歌詞會自動顯示。

## 系統需求

- macOS 14.0（Sonoma）或更新版本
- Spotify Desktop 和/或 Apple Music

## 開發

```bash
xcodegen generate
xcodebuild -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS' build
xcodebuild test -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS'
```

本機打包 `.dmg` 與 `.zip` 的步驟請參考 [docs/release-packaging.md](docs/release-packaging.md)。

## FAQ

**Q: 需要登入串流帳號嗎？**
不需要。Lyrisland 透過自動化權限從受支援的本機播放器讀取播放資訊。

**Q: 為什麼有些歌曲沒有歌詞？**
歌詞來自第三方公開資料庫，部分歌曲、地區版本或純音樂可能暫時沒有收錄。

**Q: 歌詞不同步怎麼辦？**
可在選單列圖示中使用 `[` 與 `]` 快捷鍵，每次按 `±0.5s` 調整偏移。

**Q: 支援哪些播放器？**
macOS 上的 Spotify Desktop 與 Apple Music。

## Credits

- [Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper) — Musixmatch 與網易雲相關 API 參考

## 授權

本專案依 [GNU General Public License v3.0](LICENSE) 授權。
