import UIKit

@MainActor
protocol NotesViewControllerFactory: Sendable {

    func make(coordinator: NotesCoordinator) -> UIViewController
}

struct IOS18NotesViewControllerFactory: NotesViewControllerFactory {

    func make(coordinator: NotesCoordinator) -> UIViewController {
        let viewController = PageViewController(
            viewModel: NotesViewModel(
                coordinator: coordinator,
                menuConfigurationFactory: NoteMenuConfigurationFactory()
            ),
            textBarButtonItemFactory: IOS18TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory()
        )
#if targetEnvironment(macCatalyst)
        viewController.navigationItem.largeTitleDisplayMode = .never
#else
        viewController.navigationItem.largeTitleDisplayMode = .always
#endif
        return viewController
    }
}

@available(iOS 26, *)
struct IOS26NotesViewControllerFactory: NotesViewControllerFactory {

    func make(coordinator: NotesCoordinator) -> UIViewController {
        let viewController = PageViewController(
            viewModel: NotesViewModel(
                coordinator: coordinator,
                menuConfigurationFactory: NoteMenuConfigurationFactory()
            ),
            textBarButtonItemFactory: IOS26TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory()
        )
#if targetEnvironment(macCatalyst)
        viewController.navigationItem.largeTitleDisplayMode = .never
#else
        viewController.navigationItem.largeTitleDisplayMode = .always
#endif
        return viewController
    }
}
