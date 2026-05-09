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

final class RevealFileURLTests: XCTestCase {

    func test_init_givenJotFileInfo_extractsPathFromInfoURL() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/dir/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let revealFileURL = RevealFileURL(jotFileInfo: info)

        // Then
        XCTAssertEqual(revealFileURL.scheme, "shareddocuments")
        XCTAssertEqual(revealFileURL.host, "")
        XCTAssertEqual(revealFileURL.path, "/tmp/dir/note.jot")
    }

    func test_toURL_producesSharedDocumentsURL() throws {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/dir/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let result = RevealFileURL(jotFileInfo: info).toURL()

        // Then
        XCTAssertEqual(result.scheme, "shareddocuments")
        XCTAssertEqual(result.path, "/tmp/dir/note.jot")
    }
}
