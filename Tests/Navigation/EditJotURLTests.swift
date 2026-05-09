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

import XCTest

@testable import Jottre

final class EditJotURLTests: XCTestCase {

    func test_init_givenJotFileInfo_setsFileURLFromInfo() {
        // Given
        let fileURL = URL(staticString: "file:///tmp/note.jot")
        let info = JotFile.Info(
            url: fileURL,
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let editJotURL = EditJotURL(jotFileInfo: info)

        // Then
        XCTAssertEqual(editJotURL.fileURL, fileURL)
        XCTAssertEqual(editJotURL.path, "/jots/edit")
    }

    func test_initFromURL_givenMatchingPathAndQueryItem_succeeds() throws {
        // Given
        let url = URL(staticString: "scheme:///jots/edit?fileURL=file:///tmp/note.jot")

        // When
        let editJotURL = try XCTUnwrap(EditJotURL(url: url))

        // Then
        XCTAssertEqual(editJotURL.fileURL, URL(staticString: "file:///tmp/note.jot"))
    }

    func test_initFromURL_givenWrongPath_returnsNil() {
        // Given
        let url = URL(staticString: "scheme:///not/the/right/path?fileURL=file:///tmp/note.jot")

        // When
        let editJotURL = EditJotURL(url: url)

        // Then
        XCTAssertNil(editJotURL)
    }

    func test_initFromURL_givenMissingFileURLQueryItem_returnsNil() {
        // Given
        let url = URL(staticString: "scheme:///jots/edit")

        // When
        let editJotURL = EditJotURL(url: url)

        // Then
        XCTAssertNil(editJotURL)
    }

    func test_toURL_roundTripsFileURL() throws {
        // Given
        let fileURL = URL(staticString: "file:///tmp/note.jot")
        let original = EditJotURL(
            jotFileInfo: JotFile.Info(
                url: fileURL,
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        )

        // When
        let roundTripped = try XCTUnwrap(EditJotURL(url: original.toURL()))

        // Then
        XCTAssertEqual(roundTripped.fileURL, fileURL)
    }
}
