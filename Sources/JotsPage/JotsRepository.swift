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

    private let fileService: FileServiceProtocol
    private let jotFileService: JotFileServiceProtocol
    private let jotFilePreviewImageService: JotFilePreviewImageServiceProtocol

    init(
        fileService: FileServiceProtocol,
        jotFileService: JotFileServiceProtocol,
        jotFilePreviewImageService: JotFilePreviewImageServiceProtocol
    ) {
        self.fileService = fileService
        self.jotFileService = jotFileService
        self.jotFilePreviewImageService = jotFilePreviewImageService
    }

    func getJotFiles() -> AsyncThrowingStream<[JotFile.Info], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let localDirectory = try fileService.localDocumentsDirectory()
                    let cloudDirectory = try await fileService.iCloudDocumentsDirectory()
                    let directories = [localDirectory, cloudDirectory].compactMap { $0 }

                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for directory in directories {
                            group.addTask {
                                for try await _ in fileService.directoryChanges(directory: directory) {
                                    try continuation.yield(
                                        directories
                                            .flatMap { (directory: URL) throws -> [JotFile.Info] in
                                                try jotFileService.listContents(directory: directory)
                                            }
                                            .sorted(by: {
                                                ($0.modificationDate ?? .distantPast)
                                                    > ($1.modificationDate ?? .distantPast)
                                            })
                                    )
                                }
                            }
                        }
                        try await group.waitForAll()
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func shouldShowEnableICloudButton() -> Bool {
        !fileService.isICloudEnabled()
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
