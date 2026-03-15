import UIKit

final class CreateNoteCoordinator: NavigationCoordinator {

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func shouldHandle(url: URL) -> Bool {
        false
    }

    func handle(url: URL) -> [UIViewController] {
        []
    }
}
