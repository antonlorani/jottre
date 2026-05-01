import XCTest

@testable import Jottre

@MainActor
final class PageHeaderCellViewModelTests: XCTestCase {

    func test_init_storesHeadlineAndSubheadline() {
        // When
        let viewModel = PageHeaderCellViewModel(
            headline: "Headline",
            subheadline: "Subheadline"
        )

        // Then
        XCTAssertEqual(viewModel.headline, "Headline")
        XCTAssertEqual(viewModel.subheadline, "Subheadline")
    }
}
