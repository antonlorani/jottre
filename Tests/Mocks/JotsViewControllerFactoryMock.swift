import UIKit

@testable import Jottre

@MainActor
final class JotsViewControllerFactoryMock: JotsViewControllerFactoryProtocol {

    private let makeProvider: @MainActor (_ coordinator: JotsCoordinatorProtocol) -> UIViewController

    init(
        makeProvider: @MainActor @escaping (_ coordinator: JotsCoordinatorProtocol) -> UIViewController = { _ in
            UIViewController()
        }
    ) {
        self.makeProvider = makeProvider
    }

    func make(coordinator: JotsCoordinatorProtocol) -> UIViewController {
        makeProvider(coordinator)
    }
}
