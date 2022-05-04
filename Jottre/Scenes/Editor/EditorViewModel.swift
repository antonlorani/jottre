final class EditorViewModel {
    private weak var coordinator: EditorCoordinator?

    init(coordinator: EditorCoordinator) {
        self.coordinator = coordinator
    }
}
