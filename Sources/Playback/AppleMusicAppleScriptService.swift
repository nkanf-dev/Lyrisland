import Foundation

final class AppleMusicAppleScriptService: PlaybackControlling {
    let player: PlayerKind = .appleMusic

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
        await withCheckedContinuation { continuation in
            queue.async { [script] in
                continuation.resume(returning: Self.executeScript(script))
            }
        }
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
}
