import Foundation

@testable import Jottre

final class JotFileServiceMock: JotFileServiceProtocol {

    private let documentsDirectoryContentsProvider: @Sendable () -> AsyncThrowingStream<[JotFile.Info], Error>
    private let readJotFileProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> JotFile
    private let writeProvider: @Sendable (_ jotFile: JotFile) throws -> Void
    private let duplicateProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info
    private let renameProvider: @Sendable (_ jotFileInfo: JotFile.Info, _ newName: String) throws -> JotFile.Info
    private let removeProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> Void
    private let moveProvider:
        @Sendable (_ jotFileInfo: JotFile.Info, _ shouldBecomeUbiquitous: Bool) async throws -> Void

    init(
        documentsDirectoryContentsProvider: @Sendable @escaping () -> AsyncThrowingStream<[JotFile.Info], Error> = {
            AsyncThrowingStream { $0.finish() }
        },
        readJotFileProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> JotFile = { info in
            JotFile(info: info, jot: Jot.makeEmpty())
        },
        writeProvider: @Sendable @escaping (_ jotFile: JotFile) throws -> Void = { _ in },
        duplicateProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info = { $0 },
        renameProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ newName: String) throws -> JotFile.Info = {
            info,
            _ in info
        },
        removeProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> Void = { _ in },
        moveProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ shouldBecomeUbiquitous: Bool) async throws -> Void = {
                _,
                _ in
            }
    ) {
        self.documentsDirectoryContentsProvider = documentsDirectoryContentsProvider
        self.readJotFileProvider = readJotFileProvider
        self.writeProvider = writeProvider
        self.duplicateProvider = duplicateProvider
        self.renameProvider = renameProvider
        self.removeProvider = removeProvider
        self.moveProvider = moveProvider
    }

    func documentsDirectoryContents() -> AsyncThrowingStream<[JotFile.Info], Error> {
        documentsDirectoryContentsProvider()
    }
    func readJotFile(jotFileInfo: JotFile.Info) throws -> JotFile {
        try readJotFileProvider(jotFileInfo)
    }
    func write(jotFile: JotFile) throws {
        try writeProvider(jotFile)
    }
    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        try duplicateProvider(jotFileInfo)
    }
    func rename(jotFileInfo: JotFile.Info, newName: String) throws -> JotFile.Info {
        try renameProvider(jotFileInfo, newName)
    }
    func remove(jotFileInfo: JotFile.Info) throws {
        try removeProvider(jotFileInfo)
    }
    func move(jotFileInfo: JotFile.Info, shouldBecomeUbiquitous: Bool) async throws {
        try await moveProvider(jotFileInfo, shouldBecomeUbiquitous)
    }
}
