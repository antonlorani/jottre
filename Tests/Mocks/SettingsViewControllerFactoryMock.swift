import UIKit

@testable import Jottre

@MainActor
final class SettingsViewControllerFactoryMock: SettingsViewControllerFactoryProtocol {

    private let makeProvider: @MainActor (_ coordinator: SettingsCoordinatorProtocol) -> UIViewController

    init(
        makeProvider: @MainActor @escaping (_ coordinator: SettingsCoordinatorProtocol) -> UIViewController = { _ in
            UIViewController()
        }
    ) {
        self.makeProvider = makeProvider
    }

    func make(coordinator: SettingsCoordinatorProtocol) -> UIViewController {
        makeProvider(coordinator)
    }
}
