import UIKit
import XCTest

@testable import Jottre

@MainActor
final class CloudMigrationCoordinatorTests: XCTestCase {

    func test_shouldStart_givenRepositoryReturnsTrue_returnsTrue() {
        // Given
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(getShouldShowCloudMigrationProvider: { true }),
            navigation: Navigation.test(),
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock()
        )

        // Then
        XCTAssertTrue(coordinator.shouldStart())
    }

    func test_shouldStart_givenRepositoryReturnsFalse_returnsFalse() {
        // Given
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(getShouldShowCloudMigrationProvider: { false }),
            navigation: Navigation.test(),
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock()
        )

        // Then
        XCTAssertFalse(coordinator.shouldStart())
    }

    func test_start_givenInvoked_presentsNavigationControllerWithFactoryProducedRoot() {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present is called.")
        let madeViewController = UIViewController()
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    let navigationController = viewController as? UINavigationController
                    XCTAssertEqual(navigationController?.viewControllers.first, madeViewController)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(),
            navigation: navigation,
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock(
                makeProvider: { _ in madeViewController }
            )
        )

        // When
        coordinator.start()

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }

    func test_dismiss_givenInvoked_invokesNavigationDismiss() {
        // Given
        let dismissExpectation = XCTestExpectation(description: "Navigation.dismiss is called.")
        let navigation = Navigation.test(
            dismissViewControllerProvider: { _, _ in dismissExpectation.fulfill() }
        )
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(),
            navigation: navigation,
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock()
        )

        // When
        coordinator.dismiss()

        // Then
        wait(for: [dismissExpectation], timeout: 1)
    }

    func test_dismiss_givenCompletion_invokesOnEnd() async {
        // Given
        let onEndExpectation = XCTestExpectation(description: "CloudMigrationCoordinator.onEnd is called.")
        let navigation = Navigation.test(
            dismissViewControllerProvider: { _, completion in
                completion?()
            }
        )
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(),
            navigation: navigation,
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock()
        )
        coordinator.onEnd = { onEndExpectation.fulfill() }

        // When
        coordinator.dismiss()

        // Then
        await fulfillment(of: [onEndExpectation], timeout: 1)
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
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(),
            navigation: navigation,
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock()
        )

        // When
        coordinator.showInfoAlert(title: "title", message: "message")

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }
}
