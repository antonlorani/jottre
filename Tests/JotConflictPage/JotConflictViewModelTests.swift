import XCTest

@testable import Jottre

@MainActor
final class JotConflictViewModelTests: XCTestCase {

    func test_items_givenOneVersion_yieldsHeaderAndDeviceVersionAndProvidedVersion() async throws {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let version = JotFileVersion(localizedNameOfSavingComputer: "Mac", info: info)
        let viewModel = JotConflictViewModel(
            jotFileInfo: info,
            jotFileVersions: [version],
            repository: JotConflictRepositoryMock(),
            coordinator: JotConflictCoordinatorMock(),
            onResult: { _ in }
        )

        // When
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 3)
    }

    func test_actions_givenTwoVersions_yieldsThreeActions() {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let viewModel = JotConflictViewModel(
            jotFileInfo: info,
            jotFileVersions: [
                JotFileVersion(localizedNameOfSavingComputer: "Mac", info: info),
                JotFileVersion(localizedNameOfSavingComputer: "iPad", info: info),
            ],
            repository: JotConflictRepositoryMock(),
            coordinator: JotConflictCoordinatorMock(),
            onResult: { _ in }
        )

        // Then: 1 device version + 2 provided versions + keep-all = 4
        XCTAssertEqual(viewModel.actions.count, 4)
    }

    func test_actions_givenKeepAllTap_resolvesAllAndDismissesWithKeepAllResult() {
        // Given
        let resolveExpectation = XCTestExpectation(description: "Repository.resolveVersionConflicts is called.")
        let dismissExpectation = XCTestExpectation(description: "Coordinator.dismiss is called.")
        let onResultExpectation = XCTestExpectation(description: "onResult is called with .keepAll.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = JotConflictCoordinatorMock(
            dismissProvider: { completion in
                dismissExpectation.fulfill()
                completion()
            }
        )
        let viewModel = JotConflictViewModel(
            jotFileInfo: info,
            jotFileVersions: [
                JotFileVersion(localizedNameOfSavingComputer: "Mac", info: info)
            ],
            repository: JotConflictRepositoryMock(
                resolveVersionConflictsProvider: { _, resolved in
                    XCTAssertEqual(resolved.count, 2)
                    resolveExpectation.fulfill()
                }
            ),
            coordinator: coordinator,
            onResult: { result in
                if case .keepAll = result {
                    onResultExpectation.fulfill()
                }
            }
        )

        // When (last action is keepAll)
        viewModel.actions.last?.action()

        // Then
        wait(for: [resolveExpectation, dismissExpectation, onResultExpectation], timeout: 1)
    }

    func test_actions_givenKeepVersionThrows_invokesShowInfoAlert() async {
        // Given
        let alertExpectation = XCTestExpectation(description: "Coordinator.showInfoAlert is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = JotConflictCoordinatorMock(
            showInfoAlertProvider: { _, _ in alertExpectation.fulfill() }
        )
        let viewModel = JotConflictViewModel(
            jotFileInfo: info,
            jotFileVersions: [
                JotFileVersion(localizedNameOfSavingComputer: "Mac", info: info)
            ],
            repository: JotConflictRepositoryMock(
                resolveVersionConflictsProvider: { _, _ in
                    throw NSError(domain: "test", code: 0)
                }
            ),
            coordinator: coordinator,
            onResult: { _ in }
        )

        // When (first action is keep version)
        viewModel.actions.first?.action()

        // Then
        await fulfillment(of: [alertExpectation], timeout: 1)
    }
}

@MainActor
private func firstValue<S: AsyncSequence & Sendable>(
    of sequence: S
) async throws -> S.Element where S.Element: Sendable {
    var iterator = sequence.makeAsyncIterator()
    guard let value = try await iterator.next() else {
        throw NSError(domain: "JotConflictViewModelTests", code: 0)
    }
    return value
}
