import XCTest

@testable import Jottre

@MainActor
final class FeatureRowCellViewModelTests: XCTestCase {

    func test_init_storesSystemImageNameAndText() {
        // When
        let viewModel = FeatureRowCellViewModel(
            systemImageName: "icloud",
            text: "Sync across devices"
        )

        // Then
        XCTAssertEqual(viewModel.systemImageName, "icloud")
        XCTAssertEqual(viewModel.text, "Sync across devices")
    }
}
