final class NoteViewModel {
    private weak var coordinator: NoteCoordinator?

    let navigationTitle: String

    init(
        coordinator: NoteCoordinator,
        noteBusinessModel: NoteBusinessModel
    ) {
        self.coordinator = coordinator
        navigationTitle = noteBusinessModel.name
    }

    func didClickExportNote() {
        weak var `self` = self
        coordinator?.showExportNoteAlert(
            onPDFSelected: {
                
            },
            onJPGSelected: {

            },
            onPNGSelected: {

            }
        )
    }
}
