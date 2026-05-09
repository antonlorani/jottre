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

final class JotFileTests: XCTestCase {

    func test_infoInit_givenURLWithJotExtension_succeedsAndDerivesNameFromURL() throws {
        // Given
        let url = URL(staticString: "file:///tmp/note.jot")

        // When
        let info = try XCTUnwrap(
            JotFile.Info(
                url: url,
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        )

        // Then
        XCTAssertEqual(info.name, "note")
        XCTAssertEqual(info.url, url)
    }

    func test_infoInit_givenURLWithNonJotExtension_returnsNil() {
        // Given
        let url = URL(staticString: "file:///tmp/note.txt")

        // When
        let info = JotFile.Info(
            url: url,
            modificationDate: nil,
            ubiquitousInfo: nil
        )

        // Then
        XCTAssertNil(info)
    }

    func test_makeEmptyJot_returnsVersionThreeWithDefaultWidth() {
        // When
        let jot = Jot.makeEmpty()

        // Then
        XCTAssertEqual(jot.version, 3)
        XCTAssertEqual(jot.width, 1200)
        XCTAssertFalse(jot.drawing.isEmpty)
    }
}
