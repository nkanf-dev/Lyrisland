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
