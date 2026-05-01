import XCTest

@testable import Jottre

final class DefaultsServiceTests: XCTestCase {

    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "DefaultsServiceTests-\(UUID().uuidString)"
        userDefaults = try! XCTUnwrap(UserDefaults(suiteName: suiteName))
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func test_getValue_givenNoStoredValue_returnsNil() {
        // Given
        let service = DefaultsService(userDefaults: userDefaults)

        // When
        let value: Bool? = service.getValue(DefaultsKey<Bool>("missing"))

        // Then
        XCTAssertNil(value)
    }

    func test_set_givenBoolValue_persistsAsRoundTrippableString() throws {
        // Given
        let service = DefaultsService(userDefaults: userDefaults)
        let key = DefaultsKey<Bool>("flag")

        // When
        service.set(key, value: true)

        // Then
        let stored = try XCTUnwrap(service.getValue(key))
        XCTAssertTrue(stored)
    }

    func test_set_givenNilValue_clearsValue() {
        // Given
        let service = DefaultsService(userDefaults: userDefaults)
        let key = DefaultsKey<Int>("count")
        service.set(key, value: 42)

        // When
        service.set(key, value: nil)

        // Then
        XCTAssertNil(service.getValue(key))
    }

    func test_getValueStream_yieldsCurrentValueImmediately() async throws {
        // Given
        let service = DefaultsService(userDefaults: userDefaults)
        let key = DefaultsKey<Int>("preset")
        service.set(key, value: 7)

        // When
        var iterator = service.getValueStream(key).makeAsyncIterator()
        let first = try await XCTUnwrapAsync(await iterator.next())

        // Then
        XCTAssertEqual(first, 7)
    }

    func test_getValueStream_yieldsValueOnSubsequentSet() async throws {
        // Given
        let service = DefaultsService(userDefaults: userDefaults)
        let key = DefaultsKey<Int>("counter")

        var iterator = service.getValueStream(key).makeAsyncIterator()
        // Discard initial yield (nil — no stored value)
        _ = await iterator.next()

        // When
        service.set(key, value: 99)
        let next = try await XCTUnwrapAsync(await iterator.next())

        // Then
        XCTAssertEqual(next, 99)
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
