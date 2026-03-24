extension PageCellItem {

    @MainActor
    static func settingsToggle(
        name: String,
        isOn: Bool
    ) -> PageCellItem {
        PageCellItem(
            id: name,
            cellType: SettingsToggleCell.self,
            sizing: .fullWidth(estimatedHeight: 56),
            viewModel: SettingsToggleCellViewModel(name: name, isOn: isOn)
        )
    }
}
