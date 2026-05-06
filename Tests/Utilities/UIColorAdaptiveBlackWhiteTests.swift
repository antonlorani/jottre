import UIKit
import XCTest

@testable import Jottre

final class UIColorAdaptiveBlackWhiteTests: XCTestCase {

    func test_adaptiveBlackWhite_givenLightUserInterfaceStyle_resolvesToWhite() {
        // Given
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)

        // When
        let resolved = UIColor.adaptiveBlackWhite.resolvedColor(with: lightTraits)

        // Then
        XCTAssertEqual(resolved, UIColor.white)
    }

    func test_adaptiveBlackWhite_givenDarkUserInterfaceStyle_resolvesToBlack() {
        // Given
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        // When
        let resolved = UIColor.adaptiveBlackWhite.resolvedColor(with: darkTraits)

        // Then
        XCTAssertEqual(resolved, UIColor.black)
    }
}
