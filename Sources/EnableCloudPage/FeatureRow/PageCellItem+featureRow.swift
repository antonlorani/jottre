extension PageCellItem {

    @MainActor
    static func featureRow(
        systemImageName: String,
        text: String
    ) -> PageCellItem {
        PageCellItem(
            id: systemImageName + text,
            cellType: FeatureRowCell.self,
            sizing: .fullWidth(estimatedHeight: 44),
            viewModel: FeatureRowCellViewModel(
                systemImageName: systemImageName,
                text: text
            )
        )
    }
}
