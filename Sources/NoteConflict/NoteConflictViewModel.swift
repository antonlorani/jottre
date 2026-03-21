import Foundation

@MainActor
final class NoteConflictViewModel: Sendable {

    private weak var coordinator: NoteConflictCoordinator?

    init(coordinator: NoteConflictCoordinator) {
        self.coordinator = coordinator
    }
}
