import UIKit

@MainActor
final class NotesCoordinator: NavigationCoordinator {

    private lazy var childCoordinators: [NavigationCoordinator] = [
        settingsCoordinatorFactory.make(navigation: navigation),
        CreateNoteCoordinator(navigation: navigation),
        EditNoteCoordinator(navigation: navigation)
    ]

    private var retainedRootViewController: UIViewController?

    private let navigation: Navigation
    private let notesViewControllerFactory: NotesViewControllerFactory
    private let settingsCoordinatorFactory: SettingsCoordinatorFactory

    init(
        navigation: Navigation,
        notesViewControllerFactory: NotesViewControllerFactory,
        settingsCoordinatorFactory: SettingsCoordinatorFactory
    ) {
        self.navigation = navigation
        self.notesViewControllerFactory = notesViewControllerFactory
        self.settingsCoordinatorFactory = settingsCoordinatorFactory
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
            return viewControllers + childCoordinator.handle(url: url)
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
