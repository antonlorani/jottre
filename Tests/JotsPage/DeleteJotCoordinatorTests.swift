import UIKit
import XCTest

@testable import Jottre

@MainActor
final class DeleteJotCoordinatorTests: XCTestCase {

    func test_start_givenInvoked_presentsAlertWithDestructiveDeleteAction() {
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
                    XCTAssertEqual(alert?.actions.last?.style, .destructive)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = DeleteJotCoordinator(
            jotFileInfo: info,
            navigation: navigation,
            repository: DeleteJotRepositoryMock()
        )

        // When
        coordinator.start()

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }

    func test_start_givenDeleteActionTapped_invokesRepositoryDeleteAndDismisses() {
        // Given
        let deleteExpectation = XCTestExpectation(description: "Repository.deleteJot is called.")
        let dismissExpectation = XCTestExpectation(description: "Navigation.dismiss is called.")
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
            },
            dismissViewControllerProvider: { _, _ in
                dismissExpectation.fulfill()
            }
        )
        let coordinator = DeleteJotCoordinator(
            jotFileInfo: info,
            navigation: navigation,
            repository: DeleteJotRepositoryMock(
                deleteJotProvider: { _ in deleteExpectation.fulfill() }
            )
        )

        // When
        coordinator.start()
        let destructive = alertController?.actions.first { $0.style == .destructive }
        destructive?.invokeHandler()

        // Then
        wait(for: [deleteExpectation, dismissExpectation], timeout: 1)
    }
}
