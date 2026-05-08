import UIKit

@testable import Jottre

@MainActor
final class CloudMigrationViewControllerFactoryMock: CloudMigrationViewControllerFactoryProtocol {

    private let makeProvider: @MainActor (_ viewModel: CloudMigrationViewModel) -> UIViewController

    init(
        makeProvider: @MainActor @escaping (_ viewModel: CloudMigrationViewModel) -> UIViewController = { _ in
            UIViewController()
        }
    ) {
        self.makeProvider = makeProvider
    }

    func make(viewModel: CloudMigrationViewModel) -> UIViewController {
        makeProvider(viewModel)
    }
}
