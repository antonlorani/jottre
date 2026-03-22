@MainActor
protocol CloudMigrationCoordinatorFactory: Sendable {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18CloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        CloudMigrationCoordinator(
            navigation: navigation,
            cloudMigrationViewControllerFactory: IOS18CloudMigrationViewControllerFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26CloudMigrationCoordinatorFactory: CloudMigrationCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        CloudMigrationCoordinator(
            navigation: navigation,
            cloudMigrationViewControllerFactory: IOS26CloudMigrationViewControllerFactory()
        )
    }
}
