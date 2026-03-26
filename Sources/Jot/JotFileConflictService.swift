protocol JotFileConflictServiceProtocol: Sendable {

    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]?

    func resolveConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersion: JotFileVersion?
    ) throws
}

struct JotFileConflictService: JotFileConflictServiceProtocol {

    private let fileService: FileServiceProtocol
    private let fileConflictService: FileConflictServiceProtocol

    init(
        fileService: FileServiceProtocol,
        fileConflictService: FileConflictServiceProtocol
    ) {
        self.fileService = fileService
        self.fileConflictService = fileConflictService
    }

    func getUnresolvedConflicts(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        guard let fileVersions = fileConflictService.getUnresolvedConflicts(fileURL: jotFileInfo.url),
            !fileVersions.isEmpty
        else {
            return nil
        }
        return
            fileVersions
            .map { fileVersion in
                JotFileVersion(
                    localizedNameOfSavingComputer: fileVersion.localizedNameOfSavingComputer,
                    info: JotFile.Info(
                        url: fileVersion.url,
                        name: fileVersion.localizedName ?? fileVersion.url.deletingPathExtension().lastPathComponent,
                        modificationDate: fileVersion.modificationDate
                    )
                )
            }
    }

    func resolveConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersion: JotFileVersion?
    ) throws {
        try fileConflictService.resolveConflicts(
            fileURL: jotFileInfo.url,
            resolvedVersion: resolvedVersion?.info.url
        )
    }
}
