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
