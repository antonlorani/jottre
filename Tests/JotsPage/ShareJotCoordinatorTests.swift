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
final class ShareJotCoordinatorTests: XCTestCase {

    func test_start_givenSuccessfulExport_presentsActivityViewController() async {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present(activity) is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    if viewController is UIActivityViewController {
                        presentExpectation.fulfill()
                    }
                }
            }
        )
        let coordinator = ShareJotCoordinator(
            jotFileInfo: info,
            format: .pdf,
            navigation: navigation,
            repository: ShareJotRepositoryMock(
                exportJotProvider: { _, _ in URL(fileURLWithPath: "/tmp/share.pdf") }
            ),
            configurePopoverAnchor: { _ in }
        )

        // When
        coordinator.start()

        // Then
        await fulfillment(of: [presentExpectation], timeout: 5)
    }

    func test_start_givenExportThrows_presentsAlertController() async {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present(alert) is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    if viewController is UIAlertController {
                        presentExpectation.fulfill()
                    }
                }
            }
        )
        let coordinator = ShareJotCoordinator(
            jotFileInfo: info,
            format: .pdf,
            navigation: navigation,
            repository: ShareJotRepositoryMock(
                exportJotProvider: { _, _ in throw NSError(domain: "test", code: 0) }
            ),
            configurePopoverAnchor: { _ in }
        )

        // When
        coordinator.start()

        // Then
        await fulfillment(of: [presentExpectation], timeout: 5)
    }
}
