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

struct UbiquitousFileService: FileServiceProtocol {

    nonisolated(unsafe) private let fileManager: FileManager
    private let localFileService: FileServiceProtocol

    init(
        fileManager: FileManager,
        localFileService: FileServiceProtocol
    ) {
        self.fileManager = fileManager
        self.localFileService = localFileService
    }

    func isEnabled() -> Bool {
        fileManager.ubiquityIdentityToken != nil
    }

    func documentsDirectory() async throws -> URL? {
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
        try localFileService.listContents(
            directory: directory,
            properties: properties
        )
    }

    func isUbiquitous(url: URL) -> Bool {
        fileManager.isUbiquitousItem(at: url)
    }

    func directoryChanges(directory: URL) -> AsyncStream<Void> {
        assert(isUbiquitous(url: directory), "Cannot listen to directory changes of a non ubiquitous directory.")
        return AsyncStream { continuation in
            continuation.yield()
            let observer = UbiquitousDirectoryObserver {
                continuation.yield()
            }
            continuation.onTermination = { _ in
                observer.stop()
            }
        }
    }

    func readFile(fileURL: URL) throws -> Data {
        try localFileService.readFile(fileURL: fileURL)
    }

    func writeFile(
        fileURL: URL,
        data: Data
    ) throws {
        try localFileService.writeFile(
            fileURL: fileURL,
            data: data
        )
    }

    func fileExists(fileURL: URL) -> Bool {
        localFileService.fileExists(fileURL: fileURL)
    }

    func removeFile(fileURL: URL) throws {
        try localFileService.removeFile(fileURL: fileURL)
    }

    func moveFile(fileURL: URL, newFileURL: URL) throws {
        try localFileService.moveFile(
            fileURL: fileURL,
            newFileURL: newFileURL
        )
    }

    func duplicateFile(fileURL: URL) throws -> URL {
        try localFileService.duplicateFile(fileURL: fileURL)
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
