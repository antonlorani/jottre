import UIKit
import XCTest

@testable import Jottre

@MainActor
final class CreateJotCoordinatorTests: XCTestCase {

    func test_start_givenInvoked_presentsAlertWithTitleAndCreateAndCancelActions() {
        // Given
        let presentExpectation = XCTestExpectation(description: "Navigation.present is called.")
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    let alert = viewController as? UIAlertController
                    XCTAssertNotNil(alert)
                    XCTAssertEqual(alert?.actions.count, 2)
                    XCTAssertEqual(alert?.actions.last?.style, .cancel)
                    presentExpectation.fulfill()
                }
            }
        )
        let coordinator = CreateJotCoordinator(
            navigation: navigation,
            repository: CreateJotRepositoryMock()
        )

        // When
        coordinator.start()

        // Then
        wait(for: [presentExpectation], timeout: 1)
    }

    func test_start_givenCancelTapped_invokesOnEnd() {
        // Given
        let onEndExpectation = XCTestExpectation(description: "CreateJotCoordinator.onEnd is invoked.")
        var alertController: UIAlertController?
        let navigation = Navigation.test(
            presentViewControllerProvider: { viewController, _ in
                MainActor.assumeIsolated {
                    alertController = viewController as? UIAlertController
                }
            }
        )
        let coordinator = CreateJotCoordinator(
            navigation: navigation,
            repository: CreateJotRepositoryMock()
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
