import UIKit

@testable import Jottre

@MainActor
final class JotConflictViewControllerFactoryMock: JotConflictViewControllerFactoryProtocol {

    private let makeProvider: @MainActor (_ viewModel: JotConflictViewModel) -> UIViewController

    init(
        makeProvider: @MainActor @escaping (_ viewModel: JotConflictViewModel) -> UIViewController = { _ in
            UIViewController()
        }
    ) {
        self.makeProvider = makeProvider
    }

    func make(viewModel: JotConflictViewModel) -> UIViewController {
        makeProvider(viewModel)
    }
}
