# Apple Music Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Apple Music support alongside Spotify with automatic detection, shared playback controls, and stable lyrics syncing.

**Architecture:** Introduce a small playback abstraction layer so the app can reason about one active player at a time while still polling both Spotify and Music. Keep lyrics loading player-agnostic by continuing to flow through `TrackInfo`, and centralize arbitration logic in a coordinator that decides which player is active.

**Tech Stack:** Swift, SwiftUI, AppleScript via `NSAppleScript`, Apple Testing framework, Xcode build validation

---

### Task 1: Add playback domain models and arbitration tests

**Files:**
- Create: `Lyrisland/Tests/PlaybackCoordinatorTests.swift`
- Create: `Lyrisland/Sources/Playback/PlayerKind.swift`
- Create: `Lyrisland/Sources/Playback/PlaybackSnapshot.swift`
- Create: `Lyrisland/Sources/Playback/PlaybackCoordinator.swift`

- [ ] **Step 1: Write the failing tests**

```swift
@testable import Lyrisland
import Testing

struct PlaybackCoordinatorTests {
    @Test("playing player wins over paused player")
    func playingPlayerWins() {
        let coordinator = PlaybackCoordinator()
        let spotify = PlaybackSnapshot(
            player: .spotify,
            trackId: "spotify-track",
            title: "Track A",
            artist: "Artist",
            album: "Album",
            durationMs: 180_000,
            position: 12,
            isPlaying: true,
            artworkURL: "https://example.com/a.jpg"
        )
        let music = PlaybackSnapshot(
            player: .appleMusic,
            trackId: "music-track",
            title: "Track B",
            artist: "Artist",
            album: "Album",
            durationMs: 180_000,
            position: 50,
            isPlaying: false,
            artworkURL: nil
        )

        let selected = coordinator.selectActivePlayback(from: [.spotify: spotify, .appleMusic: music])

        #expect(selected?.player == .spotify)
    }

    @Test("most recently changed playing player wins when both are playing")
    func mostRecentPlayingPlayerWins() {
        let coordinator = PlaybackCoordinator()
        let spotify = PlaybackSnapshot(
            player: .spotify,
            trackId: "spotify-track",
            title: "Track A",
            artist: "Artist",
            album: "Album",
            durationMs: 180_000,
            position: 12,
            isPlaying: true,
            artworkURL: nil,
            detectedAt: Date(timeIntervalSince1970: 10)
        )
        let music = PlaybackSnapshot(
            player: .appleMusic,
            trackId: "music-track",
            title: "Track B",
            artist: "Artist",
            album: "Album",
            durationMs: 180_000,
            position: 14,
            isPlaying: true,
            artworkURL: nil,
            detectedAt: Date(timeIntervalSince1970: 20)
        )

        let selected = coordinator.selectActivePlayback(from: [.spotify: spotify, .appleMusic: music])

        #expect(selected?.player == .appleMusic)
    }

    @Test("last active player wins when no player is currently playing")
    func lastActivePlayerWinsWhenPaused() {
        let coordinator = PlaybackCoordinator(lastActivePlayer: .appleMusic)
        let spotify = PlaybackSnapshot(
            player: .spotify,
            trackId: "spotify-track",
            title: "Track A",
            artist: "Artist",
            album: "Album",
            durationMs: 180_000,
            position: 12,
            isPlaying: false,
            artworkURL: nil
        )
        let music = PlaybackSnapshot(
            player: .appleMusic,
            trackId: "music-track",
            title: "Track B",
            artist: "Artist",
            album: "Album",
            durationMs: 180_000,
            position: 14,
            isPlaying: false,
            artworkURL: nil
        )

        let selected = coordinator.selectActivePlayback(from: [.spotify: spotify, .appleMusic: music])

        #expect(selected?.player == .appleMusic)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `PlaybackCoordinatorTests`
Expected: FAIL because `PlaybackCoordinator`, `PlaybackSnapshot`, and `PlayerKind` do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```swift
import Foundation

enum PlayerKind: String, CaseIterable, Codable {
    case spotify
    case appleMusic
}
```

```swift
import Foundation

struct PlaybackSnapshot: Equatable {
    let player: PlayerKind
    let trackId: String
    let title: String
    let artist: String
    let album: String
    let durationMs: Int
    let position: TimeInterval
    let isPlaying: Bool
    let artworkURL: String?
    let detectedAt: Date

    init(
        player: PlayerKind,
        trackId: String,
        title: String,
        artist: String,
        album: String,
        durationMs: Int,
        position: TimeInterval,
        isPlaying: Bool,
        artworkURL: String?,
        detectedAt: Date = Date()
    ) {
        self.player = player
        self.trackId = trackId
        self.title = title
        self.artist = artist
        self.album = album
        self.durationMs = durationMs
        self.position = position
        self.isPlaying = isPlaying
        self.artworkURL = artworkURL
        self.detectedAt = detectedAt
    }
}
```

```swift
import Foundation

struct PlaybackCoordinator {
    var lastActivePlayer: PlayerKind?

    func selectActivePlayback(from snapshots: [PlayerKind: PlaybackSnapshot]) -> PlaybackSnapshot? {
        let playing = snapshots.values.filter(\.isPlaying)
        if let selectedPlaying = playing.max(by: { $0.detectedAt < $1.detectedAt }) {
            return selectedPlaying
        }

        if let lastActivePlayer, let snapshot = snapshots[lastActivePlayer] {
            return snapshot
        }

        return PlayerKind.allCases.compactMap { snapshots[$0] }.first
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `PlaybackCoordinatorTests`
Expected: PASS with 3 tests passing.

- [ ] **Step 5: Commit**

```bash
git add Lyrisland/Tests/PlaybackCoordinatorTests.swift Lyrisland/Sources/Playback/PlayerKind.swift Lyrisland/Sources/Playback/PlaybackSnapshot.swift Lyrisland/Sources/Playback/PlaybackCoordinator.swift
git commit -m "test: add playback coordination model"
```

### Task 2: Abstract playback control and adapt Spotify

**Files:**
- Create: `Lyrisland/Sources/Playback/PlaybackControlling.swift`
- Modify: `Lyrisland/Sources/Spotify/SpotifyAppleScriptService.swift`
- Modify: `Lyrisland/Sources/Spotify/PlaybackSyncEngine.swift`

- [ ] **Step 1: Write the failing test**

Add a test asserting `PlaybackSyncEngine` can map a generic snapshot into its published state without depending on Spotify-specific types.

- [ ] **Step 2: Run test to verify it fails**

Run: `PlaybackCoordinatorTests`, `PlaybackSyncEngine`-focused test
Expected: FAIL because sync engine only accepts Spotify-specific control/service references.

- [ ] **Step 3: Write minimal implementation**

Introduce:

```swift
protocol PlaybackControlling: AnyObject {
    var player: PlayerKind { get }
    func fetchPlaybackState() async -> PlaybackSnapshot?
    func playPause() async
    func nextTrack() async
    func previousTrack() async
}
```

Update Spotify service to conform by returning `PlaybackSnapshot(player: .spotify, ...)`.

Update sync engine to store:

```swift
var playbackController: PlaybackControlling?
func apply(snapshot: PlaybackSnapshot?)
```

Keep its interpolation logic unchanged.

- [ ] **Step 4: Run test to verify it passes**

Run the new sync engine test plus `PlaybackCoordinatorTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Lyrisland/Sources/Playback/PlaybackControlling.swift Lyrisland/Sources/Spotify/SpotifyAppleScriptService.swift Lyrisland/Sources/Spotify/PlaybackSyncEngine.swift Lyrisland/Tests/PlaybackCoordinatorTests.swift
git commit -m "refactor: abstract playback control from spotify"
```

### Task 3: Add Apple Music AppleScript service

**Files:**
- Create: `Lyrisland/Sources/Playback/AppleMusicAppleScriptService.swift`
- Create: `Lyrisland/Tests/AppleMusicPlaybackMappingTests.swift`

- [ ] **Step 1: Write the failing test**

Write tests for parsing/mapping Apple Music script output into `PlaybackSnapshot`, including:
- running and playing track
- app not running
- paused state

- [ ] **Step 2: Run test to verify it fails**

Run: `AppleMusicPlaybackMappingTests`
Expected: FAIL because `AppleMusicAppleScriptService` does not exist.

- [ ] **Step 3: Write minimal implementation**

Create a Music.app AppleScript service mirroring Spotify behavior:

```swift
final class AppleMusicAppleScriptService: PlaybackControlling {
    let player: PlayerKind = .appleMusic
    func fetchPlaybackState() async -> PlaybackSnapshot? { ... }
    func playPause() async { ... }
    func nextTrack() async { ... }
    func previousTrack() async { ... }
}
```

Use a private parser helper so tests can validate script-output mapping without running AppleScript.

- [ ] **Step 4: Run test to verify it passes**

Run: `AppleMusicPlaybackMappingTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Lyrisland/Sources/Playback/AppleMusicAppleScriptService.swift Lyrisland/Tests/AppleMusicPlaybackMappingTests.swift
git commit -m "feat: add apple music playback service"
```

### Task 4: Wire arbitration and polling through AppDelegate

**Files:**
- Modify: `Lyrisland/Sources/App/AppDelegate.swift`
- Modify: `Lyrisland/Sources/App/AppState.swift`
- Create: `Lyrisland/Tests/AppStatePlayerStatusTests.swift`

- [ ] **Step 1: Write the failing tests**

Add tests for app/player status:
- detects installed/running players independently
- reports available players
- stores and exposes the selected active player

- [ ] **Step 2: Run test to verify it fails**

Run: `AppStatePlayerStatusTests`
Expected: FAIL because app state only models Spotify.

- [ ] **Step 3: Write minimal implementation**

Refactor app delegate to:
- create `SpotifyAppleScriptService` and `AppleMusicAppleScriptService`
- poll both services each tick
- feed results into `PlaybackCoordinator`
- switch `syncEngine.playbackController` to the active player
- reset `lastTrackId` and lyric offset when active player or track changes

Refactor app state to:
- replace `SpotifyStatus` with a generic player status model
- detect Spotify and Music installations/running state
- expose current active player for UI

- [ ] **Step 4: Run test to verify it passes**

Run: `AppStatePlayerStatusTests`, `PlaybackCoordinatorTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Lyrisland/Sources/App/AppDelegate.swift Lyrisland/Sources/App/AppState.swift Lyrisland/Tests/AppStatePlayerStatusTests.swift
git commit -m "feat: support multi-player polling and status"
```

### Task 5: Update UI and localization for dual-player support

**Files:**
- Modify: `Lyrisland/Sources/Views/SettingsView.swift`
- Modify: `Lyrisland/Sources/Views/OnboardingView.swift`
- Modify: `Lyrisland/Sources/Views/HelpView.swift`
- Modify: `Lyrisland/Sources/Resources/Localizable.xcstrings`

- [ ] **Step 1: Write the failing tests**

Add or extend localization tests to assert new player-related strings exist.

- [ ] **Step 2: Run test to verify it fails**

Run: `LocalizationTests`
Expected: FAIL because new keys are absent.

- [ ] **Step 3: Write minimal implementation**

Update UI copy and settings:
- onboarding checks Spotify or Apple Music availability
- settings shows active player / available players
- help mentions both supported apps

- [ ] **Step 4: Run test to verify it passes**

Run: `LocalizationTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Lyrisland/Sources/Views/SettingsView.swift Lyrisland/Sources/Views/OnboardingView.swift Lyrisland/Sources/Views/HelpView.swift Lyrisland/Sources/Resources/Localizable.xcstrings
git commit -m "feat: update ui copy for apple music support"
```

### Task 6: Full verification

**Files:**
- Modify: `Lyrisland/Tests/PlaybackCoordinatorTests.swift`
- Modify: `Lyrisland/Tests/AppleMusicPlaybackMappingTests.swift`
- Modify: `Lyrisland/Tests/AppStatePlayerStatusTests.swift`

- [ ] **Step 1: Run targeted tests**

Run:
- `PlaybackCoordinatorTests`
- `AppleMusicPlaybackMappingTests`
- `AppStatePlayerStatusTests`
- `LocalizationTests`

Expected: PASS.

- [ ] **Step 2: Run full build**

Run: Xcode `BuildProject`
Expected: build succeeds with no new errors.

- [ ] **Step 3: Sanity-check requirements against the plan**

Verify:
- Apple Music playback is detected
- Spotify still works
- active player auto-switches correctly
- lyrics still load from `TrackInfo`
- UI copy no longer assumes Spotify-only support

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add apple music support"
```
