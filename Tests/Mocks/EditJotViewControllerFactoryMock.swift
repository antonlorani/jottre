import UIKit

@testable import Jottre

@MainActor
final class EditJotViewControllerFactoryMock: EditJotViewControllerFactoryProtocol {

    private let makeProvider:
        @MainActor (_ jotFileInfo: JotFile.Info, _ coordinator: EditJotCoordinatorProtocol) -> UIViewController

    init(
        makeProvider:
            @MainActor @escaping (_ jotFileInfo: JotFile.Info, _ coordinator: EditJotCoordinatorProtocol) ->
            UIViewController = { _, _ in UIViewController() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(jotFileInfo: JotFile.Info, coordinator: EditJotCoordinatorProtocol) -> UIViewController {
        makeProvider(jotFileInfo, coordinator)
    }
}
