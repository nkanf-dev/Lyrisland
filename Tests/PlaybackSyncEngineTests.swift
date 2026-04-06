@testable import Lyrisland
import Foundation
import Testing

@MainActor
struct PlaybackSyncEngineTests {
    @Test("apply snapshot updates track and playback state")
    func applySnapshotUpdatesState() {
        let engine = PlaybackSyncEngine()
        let snapshot = PlaybackSnapshot(
            player: .appleMusic,
            trackId: "music-track",
            title: "Track B",
            artist: "Artist",
            album: "Album",
            durationMs: 180_000,
            position: 42,
            isPlaying: true,
            artworkURL: "https://example.com/cover.jpg"
        )

        engine.apply(snapshot: snapshot)

        #expect(engine.currentTrackId == "music-track")
        #expect(engine.trackTitle == "Track B")
        #expect(engine.trackArtist == "Artist")
        #expect(engine.artworkURL?.absoluteString == "https://example.com/cover.jpg")
        #expect(engine.isPlaying)
        #expect(engine.position == 42)
    }

    @Test("playback commands are forwarded to the active controller")
    func commandsForwardToController() async {
        let engine = PlaybackSyncEngine()
        let controller = PlaybackControllerSpy()
        engine.playbackController = controller

        await engine.playPauseNow()
        await engine.nextTrackNow()
        await engine.previousTrackNow()

        let commands = controller.commands
        #expect(commands == [.playPause, .nextTrack, .previousTrack])
    }
}

@MainActor
private final class PlaybackControllerSpy: PlaybackControlling {
    enum Command: Equatable {
        case playPause
        case nextTrack
        case previousTrack
    }

    let player: PlayerKind = .appleMusic
    private(set) var commands: [Command] = []

    func fetchPlaybackState() async -> PlaybackSnapshot? {
        nil
    }

    func playPause() async {
        commands.append(.playPause)
    }

    func nextTrack() async {
        commands.append(.nextTrack)
    }

    func previousTrack() async {
        commands.append(.previousTrack)
    }

}
