import SwiftUI

/// Expanded state: shows the current lyric line with surrounding context.
/// Uses push transitions (like Compact mode) for smooth line-by-line scrolling.
struct ExpandedIslandView: View {
    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager
    @ObservedObject var appState: AppState
    @Environment(\.rootFontSize) private var rootFontSize

    private let visibleLineCount = 5

    var body: some View {
        VStack(spacing: 4) {
            // Track info header
            if let title = syncEngine.trackTitle {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: .rem(0.6875, root: rootFontSize), weight: .semibold))
                        .foregroundStyle(appState.contentColor.opacity(0.5))
                        .lineLimit(1)
                    if let artist = syncEngine.trackArtist {
                        Text("—")
                            .font(.system(size: .rem(0.6875, root: rootFontSize)))
                            .foregroundStyle(appState.contentColor.opacity(0.3))
                        Text(artist)
                            .font(.system(size: .rem(0.6875, root: rootFontSize)))
                            .foregroundStyle(appState.contentColor.opacity(0.4))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .background(appState.contentColor.opacity(0.15))

            if let lyrics = lyricsManager.currentLyrics {
                let currentIdx = syncEngine.currentLineIndex ?? 0
                let range = contextRange(around: currentIdx, total: lyrics.lines.count)

                ForEach(lyrics.lines[range]) { line in
                    ExpandedLyricLineRow(
                        text: line.text,
                        isCurrent: line.id == currentIdx,
                        distance: abs(line.id - currentIdx),
                        rootFontSize: rootFontSize,
                        contentColor: appState.contentColor,
                        alignment: appState.resolvedLyricsAlignment,
                        lineDuration: lineDuration(for: currentIdx, in: lyrics)
                    )
                    .environment(\.layoutDirection, line.text.isRTL ? .rightToLeft : .leftToRight)
                    .transition(.push(from: .bottom))
                }
            } else {
                Text("lyrics.no_lyrics")
                    .font(.system(size: .rem(0.8125, root: rootFontSize)))
                    .foregroundStyle(appState.contentColor.opacity(0.4))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.smooth(duration: 0.35), value: syncEngine.currentLineIndex)
    }

    private func contextRange(around index: Int, total: Int) -> ClosedRange<Int> {
        let half = visibleLineCount / 2
        let start = max(0, index - half)
        let end = min(total - 1, start + visibleLineCount - 1)
        let adjustedStart = max(0, end - visibleLineCount + 1)
        return adjustedStart ... end
    }

    private func opacityFor(distance: Int) -> Double {
        switch distance {
        case 1: 0.55
        case 2: 0.3
        default: 0.15
        }
    }

    private func blurFor(distance: Int) -> CGFloat {
        switch distance {
        case 1: 0
        case 2: 0.3
        default: 0.8
        }
    }

    private func lineDuration(for index: Int, in lyrics: SyncedLyrics) -> Double? {
        guard index + 1 < lyrics.lines.count else { return nil }
        return lyrics.lines[index + 1].time - lyrics.lines[index].time
    }
}

private struct ExpandedLyricLineRow: View, Equatable {
    let text: String
    let isCurrent: Bool
    let distance: Int
    let rootFontSize: CGFloat
    let contentColor: Color
    let alignment: Alignment
    let lineDuration: Double?

    var body: some View {
        Group {
            if isCurrent {
                MarqueeText(
                    text: text,
                    font: .system(size: .rem(0.9375, root: rootFontSize), weight: .bold),
                    color: contentColor,
                    loops: false,
                    lineDuration: lineDuration
                )
            } else {
                Text(text)
                    .font(.system(
                        size: .rem(distance == 1 ? 0.8125 : 0.75, root: rootFontSize),
                        weight: distance == 1 ? .medium : .regular
                    ))
                    .foregroundStyle(contentColor.opacity(opacityFor(distance: distance)))
                    .lineLimit(1)
                    .blur(radius: blurFor(distance: distance))
            }
        }
        .frame(height: 20)
        .frame(maxWidth: .infinity, alignment: alignment)
    }

    private func opacityFor(distance: Int) -> Double {
        switch distance {
        case 1: 0.55
        case 2: 0.3
        default: 0.15
        }
    }

    private func blurFor(distance: Int) -> CGFloat {
        switch distance {
        case 1: 0
        case 2: 0.3
        default: 0.8
        }
    }
}
