import UIKit

@MainActor
protocol NotesCoordinatorFactory: Sendable {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18NotesCoordinatorFactory: NotesCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        NotesCoordinator(
            navigation: navigation,
            notesViewControllerFactory: IOS18NotesViewControllerFactory(),
            settingsCoordinatorFactory: IOS18SettingsCoordinatorFactory(),
            editNoteCoordinatorFactory: IOS18EditNoteCoordinatorFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26NotesCoordinatorFactory: NotesCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        NotesCoordinator(
            navigation: navigation,
            notesViewControllerFactory: IOS26NotesViewControllerFactory(),
            settingsCoordinatorFactory: IOS26SettingsCoordinatorFactory(),
            editNoteCoordinatorFactory: IOS26EditNoteCoordinatorFactory()
        )
    }
}
