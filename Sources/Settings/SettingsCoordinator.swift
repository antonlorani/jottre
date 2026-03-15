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

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(SettingsURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        let navigationController = UINavigationController(
            rootViewController: settingsViewControllerFactory.make(coordinator: self)
        )
        navigationController.navigationBar.prefersLargeTitles = true
        navigation.present(navigationController, animated: true)
        return []
    }

    func openExternalLink(url: URL) {
        navigation.open(url: url)
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
