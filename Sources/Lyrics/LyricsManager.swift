import Combine
import Foundation

/// Manages lyric fetching with provider fallback chain and caching.
@MainActor
final class LyricsManager: ObservableObject {
    @Published private(set) var currentLyrics: SyncedLyrics?
    @Published private(set) var isLoading = false
    @Published var userOffset: TimeInterval = 0 // ± seconds, applied on top of globalOffset

    /// Adjust user offset by a delta (e.g. +0.5 or -0.5 seconds).
    func adjustOffset(by delta: TimeInterval) {
        userOffset += delta
        // Rebuild current lyrics with updated offset
        if let lyrics = currentLyrics {
            currentLyrics = SyncedLyrics(
                lines: lyrics.lines,
                source: lyrics.source,
                globalOffset: lyrics.globalOffset + delta
            )
        }
    }

    func resetOffset() {
        if let lyrics = currentLyrics {
            currentLyrics = SyncedLyrics(
                lines: lyrics.lines,
                source: lyrics.source,
                globalOffset: lyrics.globalOffset - userOffset
            )
        }
        userOffset = 0
    }

    /// Providers sorted by priority (lower = tried first).
    private let providers: [LyricsProvider] = [
        LRCLibProvider(), // 0 — open, free, no auth
        MusixmatchProvider(), // 1 — strong for Western music, richsync
        SodaMusicProvider(), // 2 — ByteDance, good for Chinese lyrics
        NeteaseProvider(), // 3 — Netease Cloud Music, strong for Chinese/Asian music
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
