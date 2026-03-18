@MainActor
final class CloudMigrationViewModel: Sendable {

    private weak var coordinator: CloudMigrationCoordinator?

    init(coordinator: CloudMigrationCoordinator) {
        self.coordinator = coordinator
    }
}
