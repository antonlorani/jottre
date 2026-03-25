import UIKit

@MainActor
protocol NoteConflictViewControllerFactory: Sendable {

    func make(coordinator: NoteConflictCoordinator) -> UIViewController
}

struct IOS18NoteConflictViewControllerFactory: NoteConflictViewControllerFactory {

    func make(coordinator: NoteConflictCoordinator) -> UIViewController {
        PageViewController(
            viewModel: NoteConflictViewModel(
                coordinator: coordinator
            ),
            textBarButtonItemFactory: IOS18TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26NoteConflictViewControllerFactory: NoteConflictViewControllerFactory {

    func make(coordinator: NoteConflictCoordinator) -> UIViewController {
        PageViewController(
            viewModel: NoteConflictViewModel(
                coordinator: coordinator
            ),
            textBarButtonItemFactory: IOS26TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory()
        )
    }
}
