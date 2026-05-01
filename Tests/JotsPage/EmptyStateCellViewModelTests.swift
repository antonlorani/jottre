import XCTest

@testable import Jottre

@MainActor
final class EmptyStateCellViewModelTests: XCTestCase {

    func test_init_storesTitle() {
        // When
        let viewModel = EmptyStateCellViewModel(title: "Nothing here yet")

        // Then
        XCTAssertEqual(viewModel.title, "Nothing here yet")
    }

    func test_handleContextMenuConfiguration_returnsNilByDefault() {
        // Given
        let viewModel = EmptyStateCellViewModel(title: "irrelevant")

        // When
        let configuration = viewModel.handleContextMenuConfiguration(
            point: .zero,
            sourceView: UIView()
        )

        // Then
        XCTAssertNil(configuration)
    }
}
