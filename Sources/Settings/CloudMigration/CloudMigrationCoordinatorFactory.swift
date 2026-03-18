@MainActor
protocol CloudMigrationCoordinatorFactory: Sendable {
    
    func make(navigation: Navigation) -> NavigationCoordinator
}
