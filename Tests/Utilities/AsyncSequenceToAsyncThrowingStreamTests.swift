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

final class AsyncSequenceToAsyncThrowingStreamTests: XCTestCase {

    func test_toAsyncThrowingStream_givenFiniteSequence_yieldsAllElementsThenFinishes() async throws {
        // Given
        let source = AsyncStream<Int> { continuation in
            continuation.yield(1)
            continuation.yield(2)
            continuation.yield(3)
            continuation.finish()
        }

        // When
        var collected: [Int] = []
        for try await value in source.toAsyncThrowingStream() {
            collected.append(value)
        }

        // Then
        XCTAssertEqual(collected, [1, 2, 3])
    }

    func test_toAsyncStream_givenFiniteSequence_yieldsAllElementsThenFinishes() async {
        // Given
        let source = AsyncStream<Int> { continuation in
            continuation.yield(10)
            continuation.yield(20)
            continuation.finish()
        }

        // When
        var collected: [Int] = []
        for await value in source.toAsyncStream() {
            collected.append(value)
        }

        // Then
        XCTAssertEqual(collected, [10, 20])
    }

    func test_toAsyncThrowingStream_givenThrowingUpstream_propagatesError() async {
        // Given
        struct DummyError: Error, Equatable {}
        let source = AsyncThrowingStream<Int, Error> { continuation in
            continuation.yield(1)
            continuation.finish(throwing: DummyError())
        }

        // When / Then
        do {
            for try await _ in source.toAsyncThrowingStream() {
                /* no-op */
            }
            XCTFail("Expected the upstream error to propagate.")
        } catch is DummyError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
