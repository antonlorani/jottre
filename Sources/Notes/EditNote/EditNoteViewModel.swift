@MainActor
final class EditNoteViewModel: Sendable {
    
    private weak var coordinator: EditNoteCoordinator?

    init(coordinator: EditNoteCoordinator) {
        self.coordinator = coordinator
    }
}
