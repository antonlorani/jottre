import UIKit

@testable import Jottre

@MainActor
final class EnableCloudViewControllerFactoryMock: EnableCloudViewControllerFactoryProtocol {

    private let makeProvider: @MainActor (_ coordinator: EnableCloudCoordinatorProtocol) -> UIViewController

    init(
        makeProvider: @MainActor @escaping (_ coordinator: EnableCloudCoordinatorProtocol) -> UIViewController = { _ in
            UIViewController()
        }
    ) {
        self.makeProvider = makeProvider
    }

    func make(coordinator: EnableCloudCoordinatorProtocol) -> UIViewController {
        makeProvider(coordinator)
    }
}
