import SwiftUI

/// The root view hosted inside the DynamicIslandPanel.
struct IslandContentView: View {
    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager
    @ObservedObject var appState: AppState
    @State private var islandState: IslandState = .compact

    var body: some View {
        ZStack {
            // Background capsule
            RoundedRectangle(cornerRadius: islandState == .compact ? 20 : 24)
                .fill(.black)

            // Content based on state — `tick` dependency ensures periodic redraws
            let _ = syncEngine.tick // swiftlint:disable:this redundant_discardable_let
            switch islandState {
            case .compact:
                CompactIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager, appState: appState)
            case .expanded:
                ExpandedIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager, appState: appState)
            case .full:
                FullIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager)
            }
        }
        .frame(width: widthForState, height: heightForState)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: islandState)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.dualLineMode)
        .onReceive(NotificationCenter.default.publisher(for: .islandTapped)) { _ in
            cycleState()
        }
        .onChange(of: islandState) { _, newState in
            resizePanel(for: newState)
        }
        .onChange(of: appState.dualLineMode) { _, _ in
            resizePanel(for: islandState)
        }
    }

    private var widthForState: CGFloat {
        Self.size(for: islandState, dualLine: appState.dualLineMode).width
    }

    private var heightForState: CGFloat {
        Self.size(for: islandState, dualLine: appState.dualLineMode).height
    }

    static func size(for state: IslandState, dualLine: Bool = false) -> NSSize {
        switch state {
        case .compact: NSSize(width: 350, height: dualLine ? 58 : 38)
        case .expanded: NSSize(width: 380, height: 120)
        case .full: NSSize(width: 400, height: 300)
        }
    }

    private func cycleState() {
        switch islandState {
        case .compact: islandState = .expanded
        case .expanded: islandState = .full
        case .full: islandState = .compact
        }
    }

    private func resizePanel(for state: IslandState) {
        guard let window = NSApp.windows.first(where: { $0 is DynamicIslandPanel }) as? DynamicIslandPanel else { return }
        window.animateResize(to: Self.size(for: state, dualLine: appState.dualLineMode))
    }
}
