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
