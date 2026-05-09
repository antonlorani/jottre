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
final class CloudMigrationCoordinatorTests: XCTestCase {

    func test_shouldStart_givenRepositoryReturnsTrue_returnsTrue() {
        // Given
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(getShouldShowCloudMigrationProvider: { true }),
            navigation: Navigation.test(),
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock(),
            logger: LoggerMock()
        )

        // Then
        XCTAssertTrue(coordinator.shouldStart())
    }

    func test_shouldStart_givenRepositoryReturnsFalse_returnsFalse() {
        // Given
        let coordinator = CloudMigrationCoordinator(
            repository: CloudMigrationRepositoryMock(getShouldShowCloudMigrationProvider: { false }),
            navigation: Navigation.test(),
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock(),
            logger: LoggerMock()
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
            ),
            logger: LoggerMock()
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
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock(),
            logger: LoggerMock()
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
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock(),
            logger: LoggerMock()
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
            cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactoryMock(),
            logger: LoggerMock()
        )

        // When
        coordinator.showInfoAlert(title: "title", message: "message")

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }
}
