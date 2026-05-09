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
