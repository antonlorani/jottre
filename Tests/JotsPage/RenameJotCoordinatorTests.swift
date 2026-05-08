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
