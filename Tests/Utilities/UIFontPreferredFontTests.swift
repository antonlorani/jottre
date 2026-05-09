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

import UIKit
import XCTest

@testable import Jottre

final class UIFontPreferredFontTests: XCTestCase {

    func test_preferredFont_givenBodyTextStyleAndBoldWeight_returnsScaledBoldFont() {
        // When
        let font = UIFont.preferredFont(forTextStyle: .body, weight: .bold)

        // Then
        let traits = font.fontDescriptor.symbolicTraits
        XCTAssertTrue(traits.contains(.traitBold))
        XCTAssertGreaterThan(font.pointSize, 0)
    }

    func test_preferredFont_givenLargerTextStyle_producesLargerOrEqualPointSize() {
        // When
        let captionFont = UIFont.preferredFont(forTextStyle: .caption2, weight: .regular)
        let titleFont = UIFont.preferredFont(forTextStyle: .title1, weight: .regular)

        // Then
        XCTAssertGreaterThan(titleFont.pointSize, captionFont.pointSize)
    }
}
