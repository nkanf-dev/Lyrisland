@testable import Lyrisland
import Foundation
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
