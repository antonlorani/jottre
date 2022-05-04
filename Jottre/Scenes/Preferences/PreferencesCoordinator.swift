import UIKit

final class PreferencesCoordinator: Coordinator {
    var release: CoordinatorReleaseClosure?

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let preferencesNavigationController = PreferencesNavigationController()
        let preferencesViewController = PreferencesViewController(
            viewModel: PreferencesViewModel(
                coordinator: self
            )
        )
        preferencesNavigationController.modalPresentationStyle = .formSheet
        preferencesNavigationController.setViewControllers([preferencesViewController], animated: true)
        navigationController.present(preferencesNavigationController, animated: true)
    }
}
