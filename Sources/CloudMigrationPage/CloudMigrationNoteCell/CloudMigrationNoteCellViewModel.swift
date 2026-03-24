import UIKit

final class CloudMigrationNoteCellViewModel: PageCellViewModel {

    let note: NoteBusinessModel

    init(note: NoteBusinessModel) {
        self.note = note
    }

    func handle(action: PageCellAction) {
        /* no-op */
    }
}
