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

protocol CloudMigrationRepositoryProtocol: Sendable {

    func getJotFiles() -> AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error>

    func moveJotFile(
        jotFileInfo: JotFile.Info,
        shouldBecomeUbiquitous: Bool
    ) async throws

    func getShouldShowCloudMigration() -> Bool

    func markCloudMigrationPageDone()

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage?
}

struct CloudMigrationRepository: CloudMigrationRepositoryProtocol {

    private let ubiquitousFileService: FileServiceProtocol
    private let jotFileService: JotFileServiceProtocol
    private let jotFilePreviewImageService: JotFilePreviewImageServiceProtocol
    private let defaultsService: DefaultsServiceProtocol

    init(
        ubiquitousFileService: FileServiceProtocol,
        jotFileService: JotFileServiceProtocol,
        jotFilePreviewImageService: JotFilePreviewImageServiceProtocol,
        defaultsService: DefaultsServiceProtocol
    ) {
        self.ubiquitousFileService = ubiquitousFileService
        self.jotFileService = jotFileService
        self.jotFilePreviewImageService = jotFilePreviewImageService
        self.defaultsService = defaultsService
    }

    func getJotFiles() -> AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error> {
        jotFileService
            .documentsDirectoryContents()
            .map { jotFileInfos in
                jotFileInfos
                    .sorted { lhs, rhs in
                        if (lhs.ubiquitousInfo != nil) != (rhs.ubiquitousInfo != nil) {
                            return lhs.ubiquitousInfo == nil
                        }
                        return lhs.modificationDate ?? .distantPast > rhs.modificationDate ?? .distantPast
                    }
                    .map(CloudMigrationJotBusinessModel.init)
            }
            .toAsyncThrowingStream()
    }

    func moveJotFile(
        jotFileInfo: JotFile.Info,
        shouldBecomeUbiquitous: Bool
    ) async throws {
        try await jotFileService.move(
            jotFileInfo: jotFileInfo,
            shouldBecomeUbiquitous: shouldBecomeUbiquitous
        )
    }

    func getShouldShowCloudMigration() -> Bool {
        if defaultsService.getValue(.hasDoneCloudMigration) == true {
            return false
        }

        let isUbiquitousFileServiceEnabled = ubiquitousFileService.isEnabled()
        if let wasICloudEnabled = defaultsService.getValue(.isICloudEnabled) {
            return wasICloudEnabled != isUbiquitousFileServiceEnabled
        }

        if !isUbiquitousFileServiceEnabled {
            defaultsService.set(.isICloudEnabled, value: false)
        }

        return false
    }

    func markCloudMigrationPageDone() {
        defaultsService.set(.hasDoneCloudMigration, value: true)
    }

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage? {
        do {
            let imageData = try await jotFilePreviewImageService.getPreviewImageData(
                jotFileInfo: jotFileInfo,
                userInterfaceStyle: userInterfaceStyle,
                displayScale: displayScale
            )
            return UIImage(data: imageData)
        } catch {
            return nil
        }
    }
}
