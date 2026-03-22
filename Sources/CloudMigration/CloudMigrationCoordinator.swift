import UIKit

final class CloudMigrationCoordinator: NavigationCoordinator {

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(CloudMigrationURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        let navigationController = UINavigationController(
            rootViewController: CloudMigrationViewController(
                viewModel: CloudMigrationViewModel(coordinator: self)
            )
        )
        navigation.present(navigationController, animated: true)
        return []
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
