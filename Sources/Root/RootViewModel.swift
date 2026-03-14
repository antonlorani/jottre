final class RootViewModel: Sendable {
    
    private weak var coordinator: RootCoordinator?
    
    init(coordinator: RootCoordinator) {
        self.coordinator = coordinator
    }
}
