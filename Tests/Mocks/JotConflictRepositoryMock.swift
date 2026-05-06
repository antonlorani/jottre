import Foundation
import UIKit

@testable import Jottre

final class JotConflictRepositoryMock: JotConflictRepositoryProtocol {

    private let resolveVersionConflictsProvider:
        @Sendable (_ jotFileInfo: JotFile.Info, _ resolvedVersions: [JotFileVersion]) throws -> Void
    private let getPreviewImageProvider:
        @Sendable (
            _ jotFileInfo: JotFile.Info,
            _ jotFileVersion: JotFileVersion,
            _ userInterfaceStyle: UIUserInterfaceStyle,
            _ displayScale: CGFloat
        ) async -> UIImage?

    init(
        resolveVersionConflictsProvider:
            @Sendable @escaping (_ jotFileInfo: JotFile.Info, _ resolvedVersions: [JotFileVersion]) throws -> Void = {
                _,
                _ in
            },
        getPreviewImageProvider:
            @Sendable @escaping (
                _ jotFileInfo: JotFile.Info,
                _ jotFileVersion: JotFileVersion,
                _ userInterfaceStyle: UIUserInterfaceStyle,
                _ displayScale: CGFloat
            ) async -> UIImage? = { _, _, _, _ in nil }
    ) {
        self.resolveVersionConflictsProvider = resolveVersionConflictsProvider
        self.getPreviewImageProvider = getPreviewImageProvider
    }

    func resolveVersionConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersions: [JotFileVersion]
    ) throws {
        try resolveVersionConflictsProvider(jotFileInfo, resolvedVersions)
    }

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        jotFileVersion: JotFileVersion,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage? {
        await getPreviewImageProvider(jotFileInfo, jotFileVersion, userInterfaceStyle, displayScale)
    }
}
