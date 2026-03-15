import UIKit

@MainActor
final class NotesCoordinator: NavigationCoordinator {

    private lazy var childCoordinators: [NavigationCoordinator] = [
        settingsCoordinatorFactory.make(navigation: navigation),
        CreateNoteCoordinator(navigation: navigation),
        editNoteCoordinatorFactory.make(navigation: navigation)
    ]

    private var retainedRootViewController: UIViewController?

    private let navigation: Navigation
    private let notesViewControllerFactory: NotesViewControllerFactory
    private let settingsCoordinatorFactory: SettingsCoordinatorFactory
    private let editNoteCoordinatorFactory: EditNoteCoordinatorFactory

    init(
        navigation: Navigation,
        notesViewControllerFactory: NotesViewControllerFactory,
        settingsCoordinatorFactory: SettingsCoordinatorFactory,
        editNoteCoordinatorFactory: EditNoteCoordinatorFactory
    ) {
        self.navigation = navigation
        self.notesViewControllerFactory = notesViewControllerFactory
        self.settingsCoordinatorFactory = settingsCoordinatorFactory
        self.editNoteCoordinatorFactory = editNoteCoordinatorFactory
    }

    func shouldHandle(url: URL) -> Bool {
        true
    }

    func handle(url: URL) -> [UIViewController] {
        var viewControllers: [UIViewController]

        if let retainedRootViewController {
            viewControllers = [retainedRootViewController]
        } else {
            let rootViewController = notesViewControllerFactory.make(coordinator: self)
            self.retainedRootViewController = rootViewController
            viewControllers = [rootViewController]
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
}
