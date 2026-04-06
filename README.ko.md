<p align="center">
  <img src="Assets/icon.png" width="128" height="128" alt="Lyrisland Icon">
</p>

<h1 align="center">Lyrisland</h1>

<p align="center">
  <em>/ˈlɪrɪslænd/</em> — Lyrics + Island
</p>

<p align="center">
  macOS용 다이내믹 아일랜드 스타일 Spotify / Apple Music 실시간 가사 표시
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0%2B-blue" alt="macOS 14.0+">
  <img src="https://img.shields.io/badge/Spotify-Desktop-1DB954?logo=spotify&logoColor=white" alt="Spotify">
  <img src="https://img.shields.io/badge/Apple%20Music-supported-fa243c?logo=applemusic&logoColor=white" alt="Apple Music">
</p>

<p align="center">
  <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-TW.md">繁體中文</a> | <a href="README.md">English</a> | <a href="README.ja.md">日本語</a> | <strong>한국어</strong>
</p>

---

## Lyrisland 소개

Lyrisland는 화면 상단에 다이내믹 아일랜드(Dynamic Island) 스타일로 동기화된 가사를 표시하는 macOS 메뉴 막대 앱입니다. 지원되는 로컬 플레이어의 재생 상태를 자동 감지하고, 재생 진행에 맞춰 가사를 표시합니다.

## 기능

- **Spotify + Apple Music 지원** — 로컬 Spotify 데스크톱 앱과 macOS 기본 Music 앱의 재생 상태 감지
- **다이내믹 아일랜드 모드** — Compact, Expanded, Full 세 가지 레이아웃과 부드러운 애니메이션 전환
- **실시간 동기화** — 재생 진행에 따라 가사를 한 줄씩 하이라이트
- **앨범 아트워크** — 모든 레이아웃에서 앨범 커버를 표시하고 캐시로 전환을 부드럽게 유지
- **2줄 가사 표시** — 현재 줄과 다음 줄을 함께 보여주는 노래방 스타일 레이아웃
- **다중 가사 소스** — 여러 제공자를 검색하고 우선순위 재정렬 및 개별 활성화/비활성화 가능
- **유연한 위치 지정** — 메뉴 막대에 붙이거나 자유롭게 드래그할 수 있고, 위치는 다음 실행 시 복원
- **배경 스타일** — 단색, 앨범 그라디언트, 프로스트 글래스, 다이내믹 그라디언트
- **단축키 설정** — 재바인딩, 비활성화, 초기화, 충돌 확인 지원
- **RTL 지원** — 오른쪽에서 왼쪽으로 읽는 가사에 맞춰 정렬과 마키 동작 조정
- **다국어 UI** — English、简体中文、繁體中文、日本語、한국어
- **메뉴 막대 상주** — Dock 아이콘 없이 가볍게 동작

## 설치

### Homebrew

```bash
brew tap EurFelux/lyrisland
brew install --cask lyrisland

# 최신 버전으로 업데이트
brew upgrade lyrisland
```

### 수동 다운로드

[GitHub Releases](https://github.com/EurFelux/Lyrisland/releases)에서 최신 `.dmg`를 다운로드한 뒤, Lyrisland를 응용 프로그램 폴더로 드래그하세요.

## 미리보기

#### Compact
![Compact](Assets/screenshots/attached.png)

#### Expanded
![Expanded](Assets/screenshots/expanded.png)

#### Full
![Full](Assets/screenshots/full.png)

### 배경 스타일

#### 단색
![Solid](Assets/screenshots/bg-solid.png)

#### 앨범 그라디언트
![Gradient](Assets/screenshots/bg-album-gradient.png)

#### 프로스트 글래스
![Glass](Assets/screenshots/bg-glass.png)

#### 다이내믹 그라디언트
![Dynamic](Assets/screenshots/bg-dynamic-gradient.png)

### 위치 모드

#### 메뉴 막대 고정
![Attached](Assets/screenshots/attached.png)

#### 자유 배치
![Detached](Assets/screenshots/detached-compact.png)

## 시작하기

1. [Spotify 데스크톱 앱](https://www.spotify.com/download/)을 설치하거나 macOS 기본 Apple Music 앱을 사용합니다.
2. Lyrisland를 실행합니다.
3. 처음 실행할 때 표시되는 macOS 자동화 권한 요청을 허용합니다.
4. Spotify 또는 Apple Music에서 재생을 시작하면 가사가 자동으로 표시됩니다.

## 요구 사항

- macOS 14.0(Sonoma) 이상
- Spotify Desktop 및/또는 Apple Music

## 개발

```bash
xcodegen generate
xcodebuild -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS' build
xcodebuild test -project Lyrisland.xcodeproj -scheme Lyrisland -destination 'platform=macOS'
```

로컬 `.dmg` 및 `.zip` 패키징은 [docs/release-packaging.md](docs/release-packaging.md)를 참고하세요.

## FAQ

**Q: 스트리밍 계정 로그인이 필요한가요?**
아니요. Lyrisland는 자동화 권한을 사용해 지원되는 로컬 앱에서 재생 정보를 읽습니다.

**Q: 일부 곡에서 가사가 표시되지 않는 이유는 무엇인가요?**
가사는 서드파티 공개 데이터베이스에서 가져오며, 일부 곡은 아직 등록되지 않았을 수 있습니다.

**Q: 가사가 어긋나면 어떻게 하나요?**
메뉴 막대 아이콘에서 `[` 와 `]` 키를 사용해 `±0.5s` 단위로 오프셋을 조정할 수 있습니다.

**Q: 어떤 플레이어를 지원하나요?**
macOS의 Spotify Desktop과 Apple Music을 지원합니다.

## Credits

- [Lyricify Lyrics Helper](https://github.com/WXRIW/Lyricify-Lyrics-Helper) — Musixmatch / Netease 관련 API 참고

## License

이 프로젝트는 [GNU General Public License v3.0](LICENSE) 라이선스로 배포됩니다.
