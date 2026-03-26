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

protocol JotsRepositoryProtocol {

    func getJotFiles() throws -> AsyncThrowingStream<[JotFile.Info], Error>
}

struct JotsRepository: JotsRepositoryProtocol {

    private let jotFileService: JotFileServiceProtocol
    private let fileService: FileServiceProtocol

    init(
        jotFileService: JotFileServiceProtocol,
        fileService: FileServiceProtocol
    ) {
        self.jotFileService = jotFileService
        self.fileService = fileService
    }

    func getJotFiles() throws -> AsyncThrowingStream<[JotFile.Info], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let localDirectory = try fileService.localDocumentsDirectory()
                    let cloudDirectory = try await fileService.cloudDocumentsDirectory()
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
}
