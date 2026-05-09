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

import XCTest

@testable import Jottre

@MainActor
final class RevealFileCoordinatorTests: XCTestCase {

    func test_start_givenInvoked_invokesApplicationServiceOpenWithRevealFileURL() {
        // Given
        let openExpectation = XCTestExpectation(description: "ApplicationService.open is called.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = RevealFileCoordinator(
            jotFileInfo: info,
            applicationService: ApplicationServiceMock(
                openProvider: { receivedURL in
                    XCTAssertEqual(receivedURL, RevealFileURL(jotFileInfo: info).toURL())
                    openExpectation.fulfill()
                }
            )
        )

        // When
        coordinator.start()

        // Then
        wait(for: [openExpectation], timeout: 1)
    }

    func test_start_givenInvoked_invokesOnEnd() {
        // Given
        let onEndExpectation = XCTestExpectation(description: "RevealFileCoordinator.onEnd is invoked.")
        let info = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let coordinator = RevealFileCoordinator(
            jotFileInfo: info,
            applicationService: ApplicationServiceMock()
        )
        coordinator.onEnd = { onEndExpectation.fulfill() }

        // When
        coordinator.start()

        // Then
        wait(for: [onEndExpectation], timeout: 1)
    }
}
