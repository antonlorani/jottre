import UIKit

@MainActor
protocol CloudMigrationViewControllerFactory: Sendable {

    func make(coordinator: CloudMigrationCoordinator) -> UIViewController
}

struct IOS18CloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory {

    func make(coordinator: CloudMigrationCoordinator) -> UIViewController {
        PageViewController(
            viewModel: CloudMigrationViewModel(coordinator: coordinator),
            textBarButtonItemFactory: IOS18TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26CloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory {

    func make(coordinator: CloudMigrationCoordinator) -> UIViewController {
        PageViewController(
            viewModel: CloudMigrationViewModel(coordinator: coordinator),
            textBarButtonItemFactory: IOS26TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory()
        )
    }
}
