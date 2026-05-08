import UIKit
import XCTest

@testable import Jottre

@MainActor
final class JotsCoordinatorTests: XCTestCase {

    func test_shouldHandle_givenAnyURL_returnsTrue() {
        // Given
        let coordinator = makeCoordinator()

        // Then
        XCTAssertTrue(coordinator.shouldHandle(url: URL(staticString: "https://example.com")))
    }

    func test_handle_givenNonEditJotURL_returnsCachedJotsViewController() {
        // Given
        let madeViewController = UIViewController()
        let coordinator = makeCoordinator(
            jotsViewControllerFactory: JotsViewControllerFactoryMock(
                makeProvider: { _ in madeViewController }
            )
        )

        // When
        let viewControllers = coordinator.handle(url: URL(staticString: "https://example.com"))

        // Then
        XCTAssertEqual(viewControllers, [madeViewController])
    }

    func test_handle_givenEditJotURL_returnsJotsAndChildViewControllers() {
        // Given
        let madeViewController = UIViewController()
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let editJotURL = EditJotURL(jotFileInfo: info).toURL()
        let editJotViewController = UIViewController()
        let coordinator = makeCoordinator(
            jotsViewControllerFactory: JotsViewControllerFactoryMock(
                makeProvider: { _ in madeViewController }
            ),
            editJotCoordinatorFactory: EditJotCoordinatorFactoryMock(
                makeProvider: { _ in
                    NavigationCoordinatorMock(
                        shouldHandleProvider: { _ in true },
                        handleProvider: { _ in [editJotViewController] }
                    )
                }
            )
        )

        // When
        let viewControllers = coordinator.handle(url: editJotURL)

        // Then
        XCTAssertEqual(viewControllers, [madeViewController, editJotViewController])
    }

    func test_openSettings_givenInvoked_startsSettingsCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "SettingsCoordinator.start is called.")
        let coordinator = makeCoordinator(
            settingsCoordinatorFactory: SettingsCoordinatorFactoryMock(
                makeProvider: { _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.openSettings()

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    func test_openCreateJot_givenInvoked_startsCreateJotCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "CreateJotCoordinator.start is called.")
        let coordinator = makeCoordinator(
            createJotCoordinatorFactory: CreateJotCoordinatorFactoryMock(
                makeProvider: { _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.openCreateJot()

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    func test_openEnableCloudPage_givenInvoked_startsEnableCloudCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "EnableCloudCoordinator.start is called.")
        let coordinator = makeCoordinator(
            enableCloudCoordinatorFactory: EnableCloudCoordinatorFactoryMock(
                makeProvider: { _ in
                    CoordinatorMock(startProvider: { startExpectation.fulfill() })
                }
            )
        )

        // When
        coordinator.openEnableCloudPage()

        // Then
        wait(for: [startExpectation], timeout: 1)
    }

    #if !targetEnvironment(macCatalyst)
    func test_openJot_givenPrefersNewWindow_invokesNavigationOpenScene() {
        // Given
        let openSceneExpectation = XCTestExpectation(description: "Navigation.openScene is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let navigation = Navigation.test(
            openSceneProvider: { receivedURL in
                XCTAssertEqual(receivedURL, EditJotURL(jotFileInfo: info).toURL())
                openSceneExpectation.fulfill()
            }
        )
        let coordinator = makeCoordinator(navigation: navigation)

        // When
        coordinator.openJot(jotFileInfo: info, prefersNewWindow: true)

        // Then
        wait(for: [openSceneExpectation], timeout: 1)
    }

    func test_openJot_givenPrefersSameWindow_invokesNavigationOpen() {
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
        coordinator.openJot(jotFileInfo: info, prefersNewWindow: false)

        // Then
        wait(for: [openExpectation], timeout: 1)
    }
    #endif

    func test_openDeleteJot_givenInvoked_startsDeleteJotCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "DeleteJotCoordinator.start is called.")
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

    func test_showRenameAlert_givenInvoked_startsRenameJotCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "RenameJotCoordinator.start is called.")
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

    func test_showShareJot_givenInvoked_startsShareJotCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "ShareJotCoordinator.start is called.")
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

    func test_showInFiles_givenInvoked_startsRevealFileCoordinator() {
        // Given
        let startExpectation = XCTestExpectation(description: "RevealFileCoordinator.start is called.")
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
        jotsViewControllerFactory: JotsViewControllerFactoryProtocol = JotsViewControllerFactoryMock(),
        settingsCoordinatorFactory: SettingsCoordinatorFactoryProtocol = SettingsCoordinatorFactoryMock(),
        enableCloudCoordinatorFactory: EnableCloudCoordinatorFactoryProtocol = EnableCloudCoordinatorFactoryMock(),
        editJotCoordinatorFactory: EditJotCoordinatorFactoryProtocol = EditJotCoordinatorFactoryMock(),
        cloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactoryProtocol =
            CloudMigrationCoordinatorFactoryMock(),
        createJotCoordinatorFactory: CreateJotCoordinatorFactoryProtocol = CreateJotCoordinatorFactoryMock(),
        deleteJotCoordinatorFactory: DeleteJotCoordinatorFactoryProtocol = DeleteJotCoordinatorFactoryMock(),
        renameJotCoordinatorFactory: RenameJotCoordinatorFactoryProtocol = RenameJotCoordinatorFactoryMock(),
        shareJotCoordinatorFactory: ShareJotCoordinatorFactoryProtocol = ShareJotCoordinatorFactoryMock(),
        revealFileCoordinatorFactory: RevealFileCoordinatorFactoryProtocol = RevealFileCoordinatorFactoryMock()
    ) -> JotsCoordinator {
        JotsCoordinator(
            navigation: navigation,
            jotsViewControllerFactory: jotsViewControllerFactory,
            settingsCoordinatorFactory: settingsCoordinatorFactory,
            enableCloudCoordinatorFactory: enableCloudCoordinatorFactory,
            editJotCoordinatorFactory: editJotCoordinatorFactory,
            cloudMigrationCoordinatorFactory: cloudMigrationCoordinatorFactory,
            createJotCoordinatorFactory: createJotCoordinatorFactory,
            deleteJotCoordinatorFactory: deleteJotCoordinatorFactory,
            renameJotCoordinatorFactory: renameJotCoordinatorFactory,
            shareJotCoordinatorFactory: shareJotCoordinatorFactory,
            revealFileCoordinatorFactory: revealFileCoordinatorFactory
        )
    }
}
