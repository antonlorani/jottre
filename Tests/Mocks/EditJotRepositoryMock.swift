import CoreGraphics
import Foundation
@preconcurrency import PencilKit

@testable import Jottre

final class EditJotRepositoryMock: EditJotRepositoryProtocol {

    private let ubiquitousInfoProvider: @Sendable (_ url: URL) -> UbiquitousInfo?
    private let readDrawingProvider:
        @Sendable (_ jotFileInfo: JotFile.Info) async throws -> (drawing: PKDrawing, width: CGFloat)
    private let writeDrawingProvider: @Sendable (_ jotFileInfo: JotFile.Info, _ drawing: PKDrawing) async throws -> Void
    private let getConflictingVersionsProvider: @Sendable (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]?
    private let duplicateProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info

    init(
        ubiquitousInfoProvider: @Sendable @escaping (_ url: URL) -> UbiquitousInfo? = { _ in nil },
        readDrawingProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info) async throws -> (drawing: PKDrawing, width: CGFloat) = {
                _ in (PKDrawing(), 800)
            },
        writeDrawingProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ drawing: PKDrawing) async throws -> Void = { _, _ in },
        getConflictingVersionsProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) -> [JotFileVersion]? = { _ in
            nil
        },
        duplicateProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info = { jotFileInfo in
            jotFileInfo
        }
    ) {
        self.ubiquitousInfoProvider = ubiquitousInfoProvider
        self.readDrawingProvider = readDrawingProvider
        self.writeDrawingProvider = writeDrawingProvider
        self.getConflictingVersionsProvider = getConflictingVersionsProvider
        self.duplicateProvider = duplicateProvider
    }

    func ubiquitousInfo(url: URL) -> UbiquitousInfo? {
        ubiquitousInfoProvider(url)
    }

    func readDrawing(jotFileInfo: JotFile.Info) async throws -> (drawing: PKDrawing, width: CGFloat) {
        try await readDrawingProvider(jotFileInfo)
    }

    func writeDrawing(jotFileInfo: JotFile.Info, drawing: PKDrawing) async throws {
        try await writeDrawingProvider(jotFileInfo, drawing)
    }

    func getConflictingVersions(jotFileInfo: JotFile.Info) -> [JotFileVersion]? {
        getConflictingVersionsProvider(jotFileInfo)
    }

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        try duplicateProvider(jotFileInfo)
    }
}
