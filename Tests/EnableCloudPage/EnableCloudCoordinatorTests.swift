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
final class EnableCloudCoordinatorTests: XCTestCase {

    func test_start_givenInvoked_presentsNavigationControllerWithFactoryProducedRoot() {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present is called.")
        let madeViewController = UIViewController()
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, animated in
                MainActor.assumeIsolated {
                    // Then
                    XCTAssertTrue(viewController is UINavigationController)
                    let navigationController = viewController as? UINavigationController
                    XCTAssertEqual(navigationController?.viewControllers.first, madeViewController)
                    XCTAssertTrue(animated)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = EnableCloudCoordinator(
            navigation: navigation,
            enableCloudViewControllerFactory: EnableCloudViewControllerFactoryMock(
                makeProvider: { _ in madeViewController }
            )
        )

        // When
        coordinator.start()

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }

    func test_openLearnHowToEnable_givenInvoked_invokesNavigationOpenExternalWithSupportURL() {
        // Given
        let openExpectation = XCTestExpectation(description: "Navigation.openExternal is called.")
        let navigation = Navigation.test(
            openExternalURLProvider: { receivedURL in
                // Then
                XCTAssertEqual(receivedURL, EnableICloudSupportURL().toURL())
                openExpectation.fulfill()
            }
        )
        let coordinator = EnableCloudCoordinator(
            navigation: navigation,
            enableCloudViewControllerFactory: EnableCloudViewControllerFactoryMock()
        )

        // When
        coordinator.openLearnHowToEnable()

        // Then
        wait(for: [openExpectation], timeout: 1)
    }

    func test_dismiss_givenInvoked_invokesNavigationDismissAnimated() {
        // Given
        let dismissExpectation = XCTestExpectation(description: "Navigation.dismiss is called.")
        let navigation = Navigation.test(
            dismissViewControllerProvider: { animated, _ in
                // Then
                XCTAssertTrue(animated)
                dismissExpectation.fulfill()
            }
        )
        let coordinator = EnableCloudCoordinator(
            navigation: navigation,
            enableCloudViewControllerFactory: EnableCloudViewControllerFactoryMock()
        )

        // When
        coordinator.dismiss()

        // Then
        wait(for: [dismissExpectation], timeout: 1)
    }

    func test_dismiss_givenCompletion_invokesOnEnd() async {
        // Given
        let onEndExpectation = XCTestExpectation(description: "EnableCloudCoordinator.onEnd is called.")
        let navigation = Navigation.test(
            dismissViewControllerProvider: { _, completion in
                completion?()
            }
        )
        let coordinator = EnableCloudCoordinator(
            navigation: navigation,
            enableCloudViewControllerFactory: EnableCloudViewControllerFactoryMock()
        )
        coordinator.onEnd = { onEndExpectation.fulfill() }

        // When
        coordinator.dismiss()

        // Then
        await fulfillment(of: [onEndExpectation], timeout: 1)
    }
}
