import XCTest

@testable import Jottre

@MainActor
final class SettingsInfoCellViewModelTests: XCTestCase {

    func test_init_storesNameAndValueFromBusinessModel() {
        // Given
        let businessModel = SettingsInfoBusinessModel(name: "Version", value: "1.0.0")

        // When
        let viewModel = SettingsInfoCellViewModel(settingsInfo: businessModel)

        // Then
        XCTAssertEqual(viewModel.name, "Version")
        XCTAssertEqual(viewModel.value, "1.0.0")
    }

    func test_handleAction_givenTap_doesNothing() {
        // Given
        let viewModel = SettingsInfoCellViewModel(
            settingsInfo: SettingsInfoBusinessModel(name: "Version", value: "1.0.0")
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        XCTAssertEqual(viewModel.value, "1.0.0")
    }
}
