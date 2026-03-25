import UIKit

final class NoteCellViewModel: PageCellViewModel {

    let note: NoteBusinessModel
    let infoText: String?
    let noteMenuConfigurations: [NoteMenuConfiguration]
    let onAction: @Sendable () -> Void

    init(
        note: NoteBusinessModel,
        infoText: String?,
        noteMenuConfigurations: [NoteMenuConfiguration],
        onAction: @Sendable @escaping () -> Void
    ) {
        self.note = note
        self.infoText = infoText
        self.noteMenuConfigurations = noteMenuConfigurations
        self.onAction = onAction
    }

    func handle(action: PageCellAction) {
        switch action {
        case .tap: onAction()
        }
    }

    func handleContextMenuConfiguration() -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self else {
                return nil
            }
            return UIMenu.make(noteMenuConfigurations: noteMenuConfigurations)
        }
    }
}
