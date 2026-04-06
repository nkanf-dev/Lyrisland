<p align="center">
  <img src="Assets/icon.png" width="128" height="128" alt="Lyrisland Icon">
</p>

<h1 align="center">Lyrisland</h1>

<p align="center">
  <em>/ˈlɪrɪslænd/</em> — Lyrics + Island
</p>

<p align="center">
  macOS 向けダイナミックアイランド風 Spotify / Apple Music リアルタイム歌詞表示
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0%2B-blue" alt="macOS 14.0+">
  <img src="https://img.shields.io/badge/Spotify-Desktop-1DB954?logo=spotify&logoColor=white" alt="Spotify">
  <img src="https://img.shields.io/badge/Apple%20Music-supported-fa243c?logo=applemusic&logoColor=white" alt="Apple Music">
</p>

<p align="center">
  <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-TW.md">繁體中文</a> | <a href="README.md">English</a> | <strong>日本語</strong> | <a href="README.ko.md">한국어</a>
</p>

---

## Lyrisland とは？

Lyrisland は、画面上部にダイナミックアイランド（Dynamic Island）スタイルで同期歌詞を表示する macOS メニューバーアプリです。対応プレイヤーの再生状態を自動検出し、歌詞を進行状況に合わせて表示します。

## 機能

- **Spotify + Apple Music 対応** — ローカルの Spotify デスクトップアプリと macOS 標準の Music アプリの再生を検出
- **ダイナミックアイランド表示** — Compact、Expanded、Full の 3 レイアウトとスムーズなアニメーション遷移
- **リアルタイム同期** — 再生進行に合わせて歌詞を 1 行ずつハイライト
- **アルバムアートワーク** — すべての表示サイズでジャケットを表示し、キャッシュで切り替えも滑らか
- **2 行歌詞表示** — 現在行と次の行を同時に表示するカラオケ風レイアウト
- **複数の歌詞ソース** — 複数プロバイダを検索し、優先順位の並び替えや個別の有効化/無効化が可能
- **柔軟な配置** — メニューバーに吸着、または自由配置。位置は次回起動時に復元
- **背景スタイル** — ソリッド、アルバムグラデーション、すりガラス、ダイナミックグラデーション
- **ショートカット設定** — 再バインド、無効化、リセット、競合チェックに対応
- **RTL サポート** — 右から左に読む歌詞に合わせて配置やマーキー動作を調整
- **多言語 UI** — English、简体中文、繁體中文、日本語、한국어
- **メニューバー常駐** — Dock アイコンなしで軽量動作

## インストール

### Homebrew

```bash
brew tap EurFelux/lyrisland
brew install --cask lyrisland

# 最新版へ更新
brew upgrade lyrisland
```

### 手動ダウンロード

[GitHub Releases](https://github.com/EurFelux/Lyrisland/releases) から最新の `.dmg` をダウンロードし、Lyrisland をアプリケーションフォルダへドラッグしてください。

## プレビュー

#### Compact
![Compact](Assets/screenshots/attached.png)

#### Expanded
![Expanded](Assets/screenshots/expanded.png)

#### Full
![Full](Assets/screenshots/full.png)

### 背景スタイル

#### ソリッド
![Solid](Assets/screenshots/bg-solid.png)

#### アルバムグラデーション
![Gradient](Assets/screenshots/bg-album-gradient.png)

#### すりガラス
![Glass](Assets/screenshots/bg-glass.png)

#### ダイナミックグラデーション
![Dynamic](Assets/screenshots/bg-dynamic-gradient.png)

### 配置モード

#### メニューバー吸着
![Attached](Assets/screenshots/attached.png)

#### フリーフロート
![Detached](Assets/screenshots/detached-compact.png)

## はじめに

1. [Spotify デスクトップアプリ](https://www.spotify.com/download/) をインストールするか、macOS 標準の Apple Music を使用します。
2. Lyrisland を起動します。
3. 初回起動時に表示される macOS のオートメーション権限を許可します。
4. Spotify または Apple Music で再生を始めると、歌詞が自動で表示されます。

## 動作要件

- macOS 14.0（Sonoma）以降
- Spotify Desktop および/または Apple Music

## 開発

```bash
xcodegen generate
xcodebuild -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS' build
xcodebuild test -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS'
```

ローカルでの `.dmg` / `.zip` 生成手順は [docs/release-packaging.md](docs/release-packaging.md) を参照してください。

## FAQ

**Q: ストリーミングアカウントへのログインは必要ですか？**
不要です。Lyrisland はオートメーション権限を使って、対応するローカルアプリから再生情報を取得します。

**Q: 一部の曲で歌詞が表示されないのはなぜですか？**
歌詞はサードパーティの公開データベースから取得しています。曲によっては未登録の場合があります。

**Q: 歌詞がずれている場合は？**
メニューバーアイコンから `[` と `]` を使って `±0.5s` ずつオフセット調整できます。

**Q: どのプレイヤーに対応していますか？**
macOS 上の Spotify Desktop と Apple Music に対応しています。

## Credits

- [Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper) — Musixmatch / Netease 関連 API 参照

## License

このプロジェクトは [GNU General Public License v3.0](LICENSE) のもとで公開されています。
