import Combine
import Foundation
import QuartzCore

/// Maintains a high-precision interpolated playback position.
///
/// AppleScript polls every ~200ms and provides a "calibration anchor".
/// Between polls a display-link timer linearly interpolates the position
/// so lyric scrolling stays smooth.
@MainActor
final class PlaybackSyncEngine: ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTrackId: String?

    /// Monotonically incrementing tick that drives SwiftUI redraws.
    /// Views read `position` inside a body that depends on `tick`.
    @Published private(set) var tick: UInt64 = 0

    /// The current interpolated position (seconds). Read this in view bodies.
    private(set) var position: TimeInterval = 0

    /// The most recent anchor: (system timestamp, playback position in seconds).
    private var anchor: (date: Date, position: TimeInterval)?

    private var displayLink: CVDisplayLink?
    private var tickTimer: Timer?

    init() {
        startTickTimer()
    }

    deinit {
        tickTimer?.invalidate()
    }

    /// Called by the AppleScript polling timer.
    func calibrate(position: TimeInterval, isPlaying: Bool) {
        anchor = (Date(), position)
        let wasPlaying = self.isPlaying
        self.isPlaying = isPlaying

        // Adjust tick rate when play state changes
        if wasPlaying != isPlaying {
            startTickTimer()
        }
    }

    func setTrackId(_ id: String?) {
        currentTrackId = id
    }

    /// Linearly interpolated position.
    var interpolatedPosition: TimeInterval {
        guard let anchor, isPlaying else {
            return anchor?.position ?? 0
        }
        return anchor.position + Date().timeIntervalSince(anchor.date)
    }

    // MARK: - Tick Timer

    /// Use a Timer on the main run loop at ~30 fps when playing, paused when not.
    /// Each tick updates `position` and bumps the published `tick` counter,
    /// which triggers SwiftUI to re-evaluate views that read `position`.
    private func startTickTimer() {
        tickTimer?.invalidate()

        guard isPlaying else {
            // One final update so the UI shows the paused position
            updatePosition()
            return
        }

        // ~30 fps is enough for line-level lyrics scrolling
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePosition()
            }
        }
        // Keep firing even during tracking loops (e.g. window drag)
        RunLoop.main.add(tickTimer!, forMode: .common)
    }

    private func updatePosition() {
        position = interpolatedPosition
        tick &+= 1
    }
}
