extension PageCellItem {

    @MainActor
    static func cloudMigrationNote(
        note: NoteBusinessModel
    ) -> PageCellItem {
        PageCellItem(
            id: note,
            cellType: CloudMigrationNoteCell.self,
            sizing: .fullWidth(estimatedHeight: 56),
            viewModel: CloudMigrationNoteCellViewModel(
                note: note
            )
        )
    }
}
