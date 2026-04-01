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

protocol JotsRepositoryProtocol: Sendable {

    func getJotFiles() -> AsyncThrowingStream<[JotFile.Info], Error>

    func shouldShowEnableICloudButton() -> Bool

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage?
}

struct JotsRepository: JotsRepositoryProtocol {

    private let ubiquitousFileService: FileServiceProtocol
    private let jotFileService: JotFileServiceProtocol
    private let jotFilePreviewImageService: JotFilePreviewImageServiceProtocol

    init(
        ubiquitousFileService: FileServiceProtocol,
        jotFileService: JotFileServiceProtocol,
        jotFilePreviewImageService: JotFilePreviewImageServiceProtocol
    ) {
        self.ubiquitousFileService = ubiquitousFileService
        self.jotFileService = jotFileService
        self.jotFilePreviewImageService = jotFilePreviewImageService
    }

    func getJotFiles() -> AsyncThrowingStream<[JotFile.Info], Error> {
        jotFileService
            .documentsDirectoryContents()
            .map { jotFileInfos in
                jotFileInfos.sorted { a, b in
                    (a.modificationDate ?? .distantPast) > (b.modificationDate ?? .distantPast)
                }
            }
            .toAsyncThrowingStream()
    }

    func shouldShowEnableICloudButton() -> Bool {
        !ubiquitousFileService.isEnabled()
    }

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        try jotFileService.duplicate(jotFileInfo: jotFileInfo)
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
