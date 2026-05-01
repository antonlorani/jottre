import Foundation
import UIKit

@testable import Jottre

final class JotFilePreviewImageServiceMock: JotFilePreviewImageServiceProtocol {

    private let getPreviewImageDataProvider:
        @Sendable (
            _ jotFileInfo: JotFile.Info,
            _ userInterfaceStyle: UIUserInterfaceStyle,
            _ displayScale: CGFloat
        ) async throws -> Data

    init(
        getPreviewImageDataProvider:
            @Sendable @escaping (
                _ jotFileInfo: JotFile.Info,
                _ userInterfaceStyle: UIUserInterfaceStyle,
                _ displayScale: CGFloat
            ) async throws -> Data = { _, _, _ in Data() }
    ) {
        self.getPreviewImageDataProvider = getPreviewImageDataProvider
    }

    func getPreviewImageData(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async throws -> Data {
        try await getPreviewImageDataProvider(jotFileInfo, userInterfaceStyle, displayScale)
    }
}
