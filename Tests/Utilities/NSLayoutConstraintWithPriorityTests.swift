import UIKit
import XCTest

@testable import Jottre

final class NSLayoutConstraintWithPriorityTests: XCTestCase {

    func test_withPriority_setsPriorityAndReturnsSameConstraint() {
        // Given
        let view = UIView()
        let constraint = view.widthAnchor.constraint(equalToConstant: 100)

        // When
        let returned = constraint.withPriority(.defaultLow)

        // Then
        XCTAssertEqual(constraint.priority, .defaultLow)
        XCTAssertTrue(returned === constraint)
    }

    func test_withPriority_givenChainedCalls_appliesLastValue() {
        // Given
        let view = UIView()
        let constraint = view.widthAnchor.constraint(equalToConstant: 100)

        // When
        _ = constraint.withPriority(.defaultLow).withPriority(.required)

        // Then
        XCTAssertEqual(constraint.priority, .required)
    }
}
