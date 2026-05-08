import Foundation

@testable import Jottre

final class CreateJotRepositoryMock: CreateJotRepositoryProtocol {

    private let createJotProvider: @Sendable (_ name: String) async throws -> JotFile.Info

    init(
        createJotProvider:
            @Sendable @escaping (_ name: String) async throws -> JotFile.Info = { name in
                JotFile.Info(
                    url: URL(fileURLWithPath: "/tmp/\(name).jot"),
                    name: name,
                    modificationDate: nil,
                    ubiquitousInfo: nil
                )
            }
    ) {
        self.createJotProvider = createJotProvider
    }

    func createJot(name: String) async throws -> JotFile.Info {
        try await createJotProvider(name)
    }
}

final class DeleteJotRepositoryMock: DeleteJotRepositoryProtocol {

    private let deleteJotProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> Void

    init(
        deleteJotProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> Void = { _ in }
    ) {
        self.deleteJotProvider = deleteJotProvider
    }

    func deleteJot(jotFileInfo: JotFile.Info) throws {
        try deleteJotProvider(jotFileInfo)
    }
}

final class RenameJotRepositoryMock: RenameJotRepositoryProtocol {

    private let renameProvider: (_ jotFileInfo: JotFile.Info, _ newName: String) throws -> JotFile.Info

    init(
        renameProvider:
            @escaping (_ jotFileInfo: JotFile.Info, _ newName: String) throws -> JotFile.Info = { jotFileInfo, name in
                JotFile.Info(
                    url: jotFileInfo.url.deletingLastPathComponent().appendingPathComponent("\(name).jot"),
                    name: name,
                    modificationDate: nil,
                    ubiquitousInfo: nil
                )
            }
    ) {
        self.renameProvider = renameProvider
    }

    func rename(jotFileInfo: JotFile.Info, newName: String) throws -> JotFile.Info {
        try renameProvider(jotFileInfo, newName)
    }
}

final class ShareJotRepositoryMock: ShareJotRepositoryProtocol {

    private let exportJotProvider: @Sendable (_ jotFileInfo: JotFile.Info, _ format: ShareFormat) async throws -> URL

    init(
        exportJotProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ format: ShareFormat) async throws -> URL = { _, _ in
                URL(fileURLWithPath: "/tmp/share")
            }
    ) {
        self.exportJotProvider = exportJotProvider
    }

    func exportJot(jotFileInfo: JotFile.Info, format: ShareFormat) async throws -> URL {
        try await exportJotProvider(jotFileInfo, format)
    }
}
