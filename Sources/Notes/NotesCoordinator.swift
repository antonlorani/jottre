import UIKit

@MainActor
final class NotesCoordinator: NavigationCoordinator {

    private var retainedShareNoteCoordinator: Coordinator?
    private var retainedDeleteNoteCoordinator: Coordinator?
    private var retainedRenameNoteCoordinator: Coordinator?
    private var retainedNotesViewController: UIViewController?

    private lazy var childCoordinators: [NavigationCoordinator] = [
        settingsCoordinatorFactory.make(navigation: navigation),
        enableCloudCoordinatorFactory.make(navigation: navigation),
        CreateNoteCoordinator(navigation: navigation),
        editNoteCoordinatorFactory.make(navigation: navigation),
        CloudMigrationCoordinator(navigation: navigation)
    ]

    private let navigation: Navigation
    private let notesViewControllerFactory: NotesViewControllerFactory
    private let settingsCoordinatorFactory: SettingsCoordinatorFactory
    private let enableCloudCoordinatorFactory: EnableCloudCoordinatorFactory
    private let editNoteCoordinatorFactory: EditNoteCoordinatorFactory

    init(
        navigation: Navigation,
        notesViewControllerFactory: NotesViewControllerFactory,
        settingsCoordinatorFactory: SettingsCoordinatorFactory,
        enableCloudCoordinatorFactory: EnableCloudCoordinatorFactory,
        editNoteCoordinatorFactory: EditNoteCoordinatorFactory
    ) {
        self.navigation = navigation
        self.notesViewControllerFactory = notesViewControllerFactory
        self.settingsCoordinatorFactory = settingsCoordinatorFactory
        self.enableCloudCoordinatorFactory = enableCloudCoordinatorFactory
        self.editNoteCoordinatorFactory = editNoteCoordinatorFactory
    }

    func shouldHandle(url: URL) -> Bool {
        true
    }

    func handle(url: URL) -> [UIViewController] {
        var viewControllers: [UIViewController]

        if let retainedNotesViewController {
            viewControllers = [retainedNotesViewController]
        } else {
            let notesViewController = notesViewControllerFactory.make(coordinator: self)
            self.retainedNotesViewController = notesViewController
            viewControllers = [notesViewController]
        }

        if let childCoordinator = childCoordinators.first(where: { $0.shouldHandle(url: url) }) {
            viewControllers.append(contentsOf: childCoordinator.handle(url: url))
        }

        return viewControllers
    }

    func openSettings() {
        navigation.open(url: SettingsURL())
    }

    func openCreateNote() {
        navigation.open(url: CreateNoteURL())
    }

    func openNote(_ note: NoteBusinessModel) {
        navigation.open(url: EditNoteURL())
    }

    func openEnableCloudPage() {
        navigation.open(url: EnableCloudURL())
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
