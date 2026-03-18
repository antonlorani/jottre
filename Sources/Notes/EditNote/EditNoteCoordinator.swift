import UIKit

final class EditNoteCoordinator: NavigationCoordinator {

    private var retainedShareNoteCoordinator: Coordinator?
    private var retainedDeleteNoteCoordinator: Coordinator?
    private var retainedRenameNoteCoordinator: Coordinator?

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

    func showShareNote(format: ShareFormat) {
        let coordinator = ShareNoteCoordinator(
            navigation: navigation,
            format: format
        )
        retainedShareNoteCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedShareNoteCoordinator = nil
        }
        coordinator.start()
    }

    func showRenameAlert() {
        let coordinator = RenameNoteCoordinator(navigation: navigation)
        retainedRenameNoteCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedRenameNoteCoordinator = nil
        }
        coordinator.start()
    }

    func showDeleteConfirmationAlert() {
        let coordinator = DeleteNoteCoordinator(navigation: navigation)
        retainedShareNoteCoordinator = coordinator
        coordinator.onEnd = { [weak self] in
            self?.retainedShareNoteCoordinator = nil
        }
        coordinator.start()
    }

    func showInFiles() {
        
    }
}
