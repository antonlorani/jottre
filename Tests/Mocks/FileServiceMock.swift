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

@testable import Jottre

final class FileServiceMock: FileServiceProtocol {

    private let isEnabledProvider: @Sendable () -> Bool
    private let initializeDocumentsDirectoryProvider: @Sendable () async throws -> Void
    private let documentsDirectoryProvider: @Sendable () async throws -> URL?
    private let temporaryDirectoryProvider: @Sendable () -> URL
    private let listContentsProvider: @Sendable (_ directory: URL, _ properties: [URLResourceKey]) throws -> [URL]
    private let ubiquitousInfoProvider: @Sendable (_ url: URL) -> UbiquitousInfo?
    private let startDownloadProvider: @Sendable (_ fileURL: URL) throws -> Void
    private let directoryChangesProvider: @Sendable (_ directory: URL) -> AsyncStream<Void>
    private let readFileProvider: @Sendable (_ fileURL: URL) throws -> Data
    private let writeFileProvider: @Sendable (_ fileURL: URL, _ data: Data) throws -> Void
    private let fileExistsProvider: @Sendable (_ fileURL: URL) -> Bool
    private let removeFileProvider: @Sendable (_ fileURL: URL) throws -> Void
    private let moveFileProvider: @Sendable (_ fileURL: URL, _ newFileURL: URL) throws -> Void
    private let duplicateFileProvider: @Sendable (_ fileURL: URL) throws -> URL

    init(
        isEnabledProvider: @Sendable @escaping () -> Bool = { true },
        initializeDocumentsDirectoryProvider: @Sendable @escaping () async throws -> Void = {},
        documentsDirectoryProvider: @Sendable @escaping () async throws -> URL? = { nil },
        temporaryDirectoryProvider: @Sendable @escaping () -> URL = { URL(fileURLWithPath: NSTemporaryDirectory()) },
        listContentsProvider: @Sendable @escaping (_ directory: URL, _ properties: [URLResourceKey]) throws -> [URL] = {
            _,
            _ in []
        },
        ubiquitousInfoProvider: @Sendable @escaping (_ url: URL) -> UbiquitousInfo? = { _ in nil },
        startDownloadProvider: @Sendable @escaping (_ fileURL: URL) throws -> Void = { _ in },
        directoryChangesProvider: @Sendable @escaping (_ directory: URL) -> AsyncStream<Void> = { _ in
            AsyncStream { $0.finish() }
        },
        readFileProvider: @Sendable @escaping (_ fileURL: URL) throws -> Data = { _ in Data() },
        writeFileProvider: @Sendable @escaping (_ fileURL: URL, _ data: Data) throws -> Void = { _, _ in },
        fileExistsProvider: @Sendable @escaping (_ fileURL: URL) -> Bool = { _ in false },
        removeFileProvider: @Sendable @escaping (_ fileURL: URL) throws -> Void = { _ in },
        moveFileProvider: @Sendable @escaping (_ fileURL: URL, _ newFileURL: URL) throws -> Void = { _, _ in },
        duplicateFileProvider: @Sendable @escaping (_ fileURL: URL) throws -> URL = { $0 }
    ) {
        self.isEnabledProvider = isEnabledProvider
        self.initializeDocumentsDirectoryProvider = initializeDocumentsDirectoryProvider
        self.documentsDirectoryProvider = documentsDirectoryProvider
        self.temporaryDirectoryProvider = temporaryDirectoryProvider
        self.listContentsProvider = listContentsProvider
        self.ubiquitousInfoProvider = ubiquitousInfoProvider
        self.startDownloadProvider = startDownloadProvider
        self.directoryChangesProvider = directoryChangesProvider
        self.readFileProvider = readFileProvider
        self.writeFileProvider = writeFileProvider
        self.fileExistsProvider = fileExistsProvider
        self.removeFileProvider = removeFileProvider
        self.moveFileProvider = moveFileProvider
        self.duplicateFileProvider = duplicateFileProvider
    }

    func isEnabled() -> Bool { isEnabledProvider() }
    func initializeDocumentsDirectory() async throws { try await initializeDocumentsDirectoryProvider() }
    func documentsDirectory() async throws -> URL? { try await documentsDirectoryProvider() }
    func temporaryDirectory() -> URL { temporaryDirectoryProvider() }
    func listContents(directory: URL, properties: [URLResourceKey]) throws -> [URL] {
        try listContentsProvider(directory, properties)
    }
    func ubiquitousInfo(url: URL) -> UbiquitousInfo? { ubiquitousInfoProvider(url) }
    func startDownload(fileURL: URL) throws { try startDownloadProvider(fileURL) }
    func directoryChanges(directory: URL) -> AsyncStream<Void> { directoryChangesProvider(directory) }
    func readFile(fileURL: URL) throws -> Data { try readFileProvider(fileURL) }
    func writeFile(fileURL: URL, data: Data) throws { try writeFileProvider(fileURL, data) }
    func fileExists(fileURL: URL) -> Bool { fileExistsProvider(fileURL) }
    func removeFile(fileURL: URL) throws { try removeFileProvider(fileURL) }
    func moveFile(fileURL: URL, newFileURL: URL) throws { try moveFileProvider(fileURL, newFileURL) }
    func duplicateFile(fileURL: URL) throws -> URL { try duplicateFileProvider(fileURL) }
}
