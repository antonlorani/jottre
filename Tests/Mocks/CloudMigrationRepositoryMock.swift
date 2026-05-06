import Foundation
import UIKit

@testable import Jottre

final class CloudMigrationRepositoryMock: CloudMigrationRepositoryProtocol {

    private let getJotFilesProvider: @Sendable () -> AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error>
    private let moveJotFileProvider:
        @Sendable (_ jotFileInfo: JotFile.Info, _ shouldBecomeUbiquitous: Bool) async throws -> Void
    private let getShouldShowCloudMigrationProvider: @Sendable () -> Bool
    private let markCloudMigrationPageDoneProvider: @Sendable () -> Void
    private let getPreviewImageProvider:
        @Sendable (
            _ jotFileInfo: JotFile.Info,
            _ userInterfaceStyle: UIUserInterfaceStyle,
            _ displayScale: CGFloat
        ) async -> UIImage?

    init(
        getJotFilesProvider:
            @Sendable @escaping () -> AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error> = {
                AsyncThrowingStream { $0.finish() }
            },
        moveJotFileProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ shouldBecomeUbiquitous: Bool) async throws -> Void = {
                _,
                _ in
            },
        getShouldShowCloudMigrationProvider: @Sendable @escaping () -> Bool = { false },
        markCloudMigrationPageDoneProvider: @Sendable @escaping () -> Void = {},
        getPreviewImageProvider:
            @Sendable @escaping (
                _ jotFileInfo: JotFile.Info,
                _ userInterfaceStyle: UIUserInterfaceStyle,
                _ displayScale: CGFloat
            ) async -> UIImage? = { _, _, _ in nil }
    ) {
        self.getJotFilesProvider = getJotFilesProvider
        self.moveJotFileProvider = moveJotFileProvider
        self.getShouldShowCloudMigrationProvider = getShouldShowCloudMigrationProvider
        self.markCloudMigrationPageDoneProvider = markCloudMigrationPageDoneProvider
        self.getPreviewImageProvider = getPreviewImageProvider
    }

    func getJotFiles() -> AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error> {
        getJotFilesProvider()
    }

    func moveJotFile(jotFileInfo: JotFile.Info, shouldBecomeUbiquitous: Bool) async throws {
        try await moveJotFileProvider(jotFileInfo, shouldBecomeUbiquitous)
    }

    func getShouldShowCloudMigration() -> Bool {
        getShouldShowCloudMigrationProvider()
    }

    func markCloudMigrationPageDone() {
        markCloudMigrationPageDoneProvider()
    }

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage? {
        await getPreviewImageProvider(jotFileInfo, userInterfaceStyle, displayScale)
    }
}
