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
