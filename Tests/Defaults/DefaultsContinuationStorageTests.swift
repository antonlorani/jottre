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
        // Force the closure to run by creating an iterator.
        var iterator = stream.makeAsyncIterator()
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
        var iterator1 = stream1.makeAsyncIterator()
        var iterator2 = stream2.makeAsyncIterator()
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
        var iterator = stream.makeAsyncIterator()
        _ = iterator

        // When
        let result = storage.continuations(defaultsKey: otherKey)

        // Then
        XCTAssertNil(result)
    }
}
