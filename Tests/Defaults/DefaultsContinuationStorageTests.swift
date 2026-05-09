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

final class DefaultsContinuationStorageTests: XCTestCase {

    func test_continuations_givenNoRegistrations_returnsNil() {
        // Given
        let storage = DefaultsContinuationStorage()
        let key = DefaultsKey<Int>("none")

        // When
        let result = storage.continuations(defaultsKey: key)

        // Then
        XCTAssertNil(result)
    }

    func test_add_givenContinuationForKey_continuationsReturnsIt() throws {
        // Given
        let storage = DefaultsContinuationStorage()
        let key = DefaultsKey<Int>("k")
        let stream = AsyncStream<Int?> { continuation in
            storage.add(continuation, defaultsKey: key)
        }
        let iterator = stream.makeAsyncIterator()
        _ = iterator

        // When
        let result = try XCTUnwrap(storage.continuations(defaultsKey: key))

        // Then
        XCTAssertEqual(result.count, 1)
    }

    func test_addMultiple_givenSameKey_continuationsReturnsAll() throws {
        // Given
        let storage = DefaultsContinuationStorage()
        let key = DefaultsKey<Int>("k")
        let stream1 = AsyncStream<Int?> { continuation in
            storage.add(continuation, defaultsKey: key)
        }
        let stream2 = AsyncStream<Int?> { continuation in
            storage.add(continuation, defaultsKey: key)
        }
        let iterator1 = stream1.makeAsyncIterator()
        let iterator2 = stream2.makeAsyncIterator()
        _ = iterator1
        _ = iterator2

        // When
        let result = try XCTUnwrap(storage.continuations(defaultsKey: key))

        // Then
        XCTAssertEqual(result.count, 2)
    }

    func test_continuations_givenDifferentKey_returnsNil() {
        // Given
        let storage = DefaultsContinuationStorage()
        let registeredKey = DefaultsKey<Int>("k1")
        let otherKey = DefaultsKey<Int>("k2")
        let stream = AsyncStream<Int?> { continuation in
            storage.add(continuation, defaultsKey: registeredKey)
        }
        let iterator = stream.makeAsyncIterator()
        _ = iterator

        // When
        let result = storage.continuations(defaultsKey: otherKey)

        // Then
        XCTAssertNil(result)
    }
}
