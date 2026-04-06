import Foundation

enum PlayerKind: String, CaseIterable, Codable {
    case spotify
    case appleMusic

    var bundleIdentifier: String {
        switch self {
        case .spotify:
            "com.spotify.client"
        case .appleMusic:
            "com.apple.Music"
        }
    }
}
