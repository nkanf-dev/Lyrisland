import SwiftUI

/// Auto-scrolling lyrics list that tracks the current playback position.
struct LyricsScrollView: View {
    let lyrics: SyncedLyrics
    @ObservedObject var syncEngine: PlaybackSyncEngine

    private var currentIndex: Int {
        lyrics.lineIndex(at: syncEngine.interpolatedPosition) ?? 0
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 6) {
                    Spacer(minLength: 40)

                    ForEach(lyrics.lines) { line in
                        let isCurrent = line.id == currentIndex

                        VStack(spacing: 2) {
                            Text(line.text)
                                .font(.system(size: isCurrent ? 15 : 12, weight: isCurrent ? .bold : .regular))
                                .foregroundStyle(isCurrent ? .white : .white.opacity(0.35))
                                .blur(radius: blurAmount(for: line.id))

                            if let translation = line.translation {
                                Text(translation)
                                    .font(.system(size: 11))
                                    .foregroundStyle(isCurrent ? .white.opacity(0.7) : .white.opacity(0.2))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .id(line.id)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: currentIndex) { _, newIdx in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIdx, anchor: .center)
                }
            }
        }
    }

    private func blurAmount(for lineId: Int) -> CGFloat {
        let distance = abs(lineId - currentIndex)
        if distance == 0 { return 0 }
        if distance <= 2 { return 0.3 }
        return 0.8
    }
}
