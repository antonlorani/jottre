extension PageCellItem {

    @MainActor
    static func cloudMigrationNote(
        note: NoteBusinessModel
    ) -> PageCellItem {
        PageCellItem(
            id: note,
            cellType: CloudMigrationNoteCell.self,
            sizing: .fullWidth(estimatedHeight: 44),
            viewModel: CloudMigrationNoteCellViewModel(
                note: note
            )
        )
    }
}
