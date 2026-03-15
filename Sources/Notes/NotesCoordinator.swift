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

    func shouldHandle(deepLink: DeepLink) -> Bool {
        true
    }

    func handle(deepLink: DeepLink) -> [UIViewController] {
        var viewControllers: [UIViewController]

        if let retainedRootViewController {
            viewControllers = [retainedRootViewController]
        } else {
            let rootViewController = notesViewControllerFactory.make(coordinator: self)
            self.retainedRootViewController = rootViewController
            viewControllers = [rootViewController]
        }

        if let childCoordinator = childCoordinators.first(where: { $0.shouldHandle(deepLink: deepLink) }) {
            return viewControllers + childCoordinator.handle(deepLink: deepLink)
        }

        return viewControllers
    }

    func openSettings() {
        navigation.open(deepLink: SettingsDeepLink())
    }

    func openCreateNote() {
        navigation.open(deepLink: CreateNoteDeepLink())
    }

    func openNote(_ note: NoteBusinessModel) {
        navigation.open(deepLink: EditNoteDeepLink())
    }
}
