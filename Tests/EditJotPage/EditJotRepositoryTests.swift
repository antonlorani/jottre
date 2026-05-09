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
import XCTest

@testable import Jottre

final class EditJotRepositoryTests: XCTestCase {

    func test_ubiquitousInfo_forwardsToUbiquitousFileService() {
        // Given
        let expectedInfo = UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        let url = URL(staticString: "file:///cloud/note.jot")
        let repository = EditJotRepository(
            ubiquitousFileService: FileServiceMock(
                ubiquitousInfoProvider: { receivedURL in
                    XCTAssertEqual(receivedURL, url)
                    return expectedInfo
                }
            ),
            jotFileService: JotFileServiceMock(),
            jotFileConflictService: JotFileConflictServiceMock()
        )

        // When
        let result = repository.ubiquitousInfo(url: url)

        // Then
        XCTAssertEqual(result, expectedInfo)
    }

    func test_readDrawing_givenValidJotFile_returnsDrawingAndWidth() async throws {
        // Given
        let drawing = PKDrawing()
        let drawingData = drawing.dataRepresentation()
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let repository = EditJotRepository(
            ubiquitousFileService: FileServiceMock(),
            jotFileService: JotFileServiceMock(
                readJotFileProvider: { _ in
                    JotFile(
                        info: info,
                        jot: Jot(version: 3, drawing: drawingData, width: 800)
                    )
                }
            ),
            jotFileConflictService: JotFileConflictServiceMock()
        )

        // When
        let result = try await repository.readDrawing(jotFileInfo: info)

        // Then
        XCTAssertEqual(result.width, 800)
        XCTAssertEqual(result.drawing.strokes.count, drawing.strokes.count)
    }

    func test_writeDrawing_writesEncodedDrawingViaJotFileService() async throws {
        // Given
        let writeProviderExpectation = XCTestExpectation(description: "JotFileServiceMock.writeProvider is called.")
        let drawing = PKDrawing()
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let repository = EditJotRepository(
            ubiquitousFileService: FileServiceMock(),
            jotFileService: JotFileServiceMock(
                writeProvider: { jotFile in
                    // Then
                    XCTAssertEqual(jotFile.info, info)
                    XCTAssertEqual(jotFile.jot.drawing, drawing.dataRepresentation())
                    writeProviderExpectation.fulfill()
                }
            ),
            jotFileConflictService: JotFileConflictServiceMock()
        )

        // When
        try await repository.writeDrawing(jotFileInfo: info, drawing: drawing)

        // Then
        await fulfillment(of: [writeProviderExpectation], timeout: 0.2)
    }

    func test_getConflictingVersions_forwardsToConflictService() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let expected = [
            JotFileVersion(localizedNameOfSavingComputer: "Mac", info: info)
        ]
        let repository = EditJotRepository(
            ubiquitousFileService: FileServiceMock(),
            jotFileService: JotFileServiceMock(),
            jotFileConflictService: JotFileConflictServiceMock(
                getConfictingVersionsProvider: { receivedInfo in
                    XCTAssertEqual(receivedInfo, info)
                    return expected
                }
            )
        )

        // When
        let result = repository.getConflictingVersions(jotFileInfo: info)

        // Then
        XCTAssertEqual(result, expected)
    }

    func test_duplicate_forwardsToJotFileService() throws {
        // Given
        let original = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let duplicated = JotFile.Info(
            url: URL(staticString: "file:///tmp/note-1.jot"),
            name: "note-1",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let repository = EditJotRepository(
            ubiquitousFileService: FileServiceMock(),
            jotFileService: JotFileServiceMock(
                duplicateProvider: { receivedInfo in
                    XCTAssertEqual(receivedInfo, original)
                    return duplicated
                }
            ),
            jotFileConflictService: JotFileConflictServiceMock()
        )

        // When
        let result = try repository.duplicate(jotFileInfo: original)

        // Then
        XCTAssertEqual(result, duplicated)
    }
}
