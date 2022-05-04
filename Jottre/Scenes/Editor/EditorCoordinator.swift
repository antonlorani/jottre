import UIKit

final class EditorCoordinator: Coordinator {
    var release: CoordinatorReleaseClosure?

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let editorViewController = EditorViewController(
            viewModel: EditorViewModel(
                coordinator: self
            )
        )
        navigationController.pushViewController(editorViewController, animated: true)
    }
}
