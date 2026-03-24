import UIKit

@MainActor
protocol SettingsViewControllerFactory: Sendable {

    func make(coordinator: SettingsCoordinator) -> UIViewController
}

struct IOS18SettingsViewControllerFactory: SettingsViewControllerFactory {

    func make(coordinator: SettingsCoordinator) -> UIViewController {
        let viewController = PageViewController(
            viewModel: SettingsViewModel(coordinator: coordinator),
            textBarButtonItemFactory: IOS18TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory()
        )
        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }
}

@available(iOS 26, *)
struct IOS26SettingsViewControllerFactory: SettingsViewControllerFactory {

    func make(coordinator: SettingsCoordinator) -> UIViewController {
        let viewController = PageViewController(
            viewModel: SettingsViewModel(coordinator: coordinator),
            textBarButtonItemFactory: IOS26TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory()
        )
        viewController.navigationItem.largeTitleDisplayMode = .always
        return viewController
    }
}
