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

final class JotBusinessModelTests: XCTestCase {

    func test_init_givenLocalJotFileInfo_isDownloadedTrueAndIsDownloadingFalse() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // Then
        XCTAssertEqual(model.name, "note")
        XCTAssertTrue(model.isDownloaded)
        XCTAssertFalse(model.isDownloading)
    }

    func test_init_givenUbiquitousInfoWithNotDownloaded_isDownloadedFalse() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: true)
        )

        // When
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // Then
        XCTAssertFalse(model.isDownloaded)
        XCTAssertTrue(model.isDownloading)
    }

    func test_init_givenUbiquitousInfoWithDownloaded_isDownloadedTrue() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .downloaded, isDownloading: false)
        )

        // When
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // Then
        XCTAssertTrue(model.isDownloaded)
        XCTAssertFalse(model.isDownloading)
    }

    func test_toJotFileInfo_returnsOriginalInfo() {
        // Given
        let jotFileInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let model = JotBusinessModel(jotFileInfo: jotFileInfo)

        // When
        let result = model.toJotFileInfo()

        // Then
        XCTAssertEqual(result, jotFileInfo)
    }
}
