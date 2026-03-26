protocol JotFileConflictServiceProtocol: Sendable {

    func getUnresolvedConflicts(info: JotFile.Info) -> [JotFileVersion]?

    func resolveConflicts(
        info: JotFile.Info,
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

    func getUnresolvedConflicts(info: JotFile.Info) -> [JotFileVersion]? {
        guard let fileVersions = fileConflictService.getUnresolvedConflicts(fileURL: info.url),
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
        info: JotFile.Info,
        resolvedVersion: JotFileVersion?
    ) throws {
        try fileConflictService.resolveConflicts(
            fileURL: info.url,
            resolvedVersion: resolvedVersion?.info.url
        )
    }
}
