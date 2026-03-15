import UIKit

final class SettingsCoordinator: NavigationCoordinator {

    private let navigation: Navigation
    private let settingsViewControllerFactory: SettingsViewControllerFactory

    init(
        navigation: Navigation,
        settingsViewControllerFactory: SettingsViewControllerFactory
    ) {
        self.navigation = navigation
        self.settingsViewControllerFactory = settingsViewControllerFactory
    }

    func shouldHandle(deepLink: DeepLink) -> Bool {
        deepLink.path.hasPrefix(SettingsDeepLink().path)
    }

    func handle(deepLink: DeepLink) -> [UIViewController] {
        let navigationController = UINavigationController(
            rootViewController: settingsViewControllerFactory.make(coordinator: self)
        )
        navigationController.navigationBar.prefersLargeTitles = true
        navigation.present(navigationController, animated: true)
        return []
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
