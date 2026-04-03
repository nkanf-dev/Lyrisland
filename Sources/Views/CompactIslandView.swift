import SwiftUI

/// Compact state: single-line song title + playing indicator.
struct CompactIslandView: View {
    @ObservedObject var syncEngine: PlaybackSyncEngine
    @ObservedObject var lyricsManager: LyricsManager

    var body: some View {
        HStack(spacing: 10) {
            // Playing indicator bars
            if syncEngine.isPlaying {
                PlayingIndicator()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "pause.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Current lyric line or track title placeholder
            if let lyrics = lyricsManager.currentLyrics,
               let idx = lyrics.lineIndex(at: syncEngine.interpolatedPosition) {
                Text(lyrics.lines[idx].text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .transition(.push(from: .bottom))
                    .id(idx)
            } else {
                Text("♪ Waiting for lyrics…")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
