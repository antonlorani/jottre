import XCTest

@testable import Jottre

final class JottreGithubURLTests: XCTestCase {

    func test_components_pointToProjectGithubRepository() {
        // Given / When
        let url = JottreGithubURL()

        // Then
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "github.com")
        XCTAssertEqual(url.path, "/antonlorani/jottre")
    }

    func test_toURL_producesAbsoluteURL() {
        // When
        let resolved = JottreGithubURL().toURL()

        // Then
        XCTAssertEqual(resolved.absoluteString, "https://github.com/antonlorani/jottre")
    }
}
