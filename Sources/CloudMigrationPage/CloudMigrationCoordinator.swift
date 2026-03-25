import UIKit

final class CloudMigrationCoordinator: NavigationCoordinator {

    private let navigation: Navigation
    private let cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory

    init(
        navigation: Navigation,
        cloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory
    ) {
        self.navigation = navigation
        self.cloudMigrationViewControllerFactory = cloudMigrationViewControllerFactory
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(CloudMigrationURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        let navigationController = UINavigationController(
            rootViewController: cloudMigrationViewControllerFactory.make(coordinator: self)
        )
        navigation.present(navigationController, animated: true)
        return []
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
