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

final class AsyncSequenceDebounceTests: XCTestCase {

    func test_debounce_givenSingleValue_yieldsValueAfterInterval() async throws {
        // Given
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(1)
            continuation.finish()
        }

        // When
        var iterator = stream.debounce(for: 0.05).makeAsyncIterator()
        let first = try await XCTUnwrapAsync(await iterator.next())
        let second = await iterator.next()

        // Then
        XCTAssertEqual(first, 1)
        XCTAssertNil(second)
    }

    func test_debounce_givenBurstOfValues_yieldsOnlyLastValue() async throws {
        // Given
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(1)
            continuation.yield(2)
            continuation.yield(3)
            continuation.finish()
        }

        // When
        var values: [Int] = []
        for await value in stream.debounce(for: 0.05) {
            values.append(value)
        }

        // Then
        XCTAssertEqual(values, [3])
    }
}

private func XCTUnwrapAsync<T>(
    _ expression: @autoclosure () async throws -> T?,
    file: StaticString = #filePath,
    line: UInt = #line
) async throws -> T {
    let value = try await expression()
    return try XCTUnwrap(value, file: file, line: line)
}
