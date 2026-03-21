import UIKit

@MainActor
protocol CloudMigrationViewControllerFactory: Sendable {

    func make(coordinator: CloudMigrationCoordinator) -> UIViewController
}

struct IOS18CloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory {

    func make(coordinator: CloudMigrationCoordinator) -> UIViewController {
        CloudMigrationViewController(
            viewModel: CloudMigrationViewModel(coordinator: coordinator)
        )
    }
}

@available(iOS 26, *)
struct IOS26CloudMigrationViewControllerFactory: CloudMigrationViewControllerFactory {

    func make(coordinator: CloudMigrationCoordinator) -> UIViewController {
        CloudMigrationViewController(
            viewModel: CloudMigrationViewModel(coordinator: coordinator)
        )
    }
}
