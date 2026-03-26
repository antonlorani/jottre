import PencilKit

protocol EditJotRepositoryProtocol {

    func readDrawing(jotFile: JotFileBusinessModel) throws -> (drawing: PKDrawing, width: CGFloat)
    func getUnresolvedConflicts(jotFile: JotFileBusinessModel) -> [JotFileVersion]?
}

struct EditJotRepository: EditJotRepositoryProtocol {

    private let jotFileService: JotFileServiceProtocol
    private let jotFileConflictService: JotFileConflictServiceProtocol

    init(
        jotFileService: JotFileServiceProtocol,
        jotFileConflictService: JotFileConflictServiceProtocol
    ) {
        self.jotFileService = jotFileService
        self.jotFileConflictService = jotFileConflictService
    }

    func readDrawing(jotFile: JotFileBusinessModel) throws -> (drawing: PKDrawing, width: CGFloat) {
        let file = try jotFileService.readJotFile(info: jotFile.toFileInfo())
        let drawing = try PKDrawing(data: file.jot.drawing)
        return (
            drawing: drawing,
            width: file.jot.width
        )
    }

    func getUnresolvedConflicts(jotFile: JotFileBusinessModel) -> [JotFileVersion]? {
        jotFileConflictService.getUnresolvedConflicts(info: jotFile.toFileInfo())
    }
}
