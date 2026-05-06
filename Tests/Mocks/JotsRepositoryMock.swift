import Foundation
import UIKit

@testable import Jottre

final class JotsRepositoryMock: JotsRepositoryProtocol {

    private let getJotFilesProvider: @Sendable () -> AsyncThrowingStream<[JotFile.Info], Error>
    private let shouldShowEnableICloudButtonProvider: @Sendable () -> Bool
    private let duplicateProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info
    private let downloadProvider: @Sendable (_ jotFileInfo: JotFile.Info) throws -> Void
    private let getPreviewImageProvider:
        @Sendable (
            _ jotFileInfo: JotFile.Info,
            _ userInterfaceStyle: UIUserInterfaceStyle,
            _ displayScale: CGFloat
        ) async -> UIImage?
    private let supportsMultipleScenesProvider: @MainActor @Sendable () -> Bool
    private let isIPadOSProvider: @MainActor @Sendable () -> Bool

    init(
        getJotFilesProvider: @Sendable @escaping () -> AsyncThrowingStream<[JotFile.Info], Error> = {
            AsyncThrowingStream { $0.finish() }
        },
        shouldShowEnableICloudButtonProvider: @Sendable @escaping () -> Bool = { false },
        duplicateProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> JotFile.Info = { $0 },
        downloadProvider: @Sendable @escaping (_ jotFileInfo: JotFile.Info) throws -> Void = { _ in },
        getPreviewImageProvider:
            @Sendable @escaping (
                _ jotFileInfo: JotFile.Info,
                _ userInterfaceStyle: UIUserInterfaceStyle,
                _ displayScale: CGFloat
            ) async -> UIImage? = { _, _, _ in nil },
        supportsMultipleScenesProvider: @MainActor @Sendable @escaping () -> Bool = { false },
        isIPadOSProvider: @MainActor @Sendable @escaping () -> Bool = { false }
    ) {
        self.getJotFilesProvider = getJotFilesProvider
        self.shouldShowEnableICloudButtonProvider = shouldShowEnableICloudButtonProvider
        self.duplicateProvider = duplicateProvider
        self.downloadProvider = downloadProvider
        self.getPreviewImageProvider = getPreviewImageProvider
        self.supportsMultipleScenesProvider = supportsMultipleScenesProvider
        self.isIPadOSProvider = isIPadOSProvider
    }

    func getJotFiles() -> AsyncThrowingStream<[JotFile.Info], Error> {
        getJotFilesProvider()
    }

    func shouldShowEnableICloudButton() -> Bool {
        shouldShowEnableICloudButtonProvider()
    }

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        try duplicateProvider(jotFileInfo)
    }

    func download(jotFileInfo: JotFile.Info) throws {
        try downloadProvider(jotFileInfo)
    }

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage? {
        await getPreviewImageProvider(jotFileInfo, userInterfaceStyle, displayScale)
    }

    @MainActor
    func supportsMultipleScenes() -> Bool {
        supportsMultipleScenesProvider()
    }

    @MainActor
    func isIPadOS() -> Bool {
        isIPadOSProvider()
    }
}
