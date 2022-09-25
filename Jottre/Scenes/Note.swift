import PencilKit
import Foundation

struct Note: Codable {
    let drawing: PKDrawing
    let width: CGFloat

    init(drawing: PKDrawing, width: CGFloat = 1200) {
        self.drawing = drawing
        self.width = width
    }
}

struct NoteBusinessModel {

    let name: String
    
    private let note: Note
    private let file: File

    init(
        file: File,
        note: Note
    ) {
        name = file.name
        self.file = file
        self.note = note
    }

    func asNote() -> Note {
        note
    }

    func asFile() -> File {
        file
    }
}
