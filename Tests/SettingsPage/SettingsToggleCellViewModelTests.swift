import XCTest

@testable import Jottre

@MainActor
final class SettingsToggleCellViewModelTests: XCTestCase {

    func test_init_storesNameAndIsOnFromBusinessModel() {
        // Given
        let businessModel = SettingsToggleBusinessModel(name: "iCloud", isOn: true)

        // When
        let viewModel = SettingsToggleCellViewModel(settingsToggle: businessModel)

        // Then
        XCTAssertEqual(viewModel.name, "iCloud")
        XCTAssertTrue(viewModel.isOn)
    }

    func test_handleAction_givenTap_doesNothing() {
        // Given
        let viewModel = SettingsToggleCellViewModel(
            settingsToggle: SettingsToggleBusinessModel(name: "iCloud", isOn: false)
        )

        // When
        viewModel.handle(action: .tap)

        // Then
        XCTAssertFalse(viewModel.isOn)
    }
}
