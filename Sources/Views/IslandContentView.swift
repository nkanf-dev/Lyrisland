import SwiftUI

/// The root view hosted inside the DynamicIslandPanel.
struct IslandContentView: View {
    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager
    @State private var islandState: IslandState = .compact
    @State private var dragStartLocation: CGPoint?

    var body: some View {
        ZStack {
            // Background capsule
            RoundedRectangle(cornerRadius: islandState == .compact ? 20 : 24)
                .fill(.black)

            // Content based on state — `tick` dependency ensures periodic redraws
            let _ = syncEngine.tick
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
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if dragStartLocation == nil {
                        dragStartLocation = value.startLocation
                    }
                }
                .onEnded { value in
                    let distance = hypot(
                        value.location.x - (dragStartLocation ?? value.startLocation).x,
                        value.location.y - (dragStartLocation ?? value.startLocation).y
                    )
                    // Only cycle state if it was a tap (minimal movement)
                    if distance < 5 {
                        cycleState()
                    }
                    dragStartLocation = nil
                }
        )
        .onChange(of: islandState) { _, newState in
            resizePanel(for: newState)
        }
    }

    private var widthForState: CGFloat {
        Self.size(for: islandState).width
    }

    private var heightForState: CGFloat {
        Self.size(for: islandState).height
    }

    static func size(for state: IslandState) -> NSSize {
        switch state {
        case .compact:  return NSSize(width: 350, height: 38)
        case .expanded: return NSSize(width: 380, height: 120)
        case .full:     return NSSize(width: 400, height: 300)
        }
    }

    private func cycleState() {
        switch islandState {
        case .compact:  islandState = .expanded
        case .expanded: islandState = .full
        case .full:     islandState = .compact
        }
    }

    private func resizePanel(for state: IslandState) {
        guard let window = NSApp.windows.first(where: { $0 is DynamicIslandPanel }) as? DynamicIslandPanel else { return }
        window.animateResize(to: Self.size(for: state))
    }
}
