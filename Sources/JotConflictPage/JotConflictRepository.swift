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

import UIKit

protocol JotConflictRepositoryProtocol: Sendable {

    func resolveVersionConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersions: [JotFileVersion]
    ) throws

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        jotFileVersion: JotFileVersion,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage?
}

struct JotConflictRepository: JotConflictRepositoryProtocol {

    private let jotFileConflictService: JotFileConflictServiceProtocol
    private let jotFilePreviewImageService: JotFilePreviewImageServiceProtocol

    init(
        jotFileConflictService: JotFileConflictServiceProtocol,
        jotFilePreviewImageService: JotFilePreviewImageServiceProtocol
    ) {
        self.jotFileConflictService = jotFileConflictService
        self.jotFilePreviewImageService = jotFilePreviewImageService
    }

    func resolveVersionConflicts(
        jotFileInfo: JotFile.Info,
        resolvedVersions: [JotFileVersion]
    ) throws {
        try jotFileConflictService.resolveVersionConflicts(
            jotFileInfo: jotFileInfo,
            resolvedVersions: resolvedVersions
        )
    }

    func getPreviewImage(
        jotFileInfo: JotFile.Info,
        jotFileVersion: JotFileVersion,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async -> UIImage? {
        do {
            let readableVersionFileInfo: JotFile.Info
            let tmpURL: URL?

            if let tmpInfo = try jotFileConflictService.copyVersionToTemporary(
                jotFileInfo: jotFileInfo,
                jotFileVersion: jotFileVersion
            ) {
                readableVersionFileInfo = tmpInfo
                tmpURL = tmpInfo.url
            } else {
                readableVersionFileInfo = jotFileInfo
                tmpURL = nil
            }

            defer {
                if let tmpURL {
                    try? FileManager.default.removeItem(at: tmpURL)
                }
            }

            let imageData = try await jotFilePreviewImageService.getPreviewImageData(
                jotFileInfo: readableVersionFileInfo,
                userInterfaceStyle: userInterfaceStyle,
                displayScale: displayScale
            )
            return UIImage(data: imageData)
        } catch {
            print(error)
            return nil
        }
    }
}
