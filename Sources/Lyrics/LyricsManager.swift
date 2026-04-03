import Foundation
import Combine

/// Manages lyric fetching with provider fallback chain and caching.
@MainActor
final class LyricsManager: ObservableObject {
    @Published private(set) var currentLyrics: SyncedLyrics?
    @Published private(set) var isLoading = false

    /// Providers sorted by priority (lower = tried first).
    private let providers: [LyricsProvider] = [
        LRCLibProvider(),
        // Add more providers here — they will be tried in priority order.
    ]

    /// In-memory cache keyed by track ID.
    private var cache: [String: SyncedLyrics] = [:]

    func loadLyrics(for track: TrackInfo) async {
        // Check cache
        if let cached = cache[track.id] {
            currentLyrics = cached
            return
        }

        isLoading = true
        defer { isLoading = false }

        // Walk the fallback chain
        for provider in providers.sorted(by: { $0.priority < $1.priority }) {
            do {
                if let lyrics = try await provider.fetchLyrics(for: track) {
                    cache[track.id] = lyrics
                    currentLyrics = lyrics
                    return
                }
            } catch {
                // Provider failed — try next
                continue
            }
        }

        // No provider returned lyrics
        currentLyrics = nil
    }

    func clearCache() {
        cache.removeAll()
    }
}
