import UIKit

final class CreateNoteCoordinator: NavigationCoordinator {

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func shouldHandle(deepLink: DeepLink) -> Bool {
        false
    }

    func handle(deepLink: DeepLink) -> [UIViewController] {
        []
    }
}
