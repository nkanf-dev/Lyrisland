import Foundation
import Combine

/// Maintains a high-precision interpolated playback position.
///
/// AppleScript polls every ~200ms and provides a "calibration anchor".
/// Between polls a display-link driven timer linearly interpolates the position
/// so lyric scrolling stays smooth at ~60 fps.
@MainActor
final class PlaybackSyncEngine: ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTrackId: String?

    /// The most recent anchor: (system timestamp, playback position in seconds).
    private var anchor: (date: Date, position: TimeInterval)?

    /// Called by the AppleScript polling timer.
    func calibrate(position: TimeInterval, isPlaying: Bool) {
        self.anchor = (Date(), position)
        self.isPlaying = isPlaying
    }

    func setTrackId(_ id: String?) {
        currentTrackId = id
    }

    /// Linearly interpolated position — call from SwiftUI body or DisplayLink callback.
    var interpolatedPosition: TimeInterval {
        guard let anchor, isPlaying else {
            return anchor?.position ?? 0
        }
        return anchor.position + Date().timeIntervalSince(anchor.date)
    }
}
