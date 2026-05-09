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
