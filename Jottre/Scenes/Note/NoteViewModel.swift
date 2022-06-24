final class NoteViewModel {
    private weak var coordinator: NoteCoordinator?

    init(coordinator: NoteCoordinator) {
        self.coordinator = coordinator
    }

    func exportNoteDidTap() {
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
