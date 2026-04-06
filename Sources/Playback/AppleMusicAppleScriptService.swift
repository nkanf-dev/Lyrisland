import Foundation

final class AppleMusicAppleScriptService: PlaybackControlling {
    let player: PlayerKind = .appleMusic
    private let session = URLSession(configuration: .default)
    private let artworkURLCache = ArtworkURLCache()

    private let script: String = """
    if application \"Music\" is running then
        tell application \"Music\"
            set trackId to persistent ID of current track
            set trackName to name of current track
            set trackArtist to artist of current track
            set trackAlbum to album of current track
            set trackDuration to duration of current track
            set playerPos to player position
            set playerState to player state as string
            return trackId & \"||\" & trackName & \"||\" & trackArtist & \"||\" & trackAlbum & \"||\" & (trackDuration as string) & \"||\" & (playerPos as string) & \"||\" & playerState
        end tell
    else
        return \"NOT_RUNNING\"
    end if
    """

    private let queue = DispatchQueue(label: "com.lyrisland.applemusic", qos: .userInitiated)

    func fetchPlaybackState() async -> PlaybackSnapshot? {
        let snapshot = await withCheckedContinuation { continuation in
            queue.async { [script] in
                continuation.resume(returning: Self.executeScript(script))
            }
        }

        guard let snapshot else { return nil }
        return await enrichArtworkURL(for: snapshot)
    }

    func playPause() async {
        await executeCommand("playpause")
    }

    func nextTrack() async {
        await executeCommand("next track")
    }

    func previousTrack() async {
        await executeCommand("previous track")
    }

    private func executeCommand(_ command: String) async {
        await withCheckedContinuation { continuation in
            queue.async {
                let source = """
                if application \"Music\" is running then
                    tell application \"Music\" to \(command)
                end if
                """
                guard let script = NSAppleScript(source: source) else {
                    continuation.resume()
                    return
                }
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                if let error {
                    logDebug("AppleScript command failed: \(error)")
                }
                continuation.resume()
            }
        }
    }

    static func parse(raw: String) -> PlaybackSnapshot? {
        guard raw != "NOT_RUNNING" else { return nil }

        let parts = raw.components(separatedBy: "||")
        guard parts.count >= 7 else { return nil }

        return PlaybackSnapshot(
            player: .appleMusic,
            trackId: parts[0],
            title: parts[1],
            artist: parts[2],
            album: parts[3],
            durationMs: Int((Double(parts[4]) ?? 0) * 1000),
            position: Double(parts[5]) ?? 0,
            isPlaying: parts[6] == "playing",
            artworkURL: nil
        )
    }

    static func artworkLookupRequest(for snapshot: PlaybackSnapshot) -> URLRequest? {
        let searchTerm = [snapshot.artist, snapshot.album, snapshot.title]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        guard var components = URLComponents(string: "https://itunes.apple.com/search") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "term", value: searchTerm),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "5"),
        ]

        guard let url = components.url else { return nil }
        return URLRequest(url: url)
    }

    static func extractArtworkURL(from data: Data, matching snapshot: PlaybackSnapshot) -> String? {
        guard let response = try? JSONDecoder().decode(ArtworkLookupResponse.self, from: data) else {
            return nil
        }

        let loweredAlbum = snapshot.album.lowercased()
        let loweredArtist = snapshot.artist.lowercased()
        let loweredTitle = snapshot.title.lowercased()

        let bestMatch = response.results.first {
            $0.artistName.lowercased() == loweredArtist &&
                $0.trackName.lowercased() == loweredTitle &&
                $0.collectionName.lowercased() == loweredAlbum
        } ?? response.results.first {
            $0.artistName.lowercased() == loweredArtist &&
                $0.trackName.lowercased() == loweredTitle
        } ?? response.results.first

        guard let artworkURL = bestMatch?.artworkUrl100 else {
            return nil
        }

        return artworkURL.replacingOccurrences(of: "100x100bb", with: "512x512bb")
    }

    private static func executeScript(_ source: String) -> PlaybackSnapshot? {
        guard let appleScript = NSAppleScript(source: source) else { return nil }

        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        if let error {
            logDebug("AppleScript execution failed: \(error)")
        }

        guard error == nil, let raw = result.stringValue else { return nil }
        return parse(raw: raw)
    }

    private func enrichArtworkURL(for snapshot: PlaybackSnapshot) async -> PlaybackSnapshot {
        if let cachedArtworkURL = await artworkURLCache.value(for: snapshot.trackId) {
            return PlaybackSnapshot(
                player: snapshot.player,
                trackId: snapshot.trackId,
                title: snapshot.title,
                artist: snapshot.artist,
                album: snapshot.album,
                durationMs: snapshot.durationMs,
                position: snapshot.position,
                isPlaying: snapshot.isPlaying,
                artworkURL: cachedArtworkURL,
                detectedAt: snapshot.detectedAt
            )
        }

        guard let request = Self.artworkLookupRequest(for: snapshot),
              let (data, _) = try? await session.data(for: request),
              let artworkURL = Self.extractArtworkURL(from: data, matching: snapshot)
        else {
            return snapshot
        }

        await artworkURLCache.set(artworkURL, for: snapshot.trackId)
        return PlaybackSnapshot(
            player: snapshot.player,
            trackId: snapshot.trackId,
            title: snapshot.title,
            artist: snapshot.artist,
            album: snapshot.album,
            durationMs: snapshot.durationMs,
            position: snapshot.position,
            isPlaying: snapshot.isPlaying,
            artworkURL: artworkURL,
            detectedAt: snapshot.detectedAt
        )
    }
}

actor ArtworkURLCache {
    private var storage: [String: String] = [:]

    func value(for trackId: String) -> String? {
        storage[trackId]
    }

    func set(_ artworkURL: String, for trackId: String) {
        storage[trackId] = artworkURL
    }
}

private struct ArtworkLookupResponse: Decodable {
    let results: [ArtworkLookupResult]
}

private struct ArtworkLookupResult: Decodable {
    let artistName: String
    let trackName: String
    let collectionName: String
    let artworkUrl100: String?
}
