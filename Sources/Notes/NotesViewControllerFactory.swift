import UIKit

@MainActor
protocol NotesViewControllerFactory: Sendable {

    func make(coordinator: NotesCoordinator) -> UIViewController
}

struct IOS18NotesViewControllerFactory: NotesViewControllerFactory {

    func make(coordinator: NotesCoordinator) -> UIViewController {
        NotesViewController(
            viewModel: NotesViewModel(coordinator: coordinator),
            settingsBarButtonItemFactory: IOS18SettingsBarButtonItemFactory(),
            createNoteBarButtonItemFactory: IOS18CreateNoteBarButtonItemFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26NotesViewControllerFactory: NotesViewControllerFactory {

    func make(coordinator: NotesCoordinator) -> UIViewController {
        NotesViewController(
            viewModel: NotesViewModel(coordinator: coordinator),
            settingsBarButtonItemFactory: IOS26SettingsBarButtonItemFactory(),
            createNoteBarButtonItemFactory: IOS26CreateNoteBarButtonItemFactory()
        )
    }
}
