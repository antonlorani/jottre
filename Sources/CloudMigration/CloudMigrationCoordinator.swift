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
        navigation.present(CloudMigrationViewController(
            viewModel: CloudMigrationViewModel(coordinator: self)
        ), animated: true)
        return []
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
