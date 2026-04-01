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

struct LocalFileService: FileServiceProtocol {

    enum Failure: Error {
        case couldNotReadFileContents
        case couldNotWriteFileContents
    }

    nonisolated(unsafe) private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func isEnabled() -> Bool {
        true
    }

    func documentsDirectory() async throws -> URL? {
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        var isDirectory = ObjCBool(true)
        if !fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    func temporaryDirectory() -> URL {
        fileManager.temporaryDirectory
    }

    func listContents(
        directory: URL,
        properties: [URLResourceKey]
    ) throws -> [URL] {
        try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: properties
        )
    }

    func ubiquitousInfo(url: URL) -> UbiquitousInfo? {
        assertionFailure("Shouldn't have called \(#function) in \(Self.self)")
        return nil
    }

    func directoryChanges(directory: URL) -> AsyncStream<Void> {
        AsyncStream { continuation in
            continuation.yield()

            let fd = open(directory.path, O_EVTONLY)
            guard fd >= 0 else {
                continuation.finish()
                return
            }

            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd,
                eventMask: [.write, .rename, .delete, .extend],
                queue: .global()
            )

            source.setEventHandler {
                continuation.yield()
            }

            source.setCancelHandler {
                close(fd)
            }

            continuation.onTermination = { _ in
                source.cancel()
            }

            source.resume()
        }
    }

    func readFile(fileURL: URL) throws -> Data {
        let coordinator = NSFileCoordinator()
        var error: NSError?
        var result: Result<Data, Error>?

        coordinator.coordinate(
            readingItemAt: fileURL,
            options: [],
            error: &error
        ) { url in
            result = Result(catching: {
                try Data(contentsOf: url)
            })
        }

        if let error {
            throw error
        }

        guard let result else {
            throw Failure.couldNotReadFileContents
        }

        return try result.get()
    }

    func writeFile(fileURL: URL, data: Data) throws {
        let coordinator = NSFileCoordinator()
        var error: NSError?
        var result: Result<Void, Error>?

        coordinator.coordinate(
            writingItemAt: fileURL,
            options: .forReplacing,
            error: &error
        ) { url in
            result = Result(catching: {
                try data.write(to: url, options: .atomic)
            })
        }

        if let error {
            throw error
        }

        guard let result else {
            throw Failure.couldNotWriteFileContents
        }

        try result.get()
    }

    func fileExists(fileURL: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        return fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
    }

    func removeFile(fileURL: URL) throws {
        try fileManager.removeItem(at: fileURL)
    }

    func moveFile(fileURL: URL, newFileURL: URL) throws {
        try fileManager.moveItem(at: fileURL, to: newFileURL)
    }

    func duplicateFile(fileURL: URL) throws -> URL {
        var duplicateCount = 0
        let fileName = fileURL.deletingPathExtension().lastPathComponent

        while true {
            let destinationFileName =
                if duplicateCount == 0 {
                    L10n.FileSystem.Duplicate.FileName.plain(fileName)
                } else {
                    L10n.FileSystem.Duplicate.FileName.multi(fileName, duplicateCount)
                }
            duplicateCount += 1

            let destinationFileURL =
                fileURL
                .deletingPathExtension()
                .deletingLastPathComponent()
                .appendingPathComponent(destinationFileName)
                .appendingPathExtension(fileURL.pathExtension)

            do {
                try fileManager.copyItem(at: fileURL, to: destinationFileURL)
                return destinationFileURL
            } catch CocoaError.fileWriteFileExists {
                continue
            }
        }
    }
}
