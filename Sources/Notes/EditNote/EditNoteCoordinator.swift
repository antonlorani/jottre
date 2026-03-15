import UIKit

final class EditNoteCoordinator: NavigationCoordinator {

    private let navigation: Navigation
    private let editNoteViewControllerFactory: EditNoteViewControllerFactory

    init(
        navigation: Navigation,
        editNoteViewControllerFactory: EditNoteViewControllerFactory
    ) {
        self.navigation = navigation
        self.editNoteViewControllerFactory = editNoteViewControllerFactory
    }

    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(EditNoteURL().path)
    }

    func handle(url: URL) -> [UIViewController] {
        [
            editNoteViewControllerFactory.make(coordinator: self)
        ]
    }
}
