import Foundation

protocol PlaybackControlling: AnyObject {
    var player: PlayerKind { get }
    func fetchPlaybackState() async -> PlaybackSnapshot?
    func playPause() async
    func nextTrack() async
    func previousTrack() async
}
