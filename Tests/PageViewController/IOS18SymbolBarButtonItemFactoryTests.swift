import UIKit
import XCTest

@testable import Jottre

@MainActor
final class IOS18SymbolBarButtonItemFactoryTests: XCTestCase {

    func test_make_givenActionPrimary_returnsBarButtonItemWrappingButtonWithAction() {
        // Given
        let factory = IOS18SymbolBarButtonItemFactory()
        let action = UIAction { _ in }

        // When
        let barButtonItem = factory.make(symbolName: "plus", primaryAction: .action(action))

        // Then
        let button = try? XCTUnwrap(barButtonItem.customView as? UIButton)
        XCTAssertNotNil(button)
        XCTAssertFalse(button?.showsMenuAsPrimaryAction ?? true)
    }

    func test_make_givenMenuPrimary_returnsBarButtonItemWrappingButtonWithMenu() throws {
        // Given
        let factory = IOS18SymbolBarButtonItemFactory()
        let menu = UIMenu(title: "Menu", children: [])

        // When
        let barButtonItem = factory.make(symbolName: "ellipsis", primaryAction: .menu(menu))

        // Then
        let button = try XCTUnwrap(barButtonItem.customView as? UIButton)
        XCTAssertTrue(button.showsMenuAsPrimaryAction)
        XCTAssertNotNil(button.menu)
    }
}
