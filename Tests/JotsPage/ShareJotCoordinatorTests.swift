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
