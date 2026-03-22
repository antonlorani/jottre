import UIKit

@MainActor
protocol EditNoteViewControllerFactory: Sendable {

    func make(coordinator: EditNoteCoordinator) -> UIViewController
}

struct IOS18EditNoteViewControllerFactory: EditNoteViewControllerFactory {

    func make(coordinator: EditNoteCoordinator) -> UIViewController {
        EditNoteViewController(
            viewModel: EditNoteViewModel(
                coordinator: coordinator,
                menuConfigurationFactory: NoteMenuConfigurationFactory()
            ),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26EditNoteViewControllerFactory: EditNoteViewControllerFactory {

    func make(coordinator: EditNoteCoordinator) -> UIViewController {
        EditNoteViewController(
            viewModel: EditNoteViewModel(
                coordinator: coordinator,
                menuConfigurationFactory: NoteMenuConfigurationFactory()
            ),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory()
        )
    }
}
