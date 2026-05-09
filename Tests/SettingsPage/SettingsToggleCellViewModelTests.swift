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
final class SettingsToggleCellViewModelTests: XCTestCase {

    func test_init_storesNameAndIsOnFromBusinessModel() {
        // Given
        let businessModel = SettingsToggleBusinessModel(name: "iCloud", isOn: true)

        // When
        let viewModel = SettingsToggleCellViewModel(settingsToggle: businessModel)

        // Then
        XCTAssertEqual(viewModel.name, "iCloud")
        XCTAssertTrue(viewModel.isOn)
    }

    func test_handleAction_givenTap_doesNothing() {
        // Given
        let viewModel = SettingsToggleCellViewModel(
            settingsToggle: SettingsToggleBusinessModel(name: "iCloud", isOn: false)
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        XCTAssertFalse(viewModel.isOn)
    }
}
