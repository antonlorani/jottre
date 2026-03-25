extension PageCellItem {

    @MainActor
    static func notesEmptyState(title: String) -> PageCellItem {
        PageCellItem(
            id: title,
            cellType: EmptyStateCell.self,
            sizing: .fullWidth(estimatedHeight: 100),
            viewModel: EmptyStateCellViewModel(title: title)
        )
    }
}
