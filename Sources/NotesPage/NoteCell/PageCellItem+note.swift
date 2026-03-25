private struct NoteID: Sendable, Hashable {
    let note: NoteBusinessModel
    let infoText: String?
}

extension PageCellItem {

    @MainActor
    static func note(
        note: NoteBusinessModel,
        infoText: String?,
        noteMenuConfigurations: [NoteMenuConfiguration],
        sizing: PageCellSizingStrategy,
        onAction: @Sendable @escaping () -> Void
    ) -> PageCellItem {
        PageCellItem(
            id: NoteID(
                note: note,
                infoText: infoText
            ),
            cellType: NoteCell.self,
            sizing: sizing,
            viewModel: NoteCellViewModel(
                note: note,
                infoText: infoText,
                noteMenuConfigurations: noteMenuConfigurations,
                onAction: onAction
            )
        )
    }
}
