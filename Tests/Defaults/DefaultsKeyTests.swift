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

final class DefaultsKeyTests: XCTestCase {

    func test_init_givenString_setsDescription() {
        // When
        let key = DefaultsKey<String>("someKey")

        // Then
        XCTAssertEqual(key.description, "someKey")
    }

    func test_initStringLiteral_setsDescription() {
        // When
        let key: DefaultsKey<String> = "literalKey"

        // Then
        XCTAssertEqual(key.description, "literalKey")
    }

    func test_isICloudEnabled_returnsExpectedDescription() {
        // When
        let key = DefaultsKey<Bool>.isICloudEnabled

        // Then
        XCTAssertEqual(key.description, "isICloudEnabled")
    }

    func test_userInterfaceStyle_returnsExpectedDescription() {
        // When
        let key = DefaultsKey<Int>.userInterfaceStyle

        // Then
        XCTAssertEqual(key.description, "userInterfaceStyle")
    }

    func test_hasDoneCloudMigration_returnsExpectedDescription() {
        // When
        let key = DefaultsKey<Bool>.hasDoneCloudMigration

        // Then
        XCTAssertEqual(key.description, "hasDoneCloudMigration")
    }
}
