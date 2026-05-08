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
