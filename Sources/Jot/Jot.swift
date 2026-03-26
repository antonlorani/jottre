import Foundation

struct Jot: Codable, Sendable {
    let drawing: Data
    let width: CGFloat
    // NOTE: Kept for backwards compatibility, ``JotFile.Info.modificationDate`` should be used instead.
    let lastModified: Double?
    // NOTE: Kept optional for backwards compatibility.
    let version: Int?
}
