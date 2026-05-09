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

final class JotConflictBusinessModelTests: XCTestCase {

    func test_init_givenSavingComputerName_usesAsLastEditedDateString() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let version = JotFileVersion(
            localizedNameOfSavingComputer: "Anton's Mac",
            info: info
        )

        // When
        let model = JotConflictBusinessModel(
            name: "label",
            jotFileInfo: info,
            jotFileVersion: version
        )

        // Then
        XCTAssertEqual(model.name, "label")
        XCTAssertEqual(model.lastEditedDateString, "Anton's Mac")
        XCTAssertEqual(model.jotFileInfo, info)
    }

    func test_init_givenNilSavingComputerName_returnsNotApplicableString() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let version = JotFileVersion(
            localizedNameOfSavingComputer: nil,
            info: info
        )

        // When
        let model = JotConflictBusinessModel(
            name: "label",
            jotFileInfo: info,
            jotFileVersion: version
        )

        // Then
        XCTAssertEqual(model.lastEditedDateString, "n/a")
    }

    func test_toJotFileVersion_returnsOriginalVersion() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let version = JotFileVersion(localizedNameOfSavingComputer: nil, info: info)

        // When
        let model = JotConflictBusinessModel(
            name: "label",
            jotFileInfo: info,
            jotFileVersion: version
        )

        // Then
        XCTAssertEqual(model.toJotFileVersion(), version)
    }
}
