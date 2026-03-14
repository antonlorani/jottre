import UIKit

protocol NavigationCoordinator: Sendable {

    func handleDeepLink(_ deepLink: URL) -> [UIViewController]
}

final class RootCoordinator: NavigationCoordinator {

    func handleDeepLink(_ deepLink: URL) -> [UIViewController] {
        [RootViewController(viewModel: RootViewModel(coordinator: self))]
    }
}
