@testable import Lyrisland
import Combine
import Testing

@MainActor
struct AppStatePlayerStatusTests {
    @Test("refresh tracks installed and running state for both players")
    func refreshTracksPlayerStatuses() {
        let appState = AppState()
        let inspector = PlayerEnvironmentInspectorStub(
            installed: [.spotify],
            running: [.spotify]
        )

        appState.refresh(inspector: inspector)

        #expect(appState.status(for: .spotify) == .running)
        #expect(appState.status(for: .appleMusic) == .notInstalled)
        #expect(appState.availablePlayers == [.spotify])
    }

    @Test("refresh marks installed but not running players correctly")
    func refreshMarksInstalledButNotRunningPlayers() {
        let appState = AppState()
        let inspector = PlayerEnvironmentInspectorStub(
            installed: [.spotify, .appleMusic],
            running: [.appleMusic]
        )

        appState.refresh(inspector: inspector)

        #expect(appState.status(for: .spotify) == .notRunning)
        #expect(appState.status(for: .appleMusic) == .running)
        #expect(appState.availablePlayers == [.spotify, .appleMusic])
    }

    @Test("active player can be updated independently from refresh")
    func activePlayerCanBeUpdated() {
        let appState = AppState()

        appState.setActivePlayer(.appleMusic)

        #expect(appState.activePlayer == .appleMusic)
    }

    @Test("refresh does not emit changes when player environment is unchanged")
    func refreshDoesNotEmitWhenUnchanged() {
        let appState = AppState()
        let inspector = PlayerEnvironmentInspectorStub(
            installed: [.spotify, .appleMusic],
            running: [.spotify],
            hasPermission: true
        )
        var emissions = 0
        let cancellable = appState.objectWillChange.sink {
            emissions += 1
        }

        appState.refresh(inspector: inspector)
        let emissionsAfterFirstRefresh = emissions

        appState.refresh(inspector: inspector)

        #expect(emissionsAfterFirstRefresh > 0)
        #expect(emissions == emissionsAfterFirstRefresh)
        _ = cancellable
    }

    @Test("poll prefers Apple Music when both supported players are running")
    func pollPrefersAppleMusicWhenAvailable() {
        let players = AppDelegate.playersToPoll(
            for: [
                .spotify: .running,
                .appleMusic: .running,
            ]
        )

        #expect(players == [.appleMusic])
    }

    @Test("poll falls back to Spotify when Apple Music is unavailable")
    func pollFallsBackToSpotify() {
        let players = AppDelegate.playersToPoll(
            for: [
                .spotify: .running,
                .appleMusic: .notRunning,
            ]
        )

        #expect(players == [.spotify])
    }
}

private struct PlayerEnvironmentInspectorStub: PlayerEnvironmentInspecting {
    let installed: Set<PlayerKind>
    let running: Set<PlayerKind>
    var hasPermission: Bool = true

    func isInstalled(_ player: PlayerKind) -> Bool {
        installed.contains(player)
    }

    func isRunning(_ player: PlayerKind) -> Bool {
        running.contains(player)
    }

    func hasAutomationPermission() -> Bool {
        hasPermission
    }
}
