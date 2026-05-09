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

final class ArraySafeIndexTests: XCTestCase {

    func test_safeSubscript_givenIndexInBounds_returnsElement() {
        // Given
        let array = [10, 20, 30]

        // When
        let element = array[safe: 1]

        // Then
        XCTAssertEqual(element, 20)
    }

    func test_safeSubscript_givenIndexOutOfBounds_returnsNil() {
        // Given
        let array = [10, 20, 30]

        // When
        let element = array[safe: 5]

        // Then
        XCTAssertNil(element)
    }

    func test_safeSubscript_givenEmptyArray_returnsNil() {
        // Given
        let array: [Int] = []

        // When
        let element = array[safe: 0]

        // Then
        XCTAssertNil(element)
    }
}
