@MainActor
final class CreateNoteViewModel: Sendable {
    
    private weak var coordinator: CreateNoteCoordinator?

    init(coordinator: CreateNoteCoordinator) {
        self.coordinator = coordinator
    }
}
