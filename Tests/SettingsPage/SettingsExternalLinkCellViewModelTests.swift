import XCTest

@testable import Jottre

@MainActor
final class SettingsExternalLinkCellViewModelTests: XCTestCase {

    func test_init_storesNameAndInfoFromBusinessModel() {
        // Given
        let businessModel = SettingsExternalLinkBusinessModel(name: "GitHub", info: "Open repository")

        // When
        let viewModel = SettingsExternalLinkCellViewModel(
            settingsExternalLink: businessModel,
            onAction: {}
        )

        // Then
        XCTAssertEqual(viewModel.name, "GitHub")
        XCTAssertEqual(viewModel.info, "Open repository")
    }

    func test_init_givenNilInfoBusinessModel_storesNilInfo() {
        // Given
        let businessModel = SettingsExternalLinkBusinessModel(name: "GitHub", info: nil)

        // When
        let viewModel = SettingsExternalLinkCellViewModel(
            settingsExternalLink: businessModel,
            onAction: {}
        )

        // Then
        XCTAssertNil(viewModel.info)
    }

    func test_handleAction_givenTap_invokesOnAction() async {
        // Given
        let onActionExpectation = XCTestExpectation(description: "onAction is called.")
        let viewModel = SettingsExternalLinkCellViewModel(
            settingsExternalLink: SettingsExternalLinkBusinessModel(name: "GitHub", info: nil),
            onAction: { onActionExpectation.fulfill() }
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        await fulfillment(of: [onActionExpectation], timeout: 0.2)
    }
}
