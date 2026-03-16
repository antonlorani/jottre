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
            enableCloudCoordinatorFactory: IOS18EnableCloudCoordinatorFactory(),
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
            enableCloudCoordinatorFactory: IOS26EnableCloudCoordinatorFactory(),
            editNoteCoordinatorFactory: IOS26EditNoteCoordinatorFactory()
        )
    }
}
