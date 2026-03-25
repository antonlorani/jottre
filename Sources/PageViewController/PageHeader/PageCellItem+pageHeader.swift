extension PageCellItem {

    @MainActor
    static func pageHeader(
        headline: String,
        subheadline: String
    ) -> PageCellItem {
        PageCellItem(
            id: headline + subheadline,
            cellType: PageHeaderCell.self,
            sizing: .fullWidth(estimatedHeight: 100),
            viewModel: PageHeaderCellViewModel(
                headline: headline,
                subheadline: subheadline
            )
        )
    }
}
