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
final class JotsViewModelTests: XCTestCase {

    func test_leftNavigationItems_givenShouldNotShowICloudButton_yieldsOnlySettings() async throws {
        // Given
        let viewModel = JotsViewModel(
            coordinator: JotsCoordinatorMock(),
            repository: JotsRepositoryMock(shouldShowEnableICloudButtonProvider: { false }),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        let items = try await firstValue(of: viewModel.leftNavigationItems)

        // Then
        XCTAssertEqual(items.count, 1)
        guard case let .symbol(systemImageName, _) = items[0] else {
            XCTFail("Expected .symbol")
            return
        }
        XCTAssertEqual(systemImageName, "gear")
    }

    func test_leftNavigationItems_givenShouldShowICloudButton_yieldsSettingsAndICloudSlash() async throws {
        // Given
        let viewModel = JotsViewModel(
            coordinator: JotsCoordinatorMock(),
            repository: JotsRepositoryMock(shouldShowEnableICloudButtonProvider: { true }),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        let items = try await firstValue(of: viewModel.leftNavigationItems)

        // Then
        XCTAssertEqual(items.count, 2)
        guard case let .symbol(secondImage, _) = items[1] else {
            XCTFail("Expected .symbol")
            return
        }
        XCTAssertEqual(secondImage, "icloud.slash")
    }

    func test_leftNavigationItem_givenSettingsTap_invokesOpenSettings() async throws {
        // Given
        let openSettingsExpectation = XCTestExpectation(description: "Coordinator.openSettings is called.")
        let coordinator = JotsCoordinatorMock(
            openSettingsProvider: { openSettingsExpectation.fulfill() }
        )
        let viewModel = JotsViewModel(
            coordinator: coordinator,
            repository: JotsRepositoryMock(),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        let items = try await firstValue(of: viewModel.leftNavigationItems)
        guard case let .symbol(_, onAction) = items[0] else {
            XCTFail("Expected .symbol")
            return
        }
        onAction()
        await Task.yield()

        // Then
        await fulfillment(of: [openSettingsExpectation], timeout: 1)
    }

    func test_leftNavigationItem_givenICloudTap_invokesOpenEnableCloudPage() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Coordinator.openEnableCloudPage is called.")
        let coordinator = JotsCoordinatorMock(
            openEnableCloudPageProvider: { expectation.fulfill() }
        )
        let viewModel = JotsViewModel(
            coordinator: coordinator,
            repository: JotsRepositoryMock(shouldShowEnableICloudButtonProvider: { true }),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        let items = try await firstValue(of: viewModel.leftNavigationItems)
        guard case let .symbol(_, onAction) = items[1] else {
            XCTFail("Expected .symbol")
            return
        }
        onAction()
        await Task.yield()

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }

    #if !targetEnvironment(macCatalyst)
    func test_rightNavigationItem_givenCreateTap_invokesOpenCreateJot() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Coordinator.openCreateJot is called.")
        let coordinator = JotsCoordinatorMock(
            openCreateJotProvider: { expectation.fulfill() }
        )
        let viewModel = JotsViewModel(
            coordinator: coordinator,
            repository: JotsRepositoryMock(),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        let items = try await firstValue(of: viewModel.rightNavigationItems)
        XCTAssertEqual(items.count, 1)
        guard case let .text(_, onAction) = items[0] else {
            XCTFail("Expected .text")
            return
        }
        onAction()
        await Task.yield()

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }
    #endif

    func test_didLoad_givenEmptyJots_yieldsEmptyStateItem() async throws {
        // Given
        let stream = AsyncThrowingStream<[JotFile.Info], Error> { continuation in
            continuation.yield([])
            continuation.finish()
        }
        let viewModel = JotsViewModel(
            coordinator: JotsCoordinatorMock(),
            repository: JotsRepositoryMock(getJotFilesProvider: { stream }),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 1)
    }

    func test_didLoad_givenOneJot_yieldsOneJotItem() async throws {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let stream = AsyncThrowingStream<[JotFile.Info], Error> { continuation in
            continuation.yield([info])
            continuation.finish()
        }
        let viewModel = JotsViewModel(
            coordinator: JotsCoordinatorMock(),
            repository: JotsRepositoryMock(getJotFilesProvider: { stream }),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 1)
    }
}

@MainActor
private func firstValue<S: AsyncSequence & Sendable>(
    of sequence: S
) async throws -> S.Element where S.Element: Sendable {
    var iterator = sequence.makeAsyncIterator()
    guard let value = try await iterator.next() else {
        throw NSError(domain: "JotsViewModelTests", code: 0)
    }
    return value
}
