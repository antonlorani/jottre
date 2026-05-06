import XCTest

@testable import Jottre

@MainActor
final class CloudImageCellViewModelTests: XCTestCase {

    func test_handleAction_givenTap_doesNothing() {
        // Given
        let viewModel = CloudImageCellViewModel()

        // When
        viewModel.handle(action: .tap)

        // Then
        // No-op cell — the only assertion is that handling does not throw.
        XCTAssertNotNil(viewModel)
    }
}
