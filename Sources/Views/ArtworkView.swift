import SwiftUI

/// Displays album artwork with two-tier caching (memory + disk), keyed by track ID.
struct ArtworkView: View {
    let trackId: String?
    let artworkURL: URL?
    let size: CGFloat

    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
        .task(id: trackId) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let trackId,
              let url = artworkURL
        else {
            image = nil
            return
        }
        image = await ArtworkCache.shared.image(for: trackId, url: url)
    }
}
