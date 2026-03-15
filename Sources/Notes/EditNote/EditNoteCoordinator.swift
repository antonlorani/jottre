import UIKit

final class EditNoteCoordinator: NavigationCoordinator {

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(EditNoteURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        [EditNoteViewController(viewModel: EditNoteViewModel(coordinator: self))]
    }
}
