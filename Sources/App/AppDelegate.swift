import AppKit
import SwiftUI
import Combine

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var islandPanel: DynamicIslandPanel?
    private var statusItem: NSStatusItem?
    private let spotifyService = SpotifyAppleScriptService()
    private let lyricsManager = LyricsManager()
    private let syncEngine = PlaybackSyncEngine()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupIslandPanel()
        startPlaybackMonitoring()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "SpotifyLyricBar")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show/Hide Lyrics", action: #selector(toggleIsland), keyEquivalent: "l"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    // MARK: - Island Panel

    private func setupIslandPanel() {
        let contentView = IslandContentView(
            syncEngine: syncEngine,
            lyricsManager: lyricsManager
        )
        islandPanel = DynamicIslandPanel(contentView: contentView)
        islandPanel?.orderFrontRegardless()
    }

    // MARK: - Playback Monitoring

    private func startPlaybackMonitoring() {
        // Poll Spotify via AppleScript every 200ms for playback position
        Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.pollSpotify()
            }
            .store(in: &cancellables)
    }

    private var lastTrackId: String?

    private func pollSpotify() {
        guard let state = spotifyService.fetchPlaybackState() else {
            syncEngine.calibrate(position: 0, isPlaying: false)
            return
        }

        syncEngine.calibrate(position: state.position, isPlaying: state.isPlaying)

        // Track changed → fetch new lyrics
        if state.trackId != lastTrackId {
            lastTrackId = state.trackId
            Task {
                let track = TrackInfo(
                    id: state.trackId,
                    title: state.title,
                    artist: state.artist,
                    album: state.album,
                    durationMs: state.durationMs
                )
                await lyricsManager.loadLyrics(for: track)
            }
        }
    }

    // MARK: - Actions

    @objc private func toggleIsland() {
        if islandPanel?.isVisible == true {
            islandPanel?.orderOut(nil)
        } else {
            islandPanel?.orderFrontRegardless()
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
