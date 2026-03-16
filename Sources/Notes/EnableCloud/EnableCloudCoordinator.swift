import UIKit

final class EnableCloudCoordinator: NavigationCoordinator {

    private let navigation: Navigation
    private let enableCloudViewControllerFactory: EnableCloudViewControllerFactory

    init(navigation: Navigation, enableCloudViewControllerFactory: EnableCloudViewControllerFactory) {
        self.navigation = navigation
        self.enableCloudViewControllerFactory = enableCloudViewControllerFactory
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(EnableCloudURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        let navigationController = UINavigationController(
            rootViewController: enableCloudViewControllerFactory.make(coordinator: self)
        )
        navigation.present(navigationController, animated: true)
        return []
    }

    func openLearnHowToEnable() {
        navigation.open(url: EnableICloudSupportURL().toURL())
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
