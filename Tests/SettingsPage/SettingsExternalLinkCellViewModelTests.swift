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
final class SettingsExternalLinkCellViewModelTests: XCTestCase {

    func test_init_storesNameAndInfoFromBusinessModel() {
        // Given
        let businessModel = SettingsExternalLinkBusinessModel(name: "GitHub", info: "Open repository")

        // When
        let viewModel = SettingsExternalLinkCellViewModel(
            settingsExternalLink: businessModel,
            onAction: {}
        )

        // Then
        XCTAssertEqual(viewModel.name, "GitHub")
        XCTAssertEqual(viewModel.info, "Open repository")
    }

    func test_init_givenNilInfoBusinessModel_storesNilInfo() {
        // Given
        let businessModel = SettingsExternalLinkBusinessModel(name: "GitHub", info: nil)

        // When
        let viewModel = SettingsExternalLinkCellViewModel(
            settingsExternalLink: businessModel,
            onAction: {}
        )

        // Then
        XCTAssertNil(viewModel.info)
    }

    func test_handleAction_givenTap_invokesOnAction() async {
        // Given
        let onActionExpectation = XCTestExpectation(description: "onAction is called.")
        let viewModel = SettingsExternalLinkCellViewModel(
            settingsExternalLink: SettingsExternalLinkBusinessModel(name: "GitHub", info: nil),
            onAction: { onActionExpectation.fulfill() }
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        await fulfillment(of: [onActionExpectation], timeout: 0.2)
    }
}
