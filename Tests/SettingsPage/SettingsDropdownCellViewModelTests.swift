import XCTest

@testable import Jottre

@MainActor
final class SettingsDropdownCellViewModelTests: XCTestCase {

    func test_init_storesNameCurrentAndOptionsFromBusinessModel() {
        // Given
        let light = SettingsDropdownBusinessModel.Option(label: "Light", value: "light")
        let dark = SettingsDropdownBusinessModel.Option(label: "Dark", value: "dark")
        let businessModel = SettingsDropdownBusinessModel(
            name: "Appearance",
            current: light,
            options: [light, dark]
        )

        // When
        let viewModel = SettingsDropdownCellViewModel(
            settingsDropdown: businessModel,
            onAction: { _ in }
        )

        // Then
        XCTAssertEqual(viewModel.name, "Appearance")
        XCTAssertEqual(viewModel.current, light)
        XCTAssertEqual(viewModel.options, [light, dark])
    }

    func test_handleAction_givenTap_doesNotInvokeOnAction() async {
        // Given
        let onActionExpectation = XCTestExpectation(description: "onAction is not called for .tap")
        onActionExpectation.isInverted = true
        let option = SettingsDropdownBusinessModel.Option(label: "Light", value: "light")
        let viewModel = SettingsDropdownCellViewModel(
            settingsDropdown: SettingsDropdownBusinessModel(
                name: "Appearance",
                current: option,
                options: [option]
            ),
            onAction: { _ in onActionExpectation.fulfill() }
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        await fulfillment(of: [onActionExpectation], timeout: 0.05)
    }
}
