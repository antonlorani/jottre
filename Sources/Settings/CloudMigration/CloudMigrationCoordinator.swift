import UIKit

final class CloudMigrationCoordinator: NavigationCoordinator {
    
    func shouldHandle(url: URL) -> Bool {
        url.path.hasPrefix(CloudMigrationURL().path)
    }
    
    func handle(url: URL) -> [UIViewController] {
        [
            CloudMigrationViewController(
                viewModel: CloudMigrationViewModel(
                    coordinator: self
                )
            )
        ]
    }
}
