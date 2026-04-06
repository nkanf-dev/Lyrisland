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

    @Test("artwork lookup request includes artist and album metadata")
    func artworkLookupRequestIncludesMetadata() {
        let snapshot = PlaybackSnapshot(
            player: .appleMusic,
            trackId: "music-track",
            title: "Track B",
            artist: "Artist Name",
            album: "Album Name",
            durationMs: 180_000,
            position: 42,
            isPlaying: true,
            artworkURL: nil
        )

        let request = AppleMusicAppleScriptService.artworkLookupRequest(for: snapshot)
        let absoluteString = request?.url?.absoluteString ?? ""

        #expect(absoluteString.contains("itunes.apple.com/search"))
        #expect(absoluteString.contains("Artist%20Name"))
        #expect(absoluteString.contains("Album%20Name"))
    }

    @Test("extract artwork URL prefers a matched album result")
    func extractArtworkURLPrefersMatchedAlbum() throws {
        let snapshot = PlaybackSnapshot(
            player: .appleMusic,
            trackId: "music-track",
            title: "Track B",
            artist: "Artist Name",
            album: "Album Name",
            durationMs: 180_000,
            position: 42,
            isPlaying: true,
            artworkURL: nil
        )
        let data = try #require("""
        {
          "resultCount": 2,
          "results": [
            {
              "artistName": "Artist Name",
              "trackName": "Track B",
              "collectionName": "Other Album",
              "artworkUrl100": "https://example.com/other/100x100bb.jpg"
            },
            {
              "artistName": "Artist Name",
              "trackName": "Track B",
              "collectionName": "Album Name",
              "artworkUrl100": "https://example.com/matched/100x100bb.jpg"
            }
          ]
        }
        """.data(using: .utf8))

        let artworkURL = AppleMusicAppleScriptService.extractArtworkURL(from: data, matching: snapshot)

        #expect(artworkURL == "https://example.com/matched/512x512bb.jpg")
    }

    @Test("artwork URL cache serializes concurrent access")
    func artworkURLCacheSerializesConcurrentAccess() async {
        let cache = ArtworkURLCache()

        await withTaskGroup(of: Void.self) { group in
            for index in 0 ..< 100 {
                group.addTask {
                    await cache.set("https://example.com/\(index)", for: "track-\(index)")
                }
            }
        }

        let cachedArtworkURL = await cache.value(for: "track-42")
        #expect(cachedArtworkURL == "https://example.com/42")
    }

    @Test("Spotify parse maps playing response including artwork URL")
    func spotifyParsePlayingResponse() {
        let state = SpotifyAppleScriptService.parse(
            raw: "spotify:track:123||Track A||Artist||Album||180000||42.5||playing||https://example.com/cover.jpg"
        )

        #expect(state?.trackId == "spotify:track:123")
        #expect(state?.title == "Track A")
        #expect(state?.artist == "Artist")
        #expect(state?.album == "Album")
        #expect(state?.durationMs == 180000)
        #expect(state?.position == 42.5)
        #expect(state?.isPlaying == true)
        #expect(state?.artworkURL == "https://example.com/cover.jpg")
    }

    @Test("Spotify parse returns nil when app is not running")
    func spotifyParseNotRunningResponse() {
        let state = SpotifyAppleScriptService.parse(raw: "NOT_RUNNING")

        #expect(state == nil)
    }
}
