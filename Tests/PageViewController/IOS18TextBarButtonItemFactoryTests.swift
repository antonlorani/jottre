import UIKit
import XCTest

@testable import Jottre

@MainActor
final class IOS18TextBarButtonItemFactoryTests: XCTestCase {

    func test_make_returnsBarButtonItemWrappingButtonConfiguredWithTitle() throws {
        // Given
        let factory = IOS18TextBarButtonItemFactory()
        let action = UIAction { _ in }

        // When
        let barButtonItem = factory.make(title: "Save", primaryAction: action)

        // Then
        let button = try XCTUnwrap(barButtonItem.customView as? UIButton)
        XCTAssertEqual(button.configuration?.title, "Save")
    }
}
