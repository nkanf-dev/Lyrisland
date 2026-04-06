import SwiftUI

/// Animated sound bars indicator (like Spotify's playing animation).
struct PlayingIndicator: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            HStack(spacing: 2) {
                ForEach(0 ..< 3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.green)
                        .frame(width: 3)
                        .scaleEffect(
                            y: Self.barScale(
                                at: timeline.date.timeIntervalSinceReferenceDate,
                                index: index
                            ),
                            anchor: .bottom
                        )
                }
            }
        }
    }

    static func barScale(at time: TimeInterval, index: Int) -> CGFloat {
        let phase = time * 5.2 + Double(index) * 0.9
        let normalized = (sin(phase) + sin(phase * 1.7 + 0.6)) * 0.25 + 0.5
        return max(0.3, min(1.0, CGFloat(normalized)))
    }
}
