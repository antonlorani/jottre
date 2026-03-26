protocol JotsRepositoryProtocol {

    func getJotFiles() throws -> AsyncThrowingStream<[JotFile.Info], Error>
}

struct JotsRepository: JotsRepositoryProtocol {

    private let jotFileService: JotFileServiceProtocol
    private let fileService: FileServiceProtocol

    init(
        jotFileService: JotFileServiceProtocol,
        fileService: FileServiceProtocol
    ) {
        self.jotFileService = jotFileService
        self.fileService = fileService
    }

    func getJotFiles() throws -> AsyncThrowingStream<[JotFile.Info], Error> {
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
