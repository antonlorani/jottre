extension PageCellItem {

    @MainActor
    static func notesEmptyState(title: String) -> PageCellItem {
        PageCellItem(
            id: title,
            cellType: EmptyStateCell.self,
            sizing: .fullWidth(estimatedHeight: 50),
            viewModel: EmptyStateCellViewModel(title: title)
        )
    }
}
