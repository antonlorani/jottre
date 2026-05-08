@preconcurrency import PencilKit
import XCTest

@testable import Jottre

@MainActor
final class EditJotViewModelTests: XCTestCase {

    func test_didLoad_givenNoConflictingVersions_yieldsDrawingFromRepository() async throws {
        // Given
        let drawing = PKDrawing()
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(
                readDrawingProvider: { _ in (drawing, 1024) }
            ),
            coordinator: EditJotCoordinatorMock(),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didLoad()

        // Then
        var iterator = viewModel.drawing.makeAsyncIterator()
        let nextValue = await iterator.next()
        let received = try XCTUnwrap(nextValue)
        XCTAssertEqual(received.width, 1024)
    }

    func test_didLoad_givenConflictingVersions_invokesShowJotConflictPage() async {
        // Given
        let conflictExpectation = XCTestExpectation(description: "Coordinator.showJotConflictPage is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = EditJotCoordinatorMock(
            showJotConflictPageProvider: { _, _, _ in conflictExpectation.fulfill() }
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(
                getConflictingVersionsProvider: { _ in
                    [JotFileVersion(localizedNameOfSavingComputer: nil, info: info)]
                }
            ),
            coordinator: coordinator,
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didLoad()

        // Then
        await fulfillment(of: [conflictExpectation], timeout: 1)
    }

    func test_didTapBackButton_givenNoConflicts_invokesGoBack() async {
        // Given
        let goBackExpectation = XCTestExpectation(description: "Coordinator.goBack is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = EditJotCoordinatorMock(
            goBackProvider: { goBackExpectation.fulfill() }
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(),
            coordinator: coordinator,
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didTapBackButton()

        // Then
        await fulfillment(of: [goBackExpectation], timeout: 1)
    }

    func test_didTapBackButton_givenConflicts_invokesShowJotConflictPage() async {
        // Given
        let conflictExpectation = XCTestExpectation(description: "Coordinator.showJotConflictPage is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = EditJotCoordinatorMock(
            showJotConflictPageProvider: { _, _, _ in conflictExpectation.fulfill() }
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(
                getConflictingVersionsProvider: { _ in
                    [JotFileVersion(localizedNameOfSavingComputer: nil, info: info)]
                }
            ),
            coordinator: coordinator,
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didTapBackButton()

        // Then
        await fulfillment(of: [conflictExpectation], timeout: 1)
    }

    func test_showsBackButton_givenDidLoadAndCanGoBack_yieldsTrue() async throws {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = EditJotCoordinatorMock(
            canGoBackProvider: { true }
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(),
            coordinator: coordinator,
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didLoad()
        var iterator = viewModel.showsBackButton.makeAsyncIterator()
        let nextValue = await iterator.next()
        let value = try XCTUnwrap(nextValue)

        // Then
        XCTAssertTrue(value)
    }

    func test_didTapToggleEditingButton_givenFalse_yieldsTrue() async throws {
        // Given
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(),
            coordinator: EditJotCoordinatorMock(),
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        viewModel.didTapToggleEditingButton(isEditing: false)

        // Then
        var iterator = viewModel.isEditing.makeAsyncIterator()
        let nextValue = await iterator.next()
        let firstValue = try XCTUnwrap(nextValue)
        let value = try XCTUnwrap(firstValue)
        XCTAssertTrue(value)
    }

    func test_menuConfigurations_givenDuplicateActionThrows_invokesShowInfoAlert() async {
        // Given
        let alertExpectation = XCTestExpectation(description: "Coordinator.showInfoAlert is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = EditJotCoordinatorMock(
            showInfoAlertProvider: { _, _ in alertExpectation.fulfill() }
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(
                duplicateProvider: { _ in throw NSError(domain: "test", code: 0) }
            ),
            coordinator: coordinator,
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When (find duplicate action and invoke)
        let configurations = viewModel.menuConfigurations.make(popoverAnchorProvider: { nil })
        let duplicateAction = configurations.compactMap { configuration -> JotMenuConfiguration.Action? in
            if case let .action(action) = configuration, action.systemImageName == "plus.square.on.square" {
                return action
            }
            return nil
        }.first
        try? XCTUnwrap(duplicateAction).handler()
        await Task.yield()

        // Then
        await fulfillment(of: [alertExpectation], timeout: 1)
    }

    func test_menuConfigurations_givenDuplicateActionSucceeds_invokesOpenJot() async {
        // Given
        let openJotExpectation = XCTestExpectation(description: "Coordinator.openJot is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let duplicatedInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note 1.jot"),
            name: "note 1",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = EditJotCoordinatorMock(
            openJotProvider: { received in
                XCTAssertEqual(received, duplicatedInfo)
                openJotExpectation.fulfill()
            }
        )
        let viewModel = EditJotViewModel(
            jotFileInfo: info,
            repository: EditJotRepositoryMock(
                duplicateProvider: { _ in duplicatedInfo }
            ),
            coordinator: coordinator,
            menuConfigurationFactory: JotMenuConfigurationFactory()
        )

        // When
        let configurations = viewModel.menuConfigurations.make(popoverAnchorProvider: { nil })
        let duplicateAction = configurations.compactMap { configuration -> JotMenuConfiguration.Action? in
            if case let .action(action) = configuration, action.systemImageName == "plus.square.on.square" {
                return action
            }
            return nil
        }.first
        try? XCTUnwrap(duplicateAction).handler()
        await Task.yield()

        // Then
        await fulfillment(of: [openJotExpectation], timeout: 1)
    }
}
