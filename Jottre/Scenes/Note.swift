import PencilKit
import Foundation

struct Note: Codable {
    let drawing: PKDrawing
    let width: CGFloat
    let version: Int
    let lastModified: Double

    init(drawing: PKDrawing, width: CGFloat = 1200, version: Int = 1, lastModified: Double = Date().timeIntervalSince1970) {
        self.drawing = drawing
        self.width = width
        self.version = version
        self.lastModified = lastModified
    }
}

struct NoteBusinessModel {

    let name: String
    private let note: Note

    init(name: String, note: Note) {
        self.name = name
        self.note = note
    }

    func asNote() -> Note {
        note
    }
}
