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

@preconcurrency import PencilKit
import UIKit
import XCTest

@testable import Jottre

final class ShareJotRepositoryTests: XCTestCase {

    private var temporaryDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: temporaryDirectory)
        temporaryDirectory = nil
        try super.tearDownWithError()
    }

    func test_exportJot_givenPDFFormat_writesPDFFileToTemporaryDirectoryAndReturnsItsURL() async throws {
        // Given
        let repository = try makeRepository()

        // When
        let resultURL = try await repository.exportJot(jotFileInfo: makeJotFileInfo(), format: .pdf)

        // Then
        XCTAssertEqual(resultURL.lastPathComponent, "note.pdf")
        XCTAssertEqual(resultURL.deletingLastPathComponent(), temporaryDirectory)
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path))
        let header = try Data(contentsOf: resultURL).prefix(4)
        XCTAssertEqual(Array(header), Array("%PDF".utf8))
    }

    func test_exportJot_givenJPGFormat_writesJPGFileToTemporaryDirectoryAndReturnsItsURL() async throws {
        // Given
        let repository = try makeRepository()

        // When
        let resultURL = try await repository.exportJot(jotFileInfo: makeJotFileInfo(), format: .jpg)

        // Then
        XCTAssertEqual(resultURL.lastPathComponent, "note.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path))
        let bytes = try Data(contentsOf: resultURL).prefix(3)
        XCTAssertEqual(Array(bytes), [0xFF, 0xD8, 0xFF])
    }

    func test_exportJot_givenPNGFormat_writesPNGFileToTemporaryDirectoryAndReturnsItsURL() async throws {
        // Given
        let repository = try makeRepository()

        // When
        let resultURL = try await repository.exportJot(jotFileInfo: makeJotFileInfo(), format: .png)

        // Then
        XCTAssertEqual(resultURL.lastPathComponent, "note.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path))
        let bytes = try Data(contentsOf: resultURL).prefix(8)
        XCTAssertEqual(Array(bytes), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    }

    func test_exportJot_givenJotFileServiceThrows_propagatesError() async {
        // Given
        struct UnexpectedError: Error {}
        let repository = ShareJotRepository(
            jotFileService: JotFileServiceMock(
                readJotFileProvider: { _ in throw UnexpectedError() }
            ),
            fileService: FileServiceMock(
                temporaryDirectoryProvider: { [temporaryDirectory] in temporaryDirectory! }
            )
        )

        // When + Then
        do {
            _ = try await repository.exportJot(jotFileInfo: makeJotFileInfo(), format: .pdf)
            XCTFail("Expected exportJot to throw")
        } catch is UnexpectedError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func makeRepository() throws -> ShareJotRepository {
        let fixtureJot = try loadFixtureJot()
        return ShareJotRepository(
            jotFileService: JotFileServiceMock(
                readJotFileProvider: { jotFileInfo in
                    JotFile(info: jotFileInfo, jot: fixtureJot)
                }
            ),
            fileService: FileServiceMock(
                temporaryDirectoryProvider: { [temporaryDirectory] in temporaryDirectory! }
            )
        )
    }

    private func loadFixtureJot() throws -> Jot {
        let bundle = Bundle(for: ShareJotRepositoryTests.self)
        let fixtureURL = try XCTUnwrap(
            bundle.url(forResource: "Calculator Pro", withExtension: "jot"),
            "Missing 'Calculator Pro.jot' fixture in test bundle resources."
        )
        let data = try Data(contentsOf: fixtureURL)
        return try PropertyListDecoder().decode(Jot.self, from: data)
    }

    private func makeJotFileInfo() -> JotFile.Info {
        JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
    }
}
