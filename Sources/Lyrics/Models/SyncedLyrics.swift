import Foundation

/// A single time-stamped lyric line.
struct LyricLine: Identifiable, Sendable {
    let id: Int          // index in the lyrics array
    let time: TimeInterval
    let text: String
    let translation: String?
}

/// Parsed synced lyrics with source attribution.
struct SyncedLyrics: Sendable {
    let lines: [LyricLine]
    let source: String        // e.g. "lrclib"
    let globalOffset: TimeInterval  // user-adjustable offset (seconds)

    /// Find the index of the active line for a given playback position.
    func lineIndex(at position: TimeInterval) -> Int? {
        let adjusted = position + globalOffset
        return lines.lastIndex(where: { $0.time <= adjusted })
    }
}
