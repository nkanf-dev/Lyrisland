import SwiftUI

/// The root view hosted inside the DynamicIslandPanel.
struct IslandContentView: View {
    enum RightClickAction: Equatable {
        case ignore
        case collapse
        case confirmQuit
    }

    private static let attachedCompactWidth: CGFloat = 264
    private static let attachedCompactTopBarHorizontalInset: CGFloat = earRadius + 8
    private static let attachedCompactTopBarTopInset: CGFloat = 4

    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager
    @ObservedObject var appState: AppState
    @State private var islandState: IslandState = .compact
    @State private var compactPresentation: CompactIslandView.CompactPresentationMode = .normal
    @State private var isAttached: Bool = UserDefaults.standard.islandPositionMode == .attached
    @State private var isInSnapZone = false

    private var cornerRadius: CGFloat {
        islandState == .compact ? 20 : 24
    }

    /// Whether the island should use attached visual appearance (actual attached or snap zone preview).
    private var showAttachedAppearance: Bool {
        isAttached || isInSnapZone
    }

    var body: some View {
        ZStack(alignment: showAttachedAppearance ? .bottom : .topLeading) {
            // Background: attached mode (or snap zone preview) has inverse top corners, detached has full rounded corners
            if showAttachedAppearance {
                IslandBackgroundView(
                    style: appState.backgroundStyle,
                    shape: AnyShape(AttachedIslandShape(bottomRadius: cornerRadius, inverseRadius: Self.earRadius)),
                    trackId: syncEngine.currentTrackId,
                    artworkURL: syncEngine.artworkURL,
                    isPlaying: syncEngine.isPlaying,
                    solidColor: appState.solidColor
                )
                .overlay(
                    AttachedIslandShape(
                        bottomRadius: cornerRadius,
                        inverseRadius: Self.earRadius
                    )
                    .stroke(appState.contentColor.opacity(isInSnapZone ? 0.4 : 0.15), lineWidth: isInSnapZone ? 1.0 : 0.5)
                )
            } else {
                IslandBackgroundView(
                    style: appState.backgroundStyle,
                    shape: AnyShape(RoundedRectangle(cornerRadius: cornerRadius)),
                    trackId: syncEngine.currentTrackId,
                    artworkURL: syncEngine.artworkURL,
                    isPlaying: syncEngine.isPlaying
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(appState.contentColor.opacity(0.15), lineWidth: 0.5)
                )
            }

            // In attached mode, content is aligned to the bottom so it appears below the menu bar
            HStack(spacing: 10) {
                if appState.showArtwork, islandState != .compact {
                    artworkColumn
                }

                switch islandState {
                case .compact:
                    CompactIslandView(
                        syncEngine: syncEngine,
                        lyricsManager: lyricsManager,
                        appState: appState,
                        attached: showAttachedCompactTopBar,
                        presentation: compactPresentation
                    )
                case .expanded:
                    ExpandedIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager, appState: appState)
                case .full:
                    FullIslandView(syncEngine: syncEngine, lyricsManager: lyricsManager, appState: appState)
                }
            }
            .frame(
                maxHeight: showAttachedAppearance
                    ? Self.contentHeight(
                        for: islandState,
                        attached: isAttached,
                        dualLine: appState.dualLineMode,
                        artwork: appState.showArtwork,
                        compactPresentation: compactPresentation
                    )
                    : .infinity
            )
            .padding(.horizontal, showAttachedAppearance ? Self.earRadius : 0)
            .padding(contentPadding)

            if showAttachedCompactTopBar {
                attachedCompactTopBar
                    .padding(.horizontal, Self.attachedCompactTopBarHorizontalInset)
                    .padding(.top, Self.attachedCompactTopBarTopInset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .environment(\.rootFontSize, appState.rootFontSize)
        .environment(\.contentColor, appState.contentColor)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: showAttachedAppearance ? .bottom : .topLeading
        )
        .clipShape(
            showAttachedAppearance
                ? AnyShape(AttachedIslandShape(bottomRadius: cornerRadius, inverseRadius: Self.earRadius))
                : AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        )
        // In detached mode, offset the clipped island down so content that
        // overshoots during transitions has transparent space above.
        .padding(.top, showAttachedAppearance ? 0 : Self.transitionOverflowMargin)
        .shadow(color: appState.contentColor.opacity(isInSnapZone ? 0.3 : 0), radius: 8)
        .onReceive(NotificationCenter.default.publisher(for: .islandTapped)) { _ in
            cycleState()
        }
        .onReceive(NotificationCenter.default.publisher(for: .islandRightClicked)) { _ in
            switch Self.rightClickAction(for: islandState, compactPresentation: compactPresentation) {
            case .ignore:
                break
            case .collapse:
                withAnimation(.easeOut(duration: 0.2)) {
                    compactPresentation = .collapsed
                }
                resizePanel(for: islandState)
            case .confirmQuit:
                presentQuitConfirmation()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .islandPositionModeChanged)) { notification in
            if let mode = notification.object as? IslandPositionMode {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isAttached = mode == .attached
                }
                resizePanel(for: islandState)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .islandSnapZoneChanged)) { notification in
            if let inZone = notification.object as? Bool {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    isInSnapZone = inZone
                }
            }
        }
        .onChange(of: islandState) { _, newState in
            if newState != .compact {
                compactPresentation = .normal
            }
            resizePanel(for: newState)
        }
        .onChange(of: appState.dualLineMode) { _, _ in
            resizePanel(for: islandState)
        }
        .onChange(of: appState.showArtwork) { _, _ in
            resizePanel(for: islandState)
        }
    }

    // MARK: - Artwork (single persistent instance)

    private var rootFontSize: CGFloat {
        appState.rootFontSize
    }

    private var artworkColumn: some View {
        VStack(spacing: 0) {
            ArtworkView(trackId: syncEngine.currentTrackId, artworkURL: syncEngine.artworkURL, size: artworkSize)
                .padding(.top, islandState == .full ? 8 : 0)

            if islandState == .full {
                sourcePickerBadge
                    .padding(.top, 4)

                // Track info
                VStack(spacing: 2) {
                    if let title = syncEngine.trackTitle {
                        Text(title)
                            .font(.system(size: .rem(0.75, root: rootFontSize), weight: .semibold))
                            .foregroundStyle(appState.contentColor.opacity(0.8))
                            .lineLimit(1)
                    }
                    if let artist = syncEngine.trackArtist {
                        Text(artist)
                            .font(.system(size: .rem(0.6875, root: rootFontSize)))
                            .foregroundStyle(appState.contentColor.opacity(0.5))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 6)

                // Remaining space: controls centered within it
                PlaybackControlsView(syncEngine: syncEngine)
                    .frame(maxHeight: .infinity)
            }
        }
    }

    private var showAttachedCompactTopBar: Bool {
        isAttached && islandState == .compact
    }

    private var attachedCompactTopBar: some View {
        HStack(spacing: 0) {
            if appState.showArtwork {
                ArtworkView(
                    trackId: syncEngine.currentTrackId,
                    artworkURL: syncEngine.artworkURL,
                    size: CompactIslandView.LayoutMetrics.topRowArtworkSize
                )
                .frame(
                    width: CompactIslandView.LayoutMetrics.topRowArtworkSize,
                    height: CompactIslandView.LayoutMetrics.topRowArtworkSize
                )
            } else {
                Color.clear
                    .frame(
                        width: CompactIslandView.LayoutMetrics.topRowArtworkSize,
                        height: CompactIslandView.LayoutMetrics.topRowArtworkSize
                    )
            }

            Spacer(minLength: 0)

            if syncEngine.isPlaying {
                PlayingIndicator()
                    .frame(
                        width: CompactIslandView.LayoutMetrics.topRowIndicatorWidth,
                        height: CompactIslandView.LayoutMetrics.topRowArtworkSize
                    )
            } else {
                Image(systemName: compactStatusIcon)
                    .font(.system(size: .rem(0.625, root: rootFontSize)))
                    .foregroundStyle(appState.contentColor.opacity(0.6))
                    .frame(width: CompactIslandView.LayoutMetrics.topRowIndicatorWidth)
            }
        }
        .frame(height: CompactIslandView.LayoutMetrics.topRowHeight)
    }

    private var compactStatusIcon: String {
        if !syncEngine.isPlaying, syncEngine.currentTrackId == nil {
            return "antenna.radiowaves.left.and.right.slash"
        }
        return "pause.fill"
    }

    @ViewBuilder
    private var sourcePickerBadge: some View {
        if let currentSource = lyricsManager.currentLyrics?.source {
            HStack(spacing: 3) {
                Text(ProviderSettings.displayName(for: currentSource))
                Image(systemName: "arrow.triangle.2.circlepath")
                    .imageScale(.small)
            }
            .font(.system(size: .rem(0.5625, root: rootFontSize), weight: .medium))
            .foregroundStyle(appState.contentColor.opacity(0.3))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Capsule().fill(appState.contentColor.opacity(0.08)))
            .overlay {
                // Real NSButton so DynamicIslandPanel's hitTest detects it as NSControl
                NativeButtonOverlay {
                    NotificationCenter.default.post(name: .openLyricsPicker, object: nil)
                }
            }
        }
    }

    private var artworkSize: CGFloat {
        switch islandState {
        case .compact: 36
        case .expanded: 110
        case .full: 200
        }
    }

    private var contentPadding: EdgeInsets {
        switch islandState {
        case .compact:
            if showAttachedCompactTopBar {
                EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            } else {
                EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            }
        case .expanded:
            // In attached mode, move bottom padding to top so the content clears the notch.
            // The bottom padding otherwise pushes the bottom-aligned content up into the menu bar area.
            if showAttachedAppearance {
                EdgeInsets(top: 24, leading: 10, bottom: 0, trailing: 10)
            } else {
                EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10)
            }
        case .full:
            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        }
    }

    // MARK: - Sizing

    /// Extra height to extend behind the notch/menu bar in attached mode.
    /// Only needed on notched displays where the island emerges from the notch.
    /// Non-notch screens get no extension — the island sits flush at the screen top.
    static func menuBarHeight(for screen: NSScreen? = nil) -> CGFloat {
        guard let screen = screen ?? NSScreen.main else { return 0 }
        guard screen.hasNotch else { return 0 }
        return screen.frame.maxY - screen.visibleFrame.maxY
    }

    /// The content-only height (without menu bar extension).
    static func contentHeight(
        for state: IslandState,
        attached: Bool = false,
        dualLine: Bool = false,
        artwork: Bool = true,
        compactPresentation: CompactIslandView.CompactPresentationMode = .normal
    ) -> CGFloat {
        switch state {
        case .compact:
            if attached {
                switch compactPresentation {
                case .normal:
                    return CompactIslandView.LayoutMetrics.topRowHeight
                        + CompactIslandView.LayoutMetrics.lyricRowMinHeight
                        + 4
                case .collapsed:
                    return CompactIslandView.LayoutMetrics.topRowHeight - 10
                }
            }
            return artwork ? 48 : 38
        case .expanded:
            return artwork ? 140 : 120
        case .full:
            return artwork ? 340 : 340
        }
    }

    /// Radius of the inverse corner "ears" in attached mode.
    static let earRadius: CGFloat = 8

    /// Extra top margin in detached mode so content that overshoots during
    /// the SwiftUI transition animation has transparent space to overflow
    /// into instead of being clipped at the window edge.
    static let transitionOverflowMargin: CGFloat = 20

    /// Total vertical content padding for a given state (top + bottom).
    /// In attached mode this is absorbed by the menu-bar extension; in detached
    /// mode it must be added to the panel height explicitly.
    static func verticalPadding(for state: IslandState) -> CGFloat {
        state == .expanded ? 24 : 0
    }

    static func size(
        for state: IslandState,
        attached: Bool = false,
        dualLine: Bool = false,
        artwork: Bool = true,
        compactPresentation: CompactIslandView.CompactPresentationMode = .normal,
        screen: NSScreen? = nil
    ) -> NSSize {
        let h = contentHeight(
            for: state,
            attached: attached,
            dualLine: dualLine,
            artwork: artwork,
            compactPresentation: compactPresentation
        )
        let w: CGFloat
        switch state {
        case .compact:
            if attached {
                w = attachedCompactWidth
            } else {
                w = 350
            }
        case .expanded:
            w = artwork ? 450 : 380
        case .full:
            w = artwork ? 540 : 400
        }
        if attached {
            // On notch screens menuBarHeight covers the top padding need;
            // on non-notch screens it is 0 so we must add verticalPadding
            // explicitly to avoid clipping the expanded content.
            let topExtra = max(menuBarHeight(for: screen), verticalPadding(for: state))
            return NSSize(width: w, height: h + topExtra)
        }
        return NSSize(width: w, height: h + verticalPadding(for: state) + transitionOverflowMargin)
    }

    static func rightClickAction(
        for state: IslandState,
        compactPresentation: CompactIslandView.CompactPresentationMode
    ) -> RightClickAction {
        guard state == .compact else { return .ignore }

        switch compactPresentation {
        case .normal:
            return .collapse
        case .collapsed:
            return .confirmQuit
        }
    }

    static func quitConfirmationMessage(appName: String) -> String {
        "是否要退出\(appName)？"
    }

    private func cycleState() {
        if isAttached, islandState == .compact, compactPresentation == .collapsed {
            compactPresentation = .normal
            resizePanel(for: .compact)
            return
        }
        if isAttached {
            // Attached mode: no SwiftUI animation — it would pull the
            // window away from the screen top. Content is bottom-aligned
            // so it stays visually stable as the NSPanel grows downward.
            switch islandState {
            case .compact: islandState = .expanded
            case .expanded: islandState = .full
            case .full: islandState = .compact
            }
        } else {
            withAnimation(.easeOut(duration: 0.35)) {
                switch islandState {
                case .compact: islandState = .expanded
                case .expanded: islandState = .full
                case .full: islandState = .compact
                }
            }
        }
    }

    private func resizePanel(for state: IslandState) {
        guard let window = NSApp.windows.first(where: { $0 is DynamicIslandPanel }) as? DynamicIslandPanel else { return }
        window.animateResize(to: Self.size(
            for: state,
            attached: isAttached,
            dualLine: appState.dualLineMode,
            artwork: appState.showArtwork,
            compactPresentation: compactPresentation,
            screen: window.screen
        ))
    }

    private func presentQuitConfirmation() {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Lyrisland"
        let alert = NSAlert()
        alert.messageText = Self.quitConfirmationMessage(appName: appName)
        alert.addButton(withTitle: String(localized: "menu.quit"))
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            NSApp.terminate(nil)
        }
    }
}
