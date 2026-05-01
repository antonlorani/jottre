import XCTest

@testable import Jottre

final class JotsPageURLTests: XCTestCase {

    func test_path_isRoot() {
        // Given / When
        let url = JotsPageURL()

        // Then
        XCTAssertEqual(url.path, "/")
    }

    func test_toURL_producesURLWithRootPath() {
        // Given
        let url = JotsPageURL()

        // When
        let result = url.toURL()

        // Then
        XCTAssertEqual(result.path, "/")
    }
}
