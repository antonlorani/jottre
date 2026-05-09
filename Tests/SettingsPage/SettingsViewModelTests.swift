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
final class SettingsViewModelTests: XCTestCase {

    func test_rightNavigationItems_givenInit_yieldsDismissSymbol() async throws {
        // Given
        let viewModel = SettingsViewModel(
            repository: SettingsRepositoryMock(),
            coordinator: SettingsCoordinatorMock()
        )

        // When
        let items = try await firstValue(of: viewModel.rightNavigationItems)

        // Then
        XCTAssertEqual(items.count, 1)
        guard case let .symbol(systemImageName, _) = items[0] else {
            XCTFail("Expected .symbol")
            return
        }
        XCTAssertEqual(systemImageName, "xmark")
    }

    func test_rightNavigationItem_givenTap_invokesCoordinatorDismiss() async throws {
        // Given
        let dismissExpectation = XCTestExpectation(description: "SettingsCoordinatorMock.dismiss is called.")
        let coordinatorMock = SettingsCoordinatorMock(
            dismissProvider: { dismissExpectation.fulfill() }
        )
        let viewModel = SettingsViewModel(
            repository: SettingsRepositoryMock(),
            coordinator: coordinatorMock
        )

        // When
        let items = try await firstValue(of: viewModel.rightNavigationItems)
        guard case let .symbol(_, onAction) = items[0] else {
            XCTFail("Expected .symbol")
            return
        }
        onAction()

        // Then
        await fulfillment(of: [dismissExpectation], timeout: 1)
    }

    func test_didLoad_givenShouldNotShowICloud_yieldsThreeItems() async throws {
        // Given
        let userInterfaceStyleStream = AsyncStream<UIUserInterfaceStyle> { continuation in
            continuation.yield(.unspecified)
            continuation.finish()
        }
        let viewModel = SettingsViewModel(
            repository: SettingsRepositoryMock(
                shouldShowEnableICloudButtonProvider: { false },
                appVersionProvider: { "1.2.3" },
                userInterfaceStyleProvider: { userInterfaceStyleStream }
            ),
            coordinator: SettingsCoordinatorMock()
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 3)
        XCTAssertNotNil(items[0].id as? SettingsDropdownBusinessModel)
        XCTAssertNotNil(items[1].id as? SettingsExternalLinkBusinessModel)
        XCTAssertNotNil(items[2].id as? SettingsInfoBusinessModel)
        let info = try XCTUnwrap(items[2].id as? SettingsInfoBusinessModel)
        XCTAssertEqual(info.value, "1.2.3")
    }

    func test_didLoad_givenShouldShowICloud_yieldsFourItemsWithICloudLink() async throws {
        // Given
        let userInterfaceStyleStream = AsyncStream<UIUserInterfaceStyle> { continuation in
            continuation.yield(.dark)
            continuation.finish()
        }
        let viewModel = SettingsViewModel(
            repository: SettingsRepositoryMock(
                shouldShowEnableICloudButtonProvider: { true },
                userInterfaceStyleProvider: { userInterfaceStyleStream }
            ),
            coordinator: SettingsCoordinatorMock()
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 4)
        XCTAssertNotNil(items[1].id as? SettingsExternalLinkBusinessModel)
        XCTAssertNotNil(items[2].id as? SettingsExternalLinkBusinessModel)
    }

    func test_didLoad_givenDarkStyle_yieldsDropdownWithDarkAsCurrent() async throws {
        // Given
        let userInterfaceStyleStream = AsyncStream<UIUserInterfaceStyle> { continuation in
            continuation.yield(.dark)
            continuation.finish()
        }
        let viewModel = SettingsViewModel(
            repository: SettingsRepositoryMock(
                userInterfaceStyleProvider: { userInterfaceStyleStream }
            ),
            coordinator: SettingsCoordinatorMock()
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)

        // Then
        let dropdown = try XCTUnwrap(items[0].id as? SettingsDropdownBusinessModel)
        XCTAssertEqual(dropdown.current.value as? UIUserInterfaceStyle, .dark)
        XCTAssertEqual(dropdown.options.count, 3)
    }

    func test_didLoadExternalLinkTap_givenICloudVisible_invokesOpenExternalLinkWithICloudURL() async throws {
        // Given
        let openExternalLinkExpectation =
            XCTestExpectation(description: "SettingsCoordinatorMock.openExternalLink is called.")
        let userInterfaceStyleStream = AsyncStream<UIUserInterfaceStyle> { continuation in
            continuation.yield(.unspecified)
            continuation.finish()
        }
        let coordinatorMock = SettingsCoordinatorMock(
            openExternalLinkProvider: { receivedURL in
                // Then
                XCTAssertEqual(receivedURL, EnableICloudSupportURL().toURL())
                openExternalLinkExpectation.fulfill()
            }
        )
        let viewModel = SettingsViewModel(
            repository: SettingsRepositoryMock(
                shouldShowEnableICloudButtonProvider: { true },
                userInterfaceStyleProvider: { userInterfaceStyleStream }
            ),
            coordinator: coordinatorMock
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)
        items[1].handleAction(.tap)

        // Then
        await fulfillment(of: [openExternalLinkExpectation], timeout: 1)
    }

    func test_didLoadExternalLinkTap_givenGithubLink_invokesOpenExternalLinkWithGithubURL() async throws {
        // Given
        let openExternalLinkExpectation =
            XCTestExpectation(description: "SettingsCoordinatorMock.openExternalLink is called.")
        let userInterfaceStyleStream = AsyncStream<UIUserInterfaceStyle> { continuation in
            continuation.yield(.unspecified)
            continuation.finish()
        }
        let coordinatorMock = SettingsCoordinatorMock(
            openExternalLinkProvider: { receivedURL in
                // Then
                XCTAssertEqual(receivedURL, JottreGithubURL().toURL())
                openExternalLinkExpectation.fulfill()
            }
        )
        let viewModel = SettingsViewModel(
            repository: SettingsRepositoryMock(
                shouldShowEnableICloudButtonProvider: { false },
                userInterfaceStyleProvider: { userInterfaceStyleStream }
            ),
            coordinator: coordinatorMock
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)
        items[1].handleAction(.tap)

        // Then
        await fulfillment(of: [openExternalLinkExpectation], timeout: 1)
    }
}

@MainActor
private func firstValue<S: AsyncSequence & Sendable>(
    of sequence: S
) async throws -> S.Element where S.Element: Sendable {
    var iterator = sequence.makeAsyncIterator()
    guard let value = try await iterator.next() else {
        throw NSError(domain: "SettingsViewModelTests", code: 0)
    }
    return value
}
