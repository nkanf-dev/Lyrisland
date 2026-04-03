import SwiftUI

/// The root view hosted inside the DynamicIslandPanel.
struct IslandContentView: View {
    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager
    @State private var islandState: IslandState = .compact

    var body: some View {
        ZStack {
            // Background capsule
            RoundedRectangle(cornerRadius: islandState == .compact ? 20 : 24)
                .fill(.black)
                .shadow(color: .black.opacity(0.4), radius: 12, y: 4)

            // Content based on state
            switch islandState {
            case .compact:
                CompactIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager)
            case .expanded:
                ExpandedIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager)
            case .full:
                FullIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager)
            }
        }
        .frame(width: widthForState, height: heightForState)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: islandState)
        .onTapGesture {
            cycleState()
        }
    }

    private var widthForState: CGFloat {
        switch islandState {
        case .compact:  return 350
        case .expanded: return 380
        case .full:     return 400
        }
    }

    private var heightForState: CGFloat {
        switch islandState {
        case .compact:  return 38
        case .expanded: return 120
        case .full:     return 300
        }
    }

    private func cycleState() {
        switch islandState {
        case .compact:  islandState = .expanded
        case .expanded: islandState = .full
        case .full:     islandState = .compact
        }
    }
}
