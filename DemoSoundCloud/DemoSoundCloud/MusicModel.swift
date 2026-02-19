
import Foundation
// MARK: - Models

struct MusicModel: Codable {
    let musicName: String
    let musicImage: String
    let musicUrl: String
    var isFree: Bool = false
    var fileName: String
    var musicMode: MusicMode
}

enum MusicMode: String, Codable {
    case youtubeMode
    case defaultMode
    case localFileMode
}
