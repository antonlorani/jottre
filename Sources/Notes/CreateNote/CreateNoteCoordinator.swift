import UIKit

final class CreateNoteCoordinator: NavigationCoordinator {

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(CreateNoteURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        []
    }
}
