import UIKit

final class NoteConflictCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func start() {

    }

    func dismiss() {
        navigation.dismiss(animated: true)
    }
}
