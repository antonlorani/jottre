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
final class RenameJotCoordinatorTests: XCTestCase {

    func test_start_givenInvoked_presentsAlertWithCancelAndRenameActions() {
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
                    let alert = viewController as? UIAlertController
                    XCTAssertNotNil(alert)
                    XCTAssertEqual(alert?.actions.count, 2)
                    XCTAssertEqual(alert?.actions.first?.style, .cancel)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = RenameJotCoordinator(
            jotFileInfo: info,
            navigation: navigation,
            repository: RenameJotRepositoryMock(),
            onRename: { _ in }
        )

        // When
        coordinator.start()

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }

    func test_start_givenCancelTapped_invokesOnEnd() {
        // Given
        let onEndExpectation = XCTestExpectation(description: "RenameJotCoordinator.onEnd is invoked.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        var alertController: UIAlertController?
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    alertController = viewController as? UIAlertController
                }
            }
        )
        let coordinator = RenameJotCoordinator(
            jotFileInfo: info,
            navigation: navigation,
            repository: RenameJotRepositoryMock(),
            onRename: { _ in }
        )
        coordinator.onEnd = { onEndExpectation.fulfill() }

        // When
        coordinator.start()
        let cancelAction = alertController?.actions.first { $0.style == .cancel }
        cancelAction?.invokeHandler()

        // Then
        wait(for: [onEndExpectation], timeout: 1)
    }
}
