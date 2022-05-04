final class PreferencesViewModel {
    private weak var coordinator: PreferencesCoordinator?

    init(coordinator: PreferencesCoordinator) {
        self.coordinator = coordinator
    }
}
