import PencilKit

protocol EditJotRepositoryProtocol {

    func readDrawing(jotFile: JotFileBusinessModel) throws -> (drawing: PKDrawing, width: CGFloat)
}

struct EditJotRepository: EditJotRepositoryProtocol {

    private let jotFileService: JotFileServiceProtocol

    init(jotFileService: JotFileServiceProtocol) {
        self.jotFileService = jotFileService
    }

    func readDrawing(jotFile: JotFileBusinessModel) throws -> (drawing: PKDrawing, width: CGFloat) {
        let file = try jotFileService.readJotFile(info: jotFile.toFileInfo())
        let drawing = try PKDrawing(data: file.jot.drawing)
        return (
            drawing: drawing,
            width: file.jot.width
        )
    }
}
