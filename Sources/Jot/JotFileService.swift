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

protocol JotFileServiceProtocol: Sendable {
    func documentsDirectoryContents() -> AsyncThrowingStream<[JotFile.Info], Error>

    func readJotFile(jotFileInfo: JotFile.Info) throws -> JotFile

    func write(jotFile: JotFile) throws

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info

    func rename(jotFileInfo: JotFile.Info, newName: String) throws -> JotFile.Info

    func remove(jotFileInfo: JotFile.Info) throws

    func move(
        jotFileInfo: JotFile.Info,
        shouldBecomeUbiquitous: Bool
    ) async throws
}

struct JotFileService: JotFileServiceProtocol {

    private enum Constants {

        static func fileProperties(isUbiquitous: Bool) -> [URLResourceKey] {
            var fileProperties: [URLResourceKey] = [
                .contentModificationDateKey,
                .isWritableKey,
                .isReadableKey,
                .isRegularFileKey,
            ]

            if isUbiquitous {
                fileProperties.append(.ubiquitousItemDownloadingStatusKey)
                fileProperties.append(.ubiquitousItemIsDownloadingKey)
            }

            return fileProperties
        }
    }

    enum Failure: Error {
        case couldNotResolveDocumentsDirectory
    }

    private let propertyListDecoder = PropertyListDecoder()
    private let propertyListEncoder = PropertyListEncoder()

    private let localFileService: FileServiceProtocol
    private let ubiquitousFileService: FileServiceProtocol

    init(
        localFileService: FileServiceProtocol,
        ubiquitousFileService: FileServiceProtocol
    ) {
        self.localFileService = localFileService
        self.ubiquitousFileService = ubiquitousFileService
    }

    func documentsDirectoryContents() -> AsyncThrowingStream<[JotFile.Info], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let ubiquitousDocumentsDirectory = try await ubiquitousFileService.documentsDirectory()
                    let localDocumentsDirectory = try await localFileService.documentsDirectory()

                    let documentsDirectories: [(isUbiquitous: Bool, directory: URL)] = [
                        (isUbiquitous: true, directory: ubiquitousDocumentsDirectory),
                        (isUbiquitous: false, directory: localDocumentsDirectory),
                    ]
                    .compactMap { isUbiquitous, directory in
                        guard let directory else {
                            return nil
                        }
                        return (isUbiquitous: isUbiquitous, directory: directory)
                    }

                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for (isUbiquitous, documentsDirectory) in documentsDirectories {
                            let fileService =
                                if isUbiquitous {
                                    ubiquitousFileService
                                } else {
                                    localFileService
                                }

                            group.addTask {
                                for try await _ in fileService.directoryChanges(directory: documentsDirectory) {
                                    try continuation.yield(
                                        documentsDirectories
                                            .flatMap { (isUbiquitous: Bool, directory: URL) in
                                                try listContents(
                                                    directory: directory,
                                                    isUbiquitous: isUbiquitous
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

    private func listContents(
        directory: URL,
        isUbiquitous: Bool
    ) throws -> [JotFile.Info] {
        let fileService =
            if isUbiquitous {
                ubiquitousFileService
            } else {
                localFileService
            }

        let contents = try fileService.listContents(
            directory: directory,
            properties: Constants.fileProperties(isUbiquitous: isUbiquitous)
        )

        return
            try contents
            .map { content in
                try (
                    content: content,
                    properties:
                        content
                        .resourceValues(forKeys: Set(Constants.fileProperties(isUbiquitous: isUbiquitous)))
                )
            }
            .filter { (fileURL: URL, properties: URLResourceValues) in
                properties.isRegularFile == true
                    && properties.isReadable == true
                    && properties.isWritable == true
                    && fileURL.pathExtension == JotFile.Info.fileExtension
            }
            .map { (fileURL: URL, properties: URLResourceValues) in
                lazy var downloadStatus: UbiquitousInfo.DownloadStatus? =
                    switch properties.ubiquitousItemDownloadingStatus {
                    case .current:
                        UbiquitousInfo.DownloadStatus.current
                    case .downloaded:
                        UbiquitousInfo.DownloadStatus.downloaded
                    case .notDownloaded:
                        UbiquitousInfo.DownloadStatus.notDownloaded
                    default:
                        nil
                    }

                let ubiqitousInfo =
                    isUbiquitous
                    ? UbiquitousInfo(
                        downloadStatus: downloadStatus,
                        isDownloading: properties.ubiquitousItemIsDownloading ?? false
                    )
                    : nil

                return JotFile.Info(
                    url: fileURL,
                    name: fileURL.deletingPathExtension().lastPathComponent,
                    modificationDate: properties.contentModificationDate,
                    ubiquitousInfo: ubiqitousInfo
                )
            }
    }

    func readJotFile(jotFileInfo: JotFile.Info) throws -> JotFile {
        let fileService =
            if jotFileInfo.ubiquitousInfo != nil {
                ubiquitousFileService
            } else {
                localFileService
            }

        let data = try fileService.readFile(fileURL: jotFileInfo.url)
        let jot = try propertyListDecoder.decode(Jot.self, from: data)

        return JotFile(
            info: jotFileInfo,
            jot: jot
        )
    }

    func write(jotFile: JotFile) throws {
        let fileService =
            if jotFile.info.ubiquitousInfo != nil {
                ubiquitousFileService
            } else {
                localFileService
            }

        let data = try propertyListEncoder.encode(jotFile.jot)

        try fileService.writeFile(
            fileURL: jotFile.info.url,
            data: data
        )
    }

    func duplicate(jotFileInfo: JotFile.Info) throws -> JotFile.Info {
        let fileService =
            if jotFileInfo.ubiquitousInfo != nil {
                ubiquitousFileService
            } else {
                localFileService
            }
        let duplicatedFileURL = try fileService.duplicateFile(fileURL: jotFileInfo.url)

        return JotFile.Info(
            url: duplicatedFileURL,
            name: duplicatedFileURL.deletingPathExtension().lastPathComponent,
            modificationDate: jotFileInfo.modificationDate,
            ubiquitousInfo: jotFileInfo.ubiquitousInfo
        )
    }

    func rename(
        jotFileInfo: JotFile.Info,
        newName: String
    ) throws -> JotFile.Info {
        let newFileURL = jotFileInfo.url
            .deletingPathExtension()
            .deletingLastPathComponent()
            .appendingPathComponent(newName)
            .appendingPathExtension(jotFileInfo.url.pathExtension)

        let fileService =
            if jotFileInfo.ubiquitousInfo != nil {
                ubiquitousFileService
            } else {
                localFileService
            }

        try fileService.moveFile(
            fileURL: jotFileInfo.url,
            newFileURL: newFileURL
        )

        return JotFile.Info(
            url: newFileURL,
            name: newName,
            modificationDate: jotFileInfo.modificationDate,
            ubiquitousInfo: jotFileInfo.ubiquitousInfo
        )
    }

    func remove(jotFileInfo: JotFile.Info) throws {
        let fileService =
            if jotFileInfo.ubiquitousInfo != nil {
                ubiquitousFileService
            } else {
                localFileService
            }

        try fileService.removeFile(fileURL: jotFileInfo.url)
    }

    func move(
        jotFileInfo: JotFile.Info,
        shouldBecomeUbiquitous: Bool
    ) async throws {
        let fileService =
            if shouldBecomeUbiquitous {
                ubiquitousFileService
            } else {
                localFileService
            }

        guard let documentsDirectory = try await fileService.documentsDirectory() else {
            throw Failure.couldNotResolveDocumentsDirectory
        }

        try fileService.moveFile(
            fileURL: jotFileInfo.url,
            newFileURL: documentsDirectory.appendingPathComponent(jotFileInfo.url.lastPathComponent, isDirectory: false)
        )
    }
}
