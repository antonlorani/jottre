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
