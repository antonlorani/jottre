struct JotFileBusinessModel: Sendable {
    let name: String

    private let jotFileInfo: JotFile.Info

    init(jotFileInfo: JotFile.Info) {
        name = jotFileInfo.name
        self.jotFileInfo = jotFileInfo
    }

    func toFileInfo() -> JotFile.Info {
        jotFileInfo
    }
}

protocol NotesRepositoryProtocol {

    func getJotFiles() throws -> AsyncThrowingStream<[JotFileBusinessModel], Error>
}

struct NotesRepository: NotesRepositoryProtocol {

    private let jotFileService: JotFileServiceProtocol
    private let fileService: FileServiceProtocol

    init(
        jotFileService: JotFileServiceProtocol,
        fileService: FileServiceProtocol
    ) {
        self.jotFileService = jotFileService
        self.fileService = fileService
    }

    func getJotFiles() throws -> AsyncThrowingStream<[JotFileBusinessModel], Error> {
        guard let directory = try fileService.localDocumentsDirectory() else {
            return AsyncThrowingStream { continuation in
                continuation.yield([])
                continuation.finish()
            }
        }

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await _ in fileService.directoryChanges(directory: directory) {
                        let jotFiles =
                            try jotFileService
                            .listContents(directory: directory)
                            .map { JotFileBusinessModel(jotFileInfo: $0) }
                        continuation.yield(jotFiles)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
