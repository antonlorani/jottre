import UIKit
import XCTest

@testable import Jottre

final class UITraitCollectionHasRenderingChangeTests: XCTestCase {

    func test_hasRenderingChange_givenIdenticalTraits_returnsFalse() {
        // Given
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(displayScale: 2.0),
        ])

        // When
        let result = traits.hasRenderingChange(comparedTo: traits)

        // Then
        XCTAssertFalse(result)
    }

    func test_hasRenderingChange_givenNilPrevious_returnsTrue() {
        // Given
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(displayScale: 2.0),
        ])

        // When
        let result = traits.hasRenderingChange(comparedTo: nil)

        // Then
        XCTAssertTrue(result)
    }

    func test_hasRenderingChange_givenDifferingUserInterfaceStyle_returnsTrue() {
        // Given
        let lightTraits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(displayScale: 2.0),
        ])
        let darkTraits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .dark),
            UITraitCollection(displayScale: 2.0),
        ])

        // When
        let result = lightTraits.hasRenderingChange(comparedTo: darkTraits)

        // Then
        XCTAssertTrue(result)
    }

    func test_hasRenderingChange_givenDifferingDisplayScale_returnsTrue() {
        // Given
        let twoXTraits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(displayScale: 2.0),
        ])
        let threeXTraits = UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(displayScale: 3.0),
        ])

        // When
        let result = twoXTraits.hasRenderingChange(comparedTo: threeXTraits)

        // Then
        XCTAssertTrue(result)
    }
}
