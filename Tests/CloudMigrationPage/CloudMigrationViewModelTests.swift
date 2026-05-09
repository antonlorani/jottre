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
final class CloudMigrationViewModelTests: XCTestCase {

    func test_didLoad_givenEmptyJotFiles_yieldsCloudImageAndHeader() async throws {
        // Given
        let stream = AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error> { continuation in
            continuation.yield([])
            continuation.finish()
        }
        let viewModel = CloudMigrationViewModel(
            repository: CloudMigrationRepositoryMock(getJotFilesProvider: { stream }),
            coordinator: CloudMigrationCoordinatorMock()
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 2)
    }

    func test_didLoad_givenOneJot_yieldsHeaderAndJotItem() async throws {
        // Given
        let businessModel = CloudMigrationJotBusinessModel(
            jotFileInfo: JotFile.Info(
                url: URL(staticString: "file:///tmp/foo.jot"),
                name: "foo",
                modificationDate: Date(timeIntervalSince1970: 0),
                ubiquitousInfo: nil
            )
        )
        let stream = AsyncThrowingStream<[CloudMigrationJotBusinessModel], Error> { continuation in
            continuation.yield([businessModel])
            continuation.finish()
        }
        let viewModel = CloudMigrationViewModel(
            repository: CloudMigrationRepositoryMock(getJotFilesProvider: { stream }),
            coordinator: CloudMigrationCoordinatorMock()
        )

        // When
        viewModel.didLoad()
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 2)
    }

    func test_actions_givenDoneTap_marksDoneAndDismissesViaCoordinator() async {
        // Given
        let markDoneExpectation = XCTestExpectation(description: "Repository.markCloudMigrationPageDone is called.")
        let dismissExpectation =
            XCTestExpectation(description: "CloudMigrationCoordinatorMock.dismiss is called.")
        let coordinator = CloudMigrationCoordinatorMock(
            dismissProvider: { dismissExpectation.fulfill() }
        )
        let viewModel = CloudMigrationViewModel(
            repository: CloudMigrationRepositoryMock(
                markCloudMigrationPageDoneProvider: { markDoneExpectation.fulfill() }
            ),
            coordinator: coordinator
        )

        // When
        XCTAssertEqual(viewModel.actions.count, 1)
        viewModel.actions[0].action()

        // Then
        await fulfillment(of: [markDoneExpectation, dismissExpectation], timeout: 1)
    }
}

@MainActor
private func firstValue<S: AsyncSequence & Sendable>(
    of sequence: S
) async throws -> S.Element where S.Element: Sendable {
    var iterator = sequence.makeAsyncIterator()
    guard let value = try await iterator.next() else {
        throw NSError(domain: "CloudMigrationViewModelTests", code: 0)
    }
    return value
}
