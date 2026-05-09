/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

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
