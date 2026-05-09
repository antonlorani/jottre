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
final class EmptyStateCellViewModelTests: XCTestCase {

    func test_init_storesTitle() {
        // When
        let viewModel = EmptyStateCellViewModel(title: "Nothing here yet")

        // Then
        XCTAssertEqual(viewModel.title, "Nothing here yet")
    }

    func test_handleContextMenuConfiguration_returnsNilByDefault() {
        // Given
        let viewModel = EmptyStateCellViewModel(title: "irrelevant")

        // When
        let configuration = viewModel.handleContextMenuConfiguration(
            point: .zero,
            sourceView: UIView()
        )

        // Then
        XCTAssertNil(configuration)
    }
}
