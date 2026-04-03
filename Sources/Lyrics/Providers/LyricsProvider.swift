import Foundation

/// A source that can supply synced lyrics for a given track.
protocol LyricsProvider: Sendable {
    var name: String { get }
    var priority: Int { get }   // lower = higher priority
    func fetchLyrics(for track: TrackInfo) async throws -> SyncedLyrics?
}
