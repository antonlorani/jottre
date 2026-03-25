import UIKit

final class NoteConflictCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation
    private let noteConflictViewControllerFactory: NoteConflictViewControllerFactory

    init(
        navigation: Navigation,
        noteConflictViewControllerFactory: NoteConflictViewControllerFactory
    ) {
        self.navigation = navigation
        self.noteConflictViewControllerFactory = noteConflictViewControllerFactory
    }

    func start() {
        let viewController = noteConflictViewControllerFactory.make(coordinator: self)
        viewController.isModalInPresentation = true

        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.navigationBar.prefersLargeTitles = false
        navigation.present(navigationController, animated: true)
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
