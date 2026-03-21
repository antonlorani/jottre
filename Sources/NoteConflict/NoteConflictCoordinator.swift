import UIKit

final class NoteConflictCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func start() {
        let viewModel = NoteConflictViewModel(coordinator: self)
        navigation.present(NoteConflictViewController(viewModel: viewModel), animated: true)
    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
