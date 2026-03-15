import UIKit

@MainActor
protocol SettingsViewControllerFactory: Sendable {

    func make(coordinator: SettingsCoordinator) -> UIViewController
}

struct IOS18SettingsViewControllerFactory: SettingsViewControllerFactory {

    func make(coordinator: SettingsCoordinator) -> UIViewController {
        SettingsViewController(
            viewModel: SettingsViewModel(coordinator: coordinator),
            closeBarButtonItemFactory: IOS18CloseBarButtonItemFactory(),
        )
    }
}

@available(iOS 26, *)
struct IOS26SettingsViewControllerFactory: SettingsViewControllerFactory {

    func make(coordinator: SettingsCoordinator) -> UIViewController {
        SettingsViewController(
            viewModel: SettingsViewModel(coordinator: coordinator),
            closeBarButtonItemFactory: IOS26CloseBarButtonItemFactory()
        )
    }
}
