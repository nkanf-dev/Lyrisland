@testable import Lyrisland
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
}

private struct PlayerEnvironmentInspectorStub: PlayerEnvironmentInspecting {
    let installed: Set<PlayerKind>
    let running: Set<PlayerKind>

    func isInstalled(_ player: PlayerKind) -> Bool {
        installed.contains(player)
    }

    func isRunning(_ player: PlayerKind) -> Bool {
        running.contains(player)
    }

    func hasAutomationPermission() -> Bool {
        true
    }
}
