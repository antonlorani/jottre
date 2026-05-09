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

@MainActor
final class SettingsDropdownCellViewModelTests: XCTestCase {

    func test_init_storesNameCurrentAndOptionsFromBusinessModel() {
        // Given
        let light = SettingsDropdownBusinessModel.Option(label: "Light", value: "light")
        let dark = SettingsDropdownBusinessModel.Option(label: "Dark", value: "dark")
        let businessModel = SettingsDropdownBusinessModel(
            name: "Appearance",
            current: light,
            options: [light, dark]
        )

        // When
        let viewModel = SettingsDropdownCellViewModel(
            settingsDropdown: businessModel,
            onAction: { _ in }
        )

        // Then
        XCTAssertEqual(viewModel.name, "Appearance")
        XCTAssertEqual(viewModel.current, light)
        XCTAssertEqual(viewModel.options, [light, dark])
    }

    func test_handleAction_givenTap_doesNotInvokeOnAction() async {
        // Given
        let onActionExpectation = XCTestExpectation(description: "onAction is not called for .tap")
        onActionExpectation.isInverted = true
        let option = SettingsDropdownBusinessModel.Option(label: "Light", value: "light")
        let viewModel = SettingsDropdownCellViewModel(
            settingsDropdown: SettingsDropdownBusinessModel(
                name: "Appearance",
                current: option,
                options: [option]
            ),
            onAction: { _ in onActionExpectation.fulfill() }
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        await fulfillment(of: [onActionExpectation], timeout: 0.05)
    }
}
