@MainActor
final class NotesViewModel: Sendable {

    struct Item {
        let name: String
        let onAction: () -> Void
    }

    private weak var coordinator: NotesCoordinator?

    init(coordinator: NotesCoordinator) {
        self.coordinator = coordinator
    }

    func didTapSettingsButton() {
        coordinator?.openSettings()
    }

    func didTapAddButton() {
        coordinator?.openCreateNote()
    }
}
