extension PageCellItem {

    @MainActor
    static func settingsExternalLink(
        name: String,
        info: String?,
        onAction: @Sendable @escaping () -> Void
    ) -> PageCellItem {
        PageCellItem(
            id: name,
            cellType: SettingsExternalLinkCell.self,
            sizing: .fullWidth(estimatedHeight: 56),
            viewModel: SettingsExternalLinkCellViewModel(
                name: name,
                info: info,
                onAction: onAction
            )
        )
    }
}
