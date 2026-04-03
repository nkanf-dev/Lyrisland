import SwiftUI

/// Expanded state: shows the current lyric line with surrounding context.
struct ExpandedIslandView: View {
    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager

    private let visibleLineCount = 5

    var body: some View {
        VStack(spacing: 4) {
            if let lyrics = lyricsManager.currentLyrics {
                let currentIdx = lyrics.lineIndex(at: syncEngine.position) ?? 0
                let range = contextRange(around: currentIdx, total: lyrics.lines.count)

                ForEach(lyrics.lines[range]) { line in
                    let isCurrent = line.id == lyrics.lines[currentIdx].id
                    if isCurrent {
                        MarqueeText(
                            text: line.text,
                            font: .system(size: 15, weight: .bold),
                            color: .white
                        )
                        .frame(height: 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text(line.text)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.35))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .blur(radius: 0.5)
                    }
                }
            } else {
                Text("lyrics.no_lyrics")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .animation(.easeInOut(duration: 0.25), value: lyricsManager.currentLyrics?.lineIndex(at: syncEngine.position))
    }

    private func contextRange(around index: Int, total: Int) -> ClosedRange<Int> {
        let half = visibleLineCount / 2
        let start = max(0, index - half)
        let end = min(total - 1, start + visibleLineCount - 1)
        let adjustedStart = max(0, end - visibleLineCount + 1)
        return adjustedStart ... end
    }
}
