import PencilKit

protocol EditJotRepositoryProtocol {

    func readDrawing(jotFileInfo: JotFile.Info) throws -> (drawing: PKDrawing, width: CGFloat)
    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]?
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

    func readDrawing(jotFileInfo: JotFile.Info) throws -> (drawing: PKDrawing, width: CGFloat) {
        let file = try jotFileService.readJotFile(jotFileInfo: jotFileInfo)
        let drawing = try PKDrawing(data: file.jot.drawing)
        return (
            drawing: drawing,
            width: file.jot.width
        )
    }

    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        jotFileConflictService.getUnresolvedConflicts(jotFileInfo: jotFileInfo)
    }
}
