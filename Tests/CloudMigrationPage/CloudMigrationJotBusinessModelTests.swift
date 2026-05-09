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

final class CloudMigrationJotBusinessModelTests: XCTestCase {

    func test_init_givenLocalInfo_isUbiquitousFalseAndIsDownloadedTrue() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertEqual(model.name, "note")
        XCTAssertFalse(model.isUbiquitous)
        XCTAssertTrue(model.isDownloaded)
        XCTAssertFalse(model.isDownloading)
        XCTAssertEqual(model.lastModifiedText, "")
    }

    func test_init_givenUbiquitousInfoNotDownloaded_isUbiquitousTrueAndIsDownloadedFalse() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///cloud/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: true)
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertTrue(model.isUbiquitous)
        XCTAssertFalse(model.isDownloaded)
        XCTAssertTrue(model.isDownloading)
    }

    func test_init_givenModificationDate_formatsLastModifiedText() {
        // Given
        let date = Date(timeIntervalSince1970: 0)
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: date,
            ubiquitousInfo: nil
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertFalse(model.lastModifiedText.isEmpty)
        XCTAssertEqual(
            model.lastModifiedText,
            DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .short)
        )
    }

    func test_toJotFileInfo_returnsOriginalInfo() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // When
        let model = CloudMigrationJotBusinessModel(jotFileInfo: info)

        // Then
        XCTAssertEqual(model.toJotFileInfo(), info)
    }
}
