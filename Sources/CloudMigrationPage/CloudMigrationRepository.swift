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

protocol CloudMigrationRepositoryProtocol: Sendable {

    func getJotFiles() -> AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error>
    func moveJotFile(
        jotFileInfo: JotFile.Info,
        shouldSynchronizeWithICloud: Bool
    ) async throws
    func getShouldShowCloudMigration() -> Bool
    func markCloudMigrationPageDone()
}

struct CloudMigrationRepository: CloudMigrationRepositoryProtocol {

    enum Failure: Error {
        case couldNotResolveDirectories
    }

    private let fileService: FileServiceProtocol
    private let jotFileService: JotFileServiceProtocol
    private let defaultsService: DefaultsServiceProtocol

    init(
        fileService: FileServiceProtocol,
        jotFileService: JotFileServiceProtocol,
        defaultsService: DefaultsServiceProtocol
    ) {
        self.fileService = fileService
        self.jotFileService = jotFileService
        self.defaultsService = defaultsService
    }

    func getJotFiles() -> AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let localDirectory = try fileService.localDocumentsDirectory()
                    let cloudDirectory = try await fileService.cloudDocumentsDirectory()
                    let directories = [(localDirectory, false), (cloudDirectory, true)]
                        .compactMap { (url, isCloud) in url.map { ($0, isCloud) } }

                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for (directory, _) in directories {
                            group.addTask {
                                for try await _ in fileService.directoryChanges(directory: directory) {
                                    try continuation.yield(
                                        directories
                                            .flatMap { (dir, isCloud) in
                                                try jotFileService.listContents(directory: dir)
                                                    .map { (info: $0, isCloud: isCloud) }
                                            }
                                            .sorted { lhs, rhs in
                                                if lhs.isCloud != rhs.isCloud {
                                                    return !lhs.isCloud
                                                }
                                                return lhs.info.modificationDate ?? .distantPast > rhs.info
                                                    .modificationDate ?? .distantPast
                                            }
                                            .map { jotFileInfo, isCloud in
                                                CloudMigrationJotBusinessModel(
                                                    jotFileInfo: jotFileInfo,
                                                    isCloudSynchronized: isCloud
                                                )
                                            }
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

    func moveJotFile(
        jotFileInfo: JotFile.Info,
        shouldSynchronizeWithICloud: Bool
    ) async throws {
        guard
            let localDirector = try fileService.localDocumentsDirectory(),
            let cloudDirectory = try await fileService.cloudDocumentsDirectory()
        else {
            throw Failure.couldNotResolveDirectories
        }

        let targetDirectory =
            if shouldSynchronizeWithICloud {
                cloudDirectory
            } else {
                localDirector
            }

        try fileService.moveFile(
            fileURL: jotFileInfo.url,
            newFileURL:
                targetDirectory
                .appendingPathComponent(jotFileInfo.url.lastPathComponent, isDirectory: false)
        )
    }

    func getShouldShowCloudMigration() -> Bool {
        guard defaultsService.getValue(.hasDoneCloudMigration) == false else {
            return false
        }

        let isICloudEnabled = fileService.isICloudEnabled()
        if let wasICloudEnabled = defaultsService.getValue(.isICloudEnabled) {
            return wasICloudEnabled != isICloudEnabled
        }

        if !isICloudEnabled {
            defaultsService.set(.isICloudEnabled, value: false)
        }

        return false
    }

    func markCloudMigrationPageDone() {
        defaultsService.set(.hasDoneCloudMigration, value: true)
    }
}
