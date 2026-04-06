@testable import Lyrisland
import Foundation
import Testing

struct AppleMusicPlaybackMappingTests {
    @Test("parse maps playing Music.app response into a playback snapshot")
    func parsePlayingResponse() {
        let snapshot = AppleMusicAppleScriptService.parse(raw: "music-track||Track B||Artist||Album||180.5||42.25||playing")

        #expect(snapshot?.player == .appleMusic)
        #expect(snapshot?.trackId == "music-track")
        #expect(snapshot?.title == "Track B")
        #expect(snapshot?.artist == "Artist")
        #expect(snapshot?.album == "Album")
        #expect(snapshot?.durationMs == 180_500)
        #expect(snapshot?.position == 42.25)
        #expect(snapshot?.isPlaying == true)
    }

    @Test("parse returns nil when Music.app is not running")
    func parseNotRunningResponse() {
        let snapshot = AppleMusicAppleScriptService.parse(raw: "NOT_RUNNING")

        #expect(snapshot == nil)
    }

    @Test("parse maps paused Music.app response")
    func parsePausedResponse() {
        let snapshot = AppleMusicAppleScriptService.parse(raw: "music-track||Track B||Artist||Album||200||0||paused")

        #expect(snapshot?.isPlaying == false)
        #expect(snapshot?.durationMs == 200_000)
    }
}
