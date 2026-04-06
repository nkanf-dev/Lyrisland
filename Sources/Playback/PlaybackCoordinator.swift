import Foundation

struct PlaybackCoordinator {
    var lastActivePlayer: PlayerKind?

    func selectActivePlayback(from snapshots: [PlayerKind: PlaybackSnapshot]) -> PlaybackSnapshot? {
        let playingSnapshots = snapshots.values.filter(\.isPlaying)
        if let selectedPlaying = playingSnapshots.max(by: { $0.detectedAt < $1.detectedAt }) {
            return selectedPlaying
        }

        if let lastActivePlayer, let snapshot = snapshots[lastActivePlayer] {
            return snapshot
        }

        return PlayerKind.allCases.compactMap { snapshots[$0] }.first
    }
}
