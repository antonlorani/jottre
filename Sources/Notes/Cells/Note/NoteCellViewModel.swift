final class NoteCellViewModel: PageCellViewModel {

    let note: NoteBusinessModel
    let infoText: String?

    init(
        note: NoteBusinessModel,
        infoText: String?
    ) {
        self.note = note
        self.infoText = infoText
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
