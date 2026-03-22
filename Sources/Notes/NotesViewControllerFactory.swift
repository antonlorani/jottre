import UIKit

@MainActor
protocol NotesViewControllerFactory: Sendable {

    func make(coordinator: NotesCoordinator) -> UIViewController
}

struct IOS18NotesViewControllerFactory: NotesViewControllerFactory {

    func make(coordinator: NotesCoordinator) -> UIViewController {
        NotesViewController(
            viewModel: NotesViewModel(
                coordinator: coordinator,
                menuConfigurationFactory: NoteMenuConfigurationFactory()
            ),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory(),
            textBarButtonItemFactory: IOS18TextBarButtonItemFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26NotesViewControllerFactory: NotesViewControllerFactory {

    func make(coordinator: NotesCoordinator) -> UIViewController {
        NotesViewController(
            viewModel: NotesViewModel(
                coordinator: coordinator,
                menuConfigurationFactory: NoteMenuConfigurationFactory()
            ),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory(),
            textBarButtonItemFactory: IOS26TextBarButtonItemFactory()
        )
    }
}
