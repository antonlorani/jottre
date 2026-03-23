final class NoteCellViewModel: PageCellViewModel {

    let note: NoteBusinessModel
    let infoText: String?
    let onAction: @Sendable () -> Void

    init(
        note: NoteBusinessModel,
        infoText: String?,
        onAction: @Sendable @escaping () -> Void
    ) {
        self.note = note
        self.infoText = infoText
        self.onAction = onAction
    }

    func handle(action: PageCellAction) {
        switch action {
        case .tap: onAction()
        }
    }
}
