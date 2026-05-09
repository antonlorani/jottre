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
import XCTest

@testable import Jottre

final class LocalFileServiceTests: XCTestCase {

    private var rootDirectory: URL!
    private var fileService: LocalFileService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        fileService = LocalFileService(fileManager: FileManager.default)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: rootDirectory)
        rootDirectory = nil
        fileService = nil
        try super.tearDownWithError()
    }

    func test_isEnabled_alwaysReturnsTrue() {
        // Then
        XCTAssertTrue(fileService.isEnabled())
    }

    func test_temporaryDirectory_returnsFileManagerTemporaryDirectory() {
        // When
        let url = fileService.temporaryDirectory()

        // Then
        XCTAssertEqual(url, FileManager.default.temporaryDirectory)
    }

    func test_writeFileThenReadFile_roundTripsBytes() throws {
        // Given
        let fileURL = rootDirectory.appendingPathComponent("note.jot")
        let payload = Data("Hello".utf8)

        // When
        try fileService.writeFile(fileURL: fileURL, data: payload)
        let readBack = try fileService.readFile(fileURL: fileURL)

        // Then
        XCTAssertEqual(readBack, payload)
    }

    func test_fileExists_givenWrittenFile_returnsTrue() throws {
        // Given
        let fileURL = rootDirectory.appendingPathComponent("note.jot")
        try Data().write(to: fileURL)

        // Then
        XCTAssertTrue(fileService.fileExists(fileURL: fileURL))
    }

    func test_fileExists_givenMissingFile_returnsFalse() {
        // Given
        let fileURL = rootDirectory.appendingPathComponent("missing.jot")

        // Then
        XCTAssertFalse(fileService.fileExists(fileURL: fileURL))
    }

    func test_listContents_givenMixOfFiles_returnsAllURLs() throws {
        // Given
        let fileURL1 = rootDirectory.appendingPathComponent("a.jot")
        let fileURL2 = rootDirectory.appendingPathComponent("b.txt")
        try Data().write(to: fileURL1)
        try Data().write(to: fileURL2)

        // When
        let urls = try fileService.listContents(directory: rootDirectory, properties: [])

        // Then
        let names = Set(urls.map(\.lastPathComponent))
        XCTAssertEqual(names, ["a.jot", "b.txt"])
    }

    func test_moveFile_movesFileToDestinationAndDeletesOriginal() throws {
        // Given
        let originalURL = rootDirectory.appendingPathComponent("original.jot")
        let destinationURL = rootDirectory.appendingPathComponent("destination.jot")
        try Data("payload".utf8).write(to: originalURL)

        // When
        try fileService.moveFile(fileURL: originalURL, newFileURL: destinationURL)

        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: originalURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: destinationURL.path))
        XCTAssertEqual(try Data(contentsOf: destinationURL), Data("payload".utf8))
    }

    func test_removeFile_deletesFile() throws {
        // Given
        let fileURL = rootDirectory.appendingPathComponent("note.jot")
        try Data().write(to: fileURL)

        // When
        try fileService.removeFile(fileURL: fileURL)

        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func test_duplicateFile_givenNoExistingDuplicate_writesPlainNamedCopy() throws {
        // Given
        let originalURL = rootDirectory.appendingPathComponent("note.jot")
        try Data("payload".utf8).write(to: originalURL)

        // When
        let duplicatedURL = try fileService.duplicateFile(fileURL: originalURL)

        // Then
        XCTAssertEqual(duplicatedURL.pathExtension, "jot")
        XCTAssertNotEqual(duplicatedURL, originalURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: duplicatedURL.path))
        XCTAssertEqual(try Data(contentsOf: duplicatedURL), Data("payload".utf8))
    }

    func test_duplicateFile_givenExistingDuplicate_writesIncrementedNamedCopy() throws {
        // Given
        let originalURL = rootDirectory.appendingPathComponent("note.jot")
        try Data("payload".utf8).write(to: originalURL)

        // When
        let firstDuplicate = try fileService.duplicateFile(fileURL: originalURL)
        let secondDuplicate = try fileService.duplicateFile(fileURL: originalURL)

        // Then
        XCTAssertNotEqual(firstDuplicate, secondDuplicate)
        XCTAssertTrue(FileManager.default.fileExists(atPath: firstDuplicate.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: secondDuplicate.path))
    }

    func test_directoryChanges_emitsInitialEventOnSubscribe() async throws {
        // Given
        let stream = fileService.directoryChanges(directory: rootDirectory)
        var iterator = stream.makeAsyncIterator()

        // When
        let first: Void? = await iterator.next()

        // Then
        XCTAssertNotNil(first)
    }
}
