extension PageCellItem {

    @MainActor
    static func settingsDropdown(
        name: String,
        current: SettingsDropdownBusinessModel.Option,
        options: [SettingsDropdownBusinessModel.Option],
        onAction: @Sendable @escaping (SettingsDropdownBusinessModel.Option) -> Void
    ) -> PageCellItem {
        PageCellItem(
            id: name,
            cellType: SettingsDropdownCell.self,
            sizing: .fullWidth(estimatedHeight: 56),
            viewModel: SettingsDropdownCellViewModel(
                name: name,
                current: current,
                options: options,
                onAction: onAction
            )
        )
    }
}
