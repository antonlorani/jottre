extension PageCellItem {

    @MainActor
    static func settingsInfo(
        name: String,
        value: String
    ) -> PageCellItem {
        PageCellItem(
            id: name,
            cellType: SettingsInfoCell.self,
            sizing: .fullWidth(estimatedHeight: 56),
            viewModel: SettingsInfoCellViewModel(name: name, value: value)
        )
    }
}
