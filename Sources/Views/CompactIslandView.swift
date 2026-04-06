import SwiftUI

/// Compact state: single-line song title + playing indicator.
struct CompactIslandView: View {
    enum CompactPresentationMode: Equatable {
        case normal
        case collapsed
    }

    enum LayoutMetrics {
        static let topRowArtworkSize: CGFloat = 18
        static let topRowIndicatorWidth: CGFloat = 16
        static let topRowHeight: CGFloat = 14
        static let lyricRowMinHeight: CGFloat = 6
        static let verticalSpacing: CGFloat = 4
    }

    static let prefersDualLineLyricsInCompact = false

    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager
    @ObservedObject var appState: AppState
    let attached: Bool
    let presentation: CompactPresentationMode
    @Environment(\.rootFontSize) private var rootFontSize

    var body: some View {
        Group {
            if attached {
                if presentation == .normal {
                    lyricRow
                }
            } else {
                HStack(spacing: 10) {
                    playbackStatusSlot
                    lyricRow
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var playbackStatusSlot: some View {
        if syncEngine.isPlaying {
            PlayingIndicator()
                .frame(width: LayoutMetrics.topRowIndicatorWidth, height: LayoutMetrics.topRowArtworkSize)
        } else {
            Image(systemName: statusIcon)
                .font(.system(size: .rem(0.625, root: rootFontSize)))
                .foregroundStyle(appState.contentColor.opacity(0.6))
                .frame(width: LayoutMetrics.topRowIndicatorWidth)
        }
    }

    private var lyricRow: some View {
        MarqueeText(
            text: displayText,
            font: .system(size: .rem(0.8125, root: rootFontSize), weight: .medium),
            color: displayTextOpacity,
            loops: false,
            lineDuration: currentLineDuration
        )
        .transition(.push(from: .bottom).combined(with: .opacity))
        .id(currentLineIndex ?? -1)
        .animation(.smooth(duration: 0.35), value: currentLineIndex)
        .frame(maxWidth: .infinity, minHeight: LayoutMetrics.lyricRowMinHeight, alignment: attached ? .center : appState.resolvedLyricsAlignment)
        .multilineTextAlignment(attached ? .center : .leading)
        .environment(\.layoutDirection, displayText.isRTL ? .rightToLeft : .leftToRight)
    }

    private var statusIcon: String {
        if !syncEngine.isPlaying, syncEngine.currentTrackId == nil {
            return "antenna.radiowaves.left.and.right.slash" // Not connected
        }
        return "pause.fill"
    }

    private var currentLineIndex: Int? {
        syncEngine.currentLineIndex
    }

    private var displayText: String {
        // Has lyrics loaded
        if let lyrics = lyricsManager.currentLyrics {
            if let idx = currentLineIndex {
                return lyrics.lines[idx].text
            }
            // Before first line — lyrics are loaded but haven't started yet
            return "♪"
        }

        // Loading lyrics
        if lyricsManager.isLoading {
            return String(localized: "lyrics.loading")
        }

        // Playing but no lyrics found
        if syncEngine.isPlaying {
            return String(localized: "lyrics.not_available")
        }

        // Paused with a known position (Spotify running but paused)
        if syncEngine.position > 0 {
            return String(localized: "lyrics.paused")
        }

        // Spotify not running or no track
        return String(localized: "lyrics.play_to_start")
    }

    private var displayTextOpacity: Color {
        if lyricsManager.currentLyrics != nil, currentLineIndex != nil {
            return appState.contentColor
        }
        return appState.contentColor.opacity(0.5)
    }

    private var currentLineDuration: Double? {
        guard let lyrics = lyricsManager.currentLyrics, let idx = currentLineIndex else { return nil }
        return lineDuration(for: idx, in: lyrics)
    }

    private func lineDuration(for index: Int, in lyrics: SyncedLyrics) -> Double? {
        guard index + 1 < lyrics.lines.count else { return nil }
        return lyrics.lines[index + 1].time - lyrics.lines[index].time
    }
}
