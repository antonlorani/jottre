import UIKit
import XCTest

@testable import Jottre

@MainActor
final class EditJotCoordinatorTests: XCTestCase {

    func test_shouldHandle_givenEditJotURL_returnsTrue() {
        // Given
        let coordinator = makeCoordinator()
        let url = EditJotURL(
            jotFileInfo: JotFile.Info(
                url: URL(staticString: "file:///tmp/note.jot"),
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        ).toURL()

        // Then
        XCTAssertTrue(coordinator.shouldHandle(url: url))
    }

    func test_shouldHandle_givenNonEditJotURL_returnsFalse() {
        // Given
        let coordinator = makeCoordinator()

        // Then
        XCTAssertFalse(coordinator.shouldHandle(url: URL(staticString: "https://example.com")))
    }

    func test_handle_givenValidURL_returnsViewControllerFromFactory() {
        // Given
        let madeViewController = UIViewController()
        let coordinator = makeCoordinator(
            editJotViewControllerFactory: EditJotViewControllerFactoryMock(
                makeProvider: { _, _ in madeViewController }
            )
        )
        let url = EditJotURL(
            jotFileInfo: JotFile.Info(
                url: URL(staticString: "file:///tmp/note.jot"),
                name: "note",
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        ).toURL()

        // When
        let viewControllers = coordinator.handle(url: url)

        // Then
        XCTAssertEqual(viewControllers, [madeViewController])
    }

    func test_handle_givenUnparsableURL_returnsEmpty() {
        // Given
        let coordinator = makeCoordinator()

        // When
        let viewControllers = coordinator.handle(url: URL(staticString: "https://example.com"))

        // Then
        XCTAssertTrue(viewControllers.isEmpty)
    }

    func test_openJot_givenInvoked_invokesNavigationOpenWithEditJotURL() {
        // Given
        let openExpectation = XCTestExpectation(description: "Navigation.open is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let navigation = Navigation.test(
            openURLProvider: { receivedURL in
                XCTAssertEqual(receivedURL, EditJotURL(jotFileInfo: info).toURL())
                openExpectation.fulfill()
            }
        )
        let coordinator = makeCoordinator(navigation: navigation)

        // When
        coordinator.openJot(jotFileInfo: info)

        // Then
        wait(for: [openExpectation], timeout: 1)
    }

    func test_canGoBack_givenMultipleViewControllers_returnsTrue() {
        // Given
        let navigation = Navigation.test(
            getViewControllersProvider: { [UIViewController(), UIViewController()] }
        )
        let coordinator = makeCoordinator(navigation: navigation)

        // Then
        XCTAssertTrue(coordinator.canGoBack())
    }

    func test_canGoBack_givenSingleViewController_returnsFalse() {
        // Given
        let navigation = Navigation.test(
            getViewControllersProvider: { [UIViewController()] }
        )
        let coordinator = makeCoordinator(navigation: navigation)

        // Then
        XCTAssertFalse(coordinator.canGoBack())
    }

    func test_goBack_givenInvoked_invokesNavigationPop() {
        // Given
        let popExpectation = XCTestExpectation(description: "Navigation.popViewController is called.")
        let navigation = Navigation.test(
            popViewControllerProvider: { animated in
                XCTAssertTrue(animated)
                popExpectation.fulfill()
            }
        )
        let coordinator = makeCoordinator(navigation: navigation)

        // When
        coordinator.goBack()

        // Then
        wait(for: [popExpectation], timeout: 1)
    }

    func test_showShareJot_givenInvoked_startsShareCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "ShareJot Coordinator.start is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = makeCoordinator(
            shareJotCoordinatorFactory: ShareJotCoordinatorFactoryMock(
                makeProvider: { _, _, _, _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.showShareJot(jotFileInfo: info, format: .pdf, configurePopoverAnchor: nil)

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    func test_openDeleteJot_givenInvoked_startsDeleteCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "DeleteJot Coordinator.start is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = makeCoordinator(
            deleteJotCoordinatorFactory: DeleteJotCoordinatorFactoryMock(
                makeProvider: { _, _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.openDeleteJot(jotFileInfo: info)

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    func test_showRenameAlert_givenInvoked_startsRenameCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "RenameJot Coordinator.start is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = makeCoordinator(
            renameJotCoordinatorFactory: RenameJotCoordinatorFactoryMock(
                makeProvider: { _, _, _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.showRenameAlert(jotFileInfo: info)

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    func test_showInFiles_givenInvoked_startsRevealFileCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "RevealFile Coordinator.start is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = makeCoordinator(
            revealFileCoordinatorFactory: RevealFileCoordinatorFactoryMock(
                makeProvider: { _, _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.showInFiles(jotFileInfo: info)

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    func test_showJotConflictPage_givenInvoked_startsJotConflictCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "JotConflict Coordinator.start is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = makeCoordinator(
            jotConflictCoordinatorFactory: JotConflictCoordinatorFactoryMock(
                makeProvider: { _, _, _, _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.showJotConflictPage(jotFileInfo: info, jotFileVersions: []) { _ in }

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    func test_showInfoAlert_givenInvoked_presentsAlertController() {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present is called.")
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    XCTAssertTrue(viewController is UIAlertController)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = makeCoordinator(navigation: navigation)

        // When
        coordinator.showInfoAlert(title: "title", message: "message")

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }

    private func makeCoordinator(
        navigation: Navigation = .test(),
        repository: EditJotRepositoryProtocol = EditJotRepositoryMock(),
        editJotViewControllerFactory: EditJotViewControllerFactoryProtocol = EditJotViewControllerFactoryMock(),
        jotConflictCoordinatorFactory: JotConflictCoordinatorFactoryProtocol = JotConflictCoordinatorFactoryMock(),
        renameJotCoordinatorFactory: RenameJotCoordinatorFactoryProtocol = RenameJotCoordinatorFactoryMock(),
        deleteJotCoordinatorFactory: DeleteJotCoordinatorFactoryProtocol = DeleteJotCoordinatorFactoryMock(),
        shareJotCoordinatorFactory: ShareJotCoordinatorFactoryProtocol = ShareJotCoordinatorFactoryMock(),
        revealFileCoordinatorFactory: RevealFileCoordinatorFactoryProtocol = RevealFileCoordinatorFactoryMock()
    ) -> EditJotCoordinator {
        EditJotCoordinator(
            navigation: navigation,
            repository: repository,
            editJotViewControllerFactory: editJotViewControllerFactory,
            jotConflictCoordinatorFactory: jotConflictCoordinatorFactory,
            renameJotCoordinatorFactory: renameJotCoordinatorFactory,
            deleteJotCoordinatorFactory: deleteJotCoordinatorFactory,
            shareJotCoordinatorFactory: shareJotCoordinatorFactory,
            revealFileCoordinatorFactory: revealFileCoordinatorFactory
        )
    }
}
