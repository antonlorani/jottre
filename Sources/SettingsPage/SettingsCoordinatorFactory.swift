@MainActor
protocol SettingsCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18SettingsCoordinatorFactory: SettingsCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        SettingsCoordinator(
            navigation: navigation,
            settingsViewControllerFactory: IOS18SettingsViewControllerFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26SettingsCoordinatorFactory: SettingsCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        SettingsCoordinator(
            navigation: navigation,
            settingsViewControllerFactory: IOS26SettingsViewControllerFactory()
        )
    }
}
