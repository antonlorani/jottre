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
final class JotConflictCoordinatorTests: XCTestCase {

    func test_start_givenInvoked_presentsModalNavigationController() {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present is called.")
        let madeViewController = UIViewController()
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    let navigationController = viewController as? UINavigationController
                    XCTAssertEqual(navigationController?.viewControllers.first, madeViewController)
                    XCTAssertTrue(madeViewController.isModalInPresentation)
                    XCTAssertFalse(navigationController?.navigationBar.prefersLargeTitles ?? true)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = JotConflictCoordinator(
            jotFileInfo: info,
            jotFileVersions: [JotFileVersion(localizedNameOfSavingComputer: "Mac", info: info)],
            repository: JotConflictRepositoryMock(),
            navigation: navigation,
            jotConflictViewControllerFactory: JotConflictViewControllerFactoryMock(
                makeProvider: { _ in madeViewController }
            ),
            onResult: { _ in }
        )

        // When
        coordinator.start()

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }

    func test_dismiss_givenCompletion_invokesNavigationDismissAndOnEnd() async {
        // Given
        let completionExpectation = XCTestExpectation(description: "Completion is invoked.")
        let onEndExpectation = XCTestExpectation(description: "JotConflictCoordinator.onEnd is invoked.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let navigation = Navigation.test(
            dismissViewControllerProvider: { _, completion in
                completion?()
            }
        )
        let coordinator = JotConflictCoordinator(
            jotFileInfo: info,
            jotFileVersions: [],
            repository: JotConflictRepositoryMock(),
            navigation: navigation,
            jotConflictViewControllerFactory: JotConflictViewControllerFactoryMock(),
            onResult: { _ in }
        )
        coordinator.onEnd = { onEndExpectation.fulfill() }

        // When
        coordinator.dismiss(completion: { completionExpectation.fulfill() })

        // Then
        await fulfillment(of: [completionExpectation, onEndExpectation], timeout: 1)
    }

    func test_showInfoAlert_givenInvoked_presentsAlertController() {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    XCTAssertTrue(viewController is UIAlertController)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = JotConflictCoordinator(
            jotFileInfo: info,
            jotFileVersions: [],
            repository: JotConflictRepositoryMock(),
            navigation: navigation,
            jotConflictViewControllerFactory: JotConflictViewControllerFactoryMock(),
            onResult: { _ in }
        )

        // When
        coordinator.showInfoAlert(title: "title", message: "message")

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }
}
