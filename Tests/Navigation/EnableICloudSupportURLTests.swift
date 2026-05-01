import XCTest

@testable import Jottre

final class EnableICloudSupportURLTests: XCTestCase {

    func test_init_givenLocaleWithLanguageAndRegion_buildsLocalizedSupportPath() {
        // Given
        let locale = Locale(identifier: "en_US")

        // When
        let url = EnableICloudSupportURL(locale: locale)

        // Then
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "support.apple.com")
        XCTAssertEqual(url.path, "/en-us/guide/icloud/mmfc0f1e2a/icloud")
    }

    func test_init_givenLocaleWithoutRegion_buildsGenericSupportPath() {
        // Given
        let locale = Locale(identifier: "en")

        // When
        let url = EnableICloudSupportURL(locale: locale)

        // Then
        XCTAssertEqual(url.path, "/guide/icloud/mmfc0f1e2a/icloud")
    }

    func test_toURL_producesAppleSupportURL() {
        // Given
        let url = EnableICloudSupportURL(locale: Locale(identifier: "de_DE"))

        // When
        let resolved = url.toURL()

        // Then
        XCTAssertEqual(resolved.scheme, "https")
        XCTAssertEqual(resolved.host, "support.apple.com")
    }
}
