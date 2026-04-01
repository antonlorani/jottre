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

protocol FileServiceProtocol: Sendable {

    func isICloudEnabled() -> Bool

    func localDocumentsDirectory() throws -> URL?

    func iCloudDocumentsDirectory() async throws -> URL?

    func listContents(
        directory: URL,
        properties: [URLResourceKey]
    ) throws -> [URL]

    func directoryChanges(directory: URL) -> AsyncStream<Void>

    func readFile(fileURL: URL) throws -> Data

    func writeFile(fileURL: URL, data: Data) throws

    func fileExists(fileURL: URL) -> Bool

    func removeFile(fileURL: URL) throws

    func moveFile(fileURL: URL, newFileURL: URL) throws

    func duplicateFile(fileURL: URL) throws -> URL
}

struct FileService: FileServiceProtocol {

    enum Failure: Error {
        case couldNotReadFileContents
        case couldNotWriteFileContents
    }

    nonisolated(unsafe) private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func isICloudEnabled() -> Bool {
        fileManager.ubiquityIdentityToken != nil
    }

    func localDocumentsDirectory() throws -> URL? {
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        var isDirectory = ObjCBool(true)
        if !fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    func iCloudDocumentsDirectory() async throws -> URL? {
        guard
            let directory = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        else {
            return nil
        }

        var isDirectory = ObjCBool(true)
        if !fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
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

    func directoryChanges(directory: URL) -> AsyncStream<Void> {
        if fileManager.isUbiquitousItem(at: directory) {
            ubiquitousDirectoryChanges()
        } else {
            localDirectoryChanges(directory: directory)
        }
    }

    private func localDirectoryChanges(directory: URL) -> AsyncStream<Void> {
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

    private func ubiquitousDirectoryChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            continuation.yield()
            let observer = UbiquitousDirectoryObserver { continuation.yield() }
            continuation.onTermination = { _ in observer.stop() }
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

private final class UbiquitousDirectoryObserver: @unchecked Sendable {

    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private let query = NSMetadataQuery()
    private var observers = [Any]()

    init(onUpdate: @Sendable @escaping () -> Void) {
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K LIKE '*.\(JotFile.Info.fileExtension)'", NSMetadataItemFSNameKey)
        query.operationQueue = queue

        for name: NSNotification.Name in [.NSMetadataQueryDidFinishGathering, .NSMetadataQueryDidUpdate] {
            observers.append(
                NotificationCenter.default.addObserver(forName: name, object: query, queue: queue) { _ in
                    onUpdate()
                }
            )
        }

        queue.addOperation { [self] in
            query.start()
        }
    }

    func stop() {
        queue.addOperation { [self] in
            query.stop()
            observers.forEach { NotificationCenter.default.removeObserver($0) }
        }
    }
}
