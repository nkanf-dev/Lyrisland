import Foundation

/// Fetches synced lyrics from LRCLIB (https://lrclib.net).
/// Free, open API — no auth required.
struct LRCLibProvider: LyricsProvider {
    let name = "lrclib"
    let priority = 0

    private let baseURL = "https://lrclib.net/api"

    func fetchLyrics(for track: TrackInfo) async throws -> SyncedLyrics? {
        // Try exact match first, then search fallback
        if let lyrics = try await fetchExact(track: track) {
            return lyrics
        }
        return try await fetchSearch(track: track)
    }

    // MARK: - Exact match by metadata

    private func fetchExact(track: TrackInfo) async throws -> SyncedLyrics? {
        var components = URLComponents(string: "\(baseURL)/get")!
        components.queryItems = [
            URLQueryItem(name: "track_name", value: track.title),
            URLQueryItem(name: "artist_name", value: track.artist),
            URLQueryItem(name: "album_name", value: track.album),
            URLQueryItem(name: "duration", value: String(Int(track.durationSeconds))),
        ]

        guard let url = components.url else { return nil }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        return try parseLRCLibResponse(data)
    }

    // MARK: - Search fallback

    private func fetchSearch(track: TrackInfo) async throws -> SyncedLyrics? {
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "\(track.title) \(track.artist)"),
        ]

        guard let url = components.url else { return nil }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        guard let results = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let first = results.first,
              let resultData = try? JSONSerialization.data(withJSONObject: first) else {
            return nil
        }

        return try parseLRCLibResponse(resultData)
    }

    // MARK: - LRC Parsing

    private func parseLRCLibResponse(_ data: Data) throws -> SyncedLyrics? {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let syncedLyrics = json["syncedLyrics"] as? String else {
            return nil
        }

        let lines = parseLRC(syncedLyrics)
        guard !lines.isEmpty else { return nil }
        return SyncedLyrics(lines: lines, source: name, globalOffset: 0)
    }

    /// Parse standard LRC format: [mm:ss.xx] text
    private func parseLRC(_ raw: String) -> [LyricLine] {
        let pattern = #"\[(\d{2}):(\d{2})\.(\d{2,3})\]\s*(.*)"#
        let regex = try! NSRegularExpression(pattern: pattern)

        var lines: [LyricLine] = []
        for (index, line) in raw.components(separatedBy: .newlines).enumerated() {
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range) else { continue }

            let minutes = Double(line[Range(match.range(at: 1), in: line)!])!
            let seconds = Double(line[Range(match.range(at: 2), in: line)!])!
            let msString = String(line[Range(match.range(at: 3), in: line)!])
            let ms = Double(msString)! / (msString.count == 2 ? 100.0 : 1000.0)
            let text = String(line[Range(match.range(at: 4), in: line)!])

            guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { continue }

            let time = minutes * 60 + seconds + ms
            lines.append(LyricLine(id: index, time: time, text: text, translation: nil))
        }

        return lines.sorted { $0.time < $1.time }
    }
}
